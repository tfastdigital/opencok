import { Effect } from "effect";
import { decodePacket, encodePacket } from "@opencok/contracts/binary";
import { mapQuery } from "@opencok/contracts";
import { World } from "./modules/world/world";

export function handler(world = new World())
{
    const kingdomStates = new Map<string, { wood: number; food: number; power: number; levels: Record<string, number> }>();

    return async (request: Request): Promise<Response> => {
        const url = new URL(request.url);
        if (request.method === "GET" && url.pathname === "/healthz")
        {
            return Response.json({ status: "ok", kingdomId: world.id });
        }
        if (request.method === "GET" && url.pathname === "/kingdom/state")
        {
            const playerId = url.searchParams.get("playerId") ?? "default";
            const state = kingdomStates.get(playerId) ?? {
                wood: 1900000,
                food: 1900000,
                power: 295097198,
                levels: { buildingCastle: 30, buildingBarracks: 22 },
            };
            kingdomStates.set(playerId, state);
            return Response.json(state);
        }
        if (request.method === "POST" && url.pathname === "/kingdom/action")
        {
            const body = (await request.json()) as { playerId?: string; action?: string; buildingKey?: string };
            const playerId = body.playerId ?? "default";
            const state = kingdomStates.get(playerId) ?? {
                wood: 1900000,
                food: 1900000,
                power: 295097198,
                levels: { buildingCastle: 30, buildingBarracks: 22 },
            };
            if (body.action === "BUILDING_UPGRADE" && body.buildingKey)
            {
                const lv = state.levels[body.buildingKey] ?? 1;
                const woodCost = (lv + 1) * 12000;
                const foodCost = (lv + 1) * 10000;
                if (state.wood < woodCost || state.food < foodCost)
                {
                    return Response.json({ ok: false, error: "Insufficient resources" }, { status: 400 });
                }
                state.wood -= woodCost;
                state.food -= foodCost;
                state.levels[body.buildingKey] = lv + 1;
                state.power += 15000;
                kingdomStates.set(playerId, state);
            }
            return Response.json({ ok: true, state });
        }
        if (request.method !== "POST" || url.pathname !== "/map/query")
        {
            return new Response("Not found", { status: 404 });
        }
        try
        {
            const reader = request.body?.getReader();
            if (!reader)
            {
                return new Response("Missing body", { status: 400 });
            }
            const bytes = new Uint8Array(26);
            let offset = 0;
            try
            {
                while (true)
                {
                    const { done, value } = await reader.read();
                    if (done)
                    {
                        break;
                    }
                    if (offset + value.length > bytes.length)
                    {
                        await reader.cancel();
                        return new Response("Body too large", { status: 413 });
                    }
                    bytes.set(value, offset);
                    offset += value.length;
                }
            }
            finally
            {
                reader.releaseLock();
            }
            const packet = decodePacket(bytes.subarray(0, offset));
            if (packet.opcode !== 16)
            {
                return new Response("Invalid packet", { status: 400 });
            }
            const query = mapQuery.parse(packet.value);
            const region = Effect.runSync(Effect.sync(() => world.query(query)));
            return new Response(encodePacket(17, region).slice().buffer, {
                headers: { "Content-Type": "application/octet-stream" },
            });
        }
        catch
        {
            return new Response("Invalid packet", { status: 400 });
        }
    };
}
