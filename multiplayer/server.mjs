import http from 'node:http';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PORT = Number(process.env.PORT || 9944);
const STATE_FILE = path.join(__dirname, 'state.json');

function loadState() {
  try {
    if (fs.existsSync(STATE_FILE)) {
      const raw = JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
      return {
        players: raw.players || {},
        marches: [],
        throne: raw.throne || {
          kingId: '',
          kingName: 'LordVanguard',
          allianceTag: 'WAR',
          allianceName: 'Iron Vanguard',
          royalAppointments: {},
        },
        chat: Array.isArray(raw.chat) ? raw.chat.slice(0, 50) : [],
      };
    }
  } catch (err) {
    console.error('Failed to load state:', err);
  }
  return {
    players: {},
    marches: [],
    throne: {
      kingId: '',
      kingName: 'LordVanguard',
      allianceTag: 'WAR',
      allianceName: 'Iron Vanguard',
      royalAppointments: {},
    },
    chat: [],
  };
}

const state = loadState();
const clients = new Set();

function saveState() {
  try {
    const toSave = {
      players: state.players,
      throne: state.throne,
      chat: state.chat.slice(0, 50),
    };
    fs.writeFileSync(STATE_FILE, JSON.stringify(toSave, null, 2));
  } catch (err) {
    console.error('Failed to save state:', err);
  }
}

// Minimal RFC 6455 WebSocket frame encoder/decoder (text frames)
function encodeFrame(opcode, payloadBuf) {
  const len = payloadBuf.length;
  let header;
  if (len < 126) {
    header = Buffer.alloc(2);
    header[0] = 0x80 | opcode;
    header[1] = len;
  } else if (len < 65536) {
    header = Buffer.alloc(4);
    header[0] = 0x80 | opcode;
    header[1] = 126;
    header.writeUInt16BE(len, 2);
  } else {
    header = Buffer.alloc(10);
    header[0] = 0x80 | opcode;
    header[1] = 127;
    header.writeBigUInt64BE(BigInt(len), 2);
  }
  return Buffer.concat([header, payloadBuf]);
}

function sendJson(client, obj) {
  if (!client.socket.writable) return;
  try {
    const buf = Buffer.from(JSON.stringify(obj), 'utf8');
    client.socket.write(encodeFrame(0x1, buf));
  } catch {
    // ignore closed socket
  }
}

function broadcast(obj) {
  const buf = Buffer.from(JSON.stringify(obj), 'utf8');
  const frame = encodeFrame(0x1, buf);
  for (const client of clients) {
    if (client.socket.writable) {
      try {
        client.socket.write(frame);
      } catch {
        // ignore
      }
    }
  }
}

function broadcastWorldState() {
  broadcast({
    type: 'world_state',
    serverTimeMs: Date.now(),
    players: Object.values(state.players),
    marches: state.marches,
    throne: state.throne,
    chat: state.chat.slice(0, 40),
  });
}

function sendToPlayer(playerId, obj) {
  for (const client of clients) {
    if (client.playerId === playerId) {
      sendJson(client, obj);
    }
  }
}

function assignUniqueCoords(playerId, desiredX, desiredY) {
  const taken = new Set();
  for (const [id, p] of Object.entries(state.players)) {
    if (id !== playerId) {
      taken.add(`${p.x},${p.y}`);
    }
  }
  // Keep away from Middle Throne (574, 566)
  taken.add('574,566');
  let x = Number(desiredX) || 570;
  let y = Number(desiredY) || 570;
  if (!taken.has(`${x},${y}`)) return { x, y };
  for (let ring = 2; ring <= 16; ring += 2) {
    for (let dx = -ring; dx <= ring; dx += 3) {
      for (let dy = -ring; dy <= ring; dy += 3) {
        const nx = Math.max(555, Math.min(595, 574 + dx));
        const ny = Math.max(552, Math.min(585, 566 + dy));
        if (!taken.has(`${nx},${ny}`)) {
          return { x: nx, y: ny };
        }
      }
    }
  }
  return { x, y };
}

function handleMessage(client, msg) {
  if (!msg || typeof msg !== 'object') return;
  const now = Date.now();

  switch (msg.type) {
    case 'hello':
    case 'profile_update': {
      const p = msg.player;
      if (!p || !p.playerId) return;
      client.playerId = p.playerId;
      const existing = state.players[p.playerId];
      const coords = existing
        ? { x: existing.x, y: existing.y }
        : assignUniqueCoords(p.playerId, p.x, p.y);
      state.players[p.playerId] = {
        playerId: p.playerId,
        playerName: String(p.playerName || `Lord-${p.playerId.slice(0, 4)}`).slice(0, 24),
        allianceTag: String(p.allianceTag || 'COK').slice(0, 6),
        allianceName: String(p.allianceName || 'Crown Order').slice(0, 32),
        castleLevel: Number(p.castleLevel) || 30,
        power: Number(p.power) || 295000000,
        factionId: String(p.factionId || 'dragon_born'),
        troopsCount: Number(p.troopsCount) || 124500,
        wood: Number(p.wood) || 1900000,
        food: Number(p.food) || 1900000,
        iron: Number(p.iron) || 736300,
        gold: Number(p.gold) || 979586,
        x: coords.x,
        y: coords.y,
        online: true,
        lastSeenMs: now,
      };
      saveState();
      // Tell this client its authoritative assigned coords & current world state
      sendJson(client, {
        type: 'welcome_player',
        player: state.players[p.playerId],
      });
      broadcastWorldState();
      break;
    }

    case 'launch_march': {
      const m = msg.march;
      if (!m || !m.id || !m.fromPlayerId) return;
      const fromPlayer = state.players[m.fromPlayerId];
      const toPlayer = m.toPlayerId ? state.players[m.toPlayerId] : null;
      const durationMs = Math.max(1500, Math.min(30000, Number(m.durationMs) || 5000));
      const march = {
        id: String(m.id),
        fromPlayerId: m.fromPlayerId,
        fromName: fromPlayer ? fromPlayer.playerName : (m.fromName || 'Unknown'),
        toPlayerId: m.toPlayerId || '',
        toName: toPlayer ? toPlayer.playerName : (m.toName || ''),
        kind: String(m.kind || 'attack'),
        label: String(m.label || 'Marching'),
        fromX: fromPlayer ? fromPlayer.x : (Number(m.fromX) || 570),
        fromY: fromPlayer ? fromPlayer.y : (Number(m.fromY) || 570),
        toX: toPlayer ? toPlayer.x : (Number(m.toX) || 574),
        toY: toPlayer ? toPlayer.y : (Number(m.toY) || 566),
        startedAtMs: now,
        durationMs,
      };
      state.marches.push(march);
      broadcastWorldState();

      setTimeout(() => {
        resolveMarch(march.id);
      }, durationMs);
      break;
    }

    case 'send_chat': {
      const text = String(msg.text || '').trim();
      if (!text) return;
      const sender = state.players[msg.senderId];
      const item = {
        id: `chat_${now}_${Math.floor(Math.random() * 1000)}`,
        channel: String(msg.channel || 'Kingdom'),
        senderId: msg.senderId || '',
        sender: sender ? sender.playerName : String(msg.sender || 'Lord'),
        allianceTag: sender ? sender.allianceTag : String(msg.allianceTag || 'COK'),
        text: text.slice(0, 240),
        timestampMs: now,
      };
      state.chat.unshift(item);
      if (state.chat.length > 50) state.chat.length = 50;
      saveState();
      broadcastWorldState();
      break;
    }

    case 'appoint_lord': {
      if (state.throne.kingId && msg.kingId !== state.throne.kingId) return;
      const title = String(msg.title || '').trim();
      const lordName = String(msg.lordName || '').trim();
      if (!title || !lordName) return;
      state.throne.royalAppointments[title] = lordName;
      saveState();
      broadcastWorldState();
      break;
    }
  }
}

function resolveMarch(marchId) {
  const idx = state.marches.findIndex((m) => m.id === marchId);
  if (idx < 0) return;
  const march = state.marches.splice(idx, 1)[0];
  const attacker = state.players[march.fromPlayerId];
  const defender = march.toPlayerId ? state.players[march.toPlayerId] : null;
  const now = Date.now();

  if (march.kind === 'rally' && attacker) {
    state.throne = {
      kingId: attacker.playerId,
      kingName: attacker.playerName,
      allianceTag: attacker.allianceTag,
      allianceName: attacker.allianceName,
      royalAppointments: state.throne.royalAppointments || {},
      capturedAtMs: now,
    };
    attacker.power += 25000;
    attacker.gold += 1500;
    state.chat.unshift({
      id: `throne_chat_${now}`,
      channel: 'Kingdom',
      senderId: 'system',
      sender: 'Royal Herald',
      allianceTag: 'KING',
      text: `${attacker.playerName} [${attacker.allianceTag}] seized the Middle Throne and is crowned King!`,
      timestampMs: now,
    });
    saveState();
  } else if (march.kind === 'attack' && attacker && defender) {
    const attackerWon = attacker.power >= defender.power * 0.9;
    const lootWood = attackerWon ? Math.min(25000, defender.wood) : 0;
    const lootFood = attackerWon ? Math.min(25000, defender.food) : 0;
    const lootIron = attackerWon ? Math.min(10000, defender.iron) : 0;
    const lootGold = attackerWon ? Math.min(250, defender.gold) : 0;

    if (attackerWon) {
      attacker.wood += lootWood;
      attacker.food += lootFood;
      attacker.iron += lootIron;
      attacker.gold += lootGold;
      attacker.power += 15000;
      defender.wood = Math.max(0, defender.wood - lootWood);
      defender.food = Math.max(0, defender.food - lootFood);
      defender.iron = Math.max(0, defender.iron - lootIron);
      defender.gold = Math.max(0, defender.gold - lootGold);
      defender.power = Math.max(1000000, defender.power - 8000);
    } else {
      defender.power += 10000;
      attacker.power = Math.max(1000000, attacker.power - 5000);
    }

    sendToPlayer(attacker.playerId, {
      type: 'battle_report',
      victory: attackerWon,
      opponentName: defender.playerName,
      opponentCoords: `(${defender.x}, ${defender.y})`,
      lootWood,
      lootFood,
      lootIron,
      lootGold,
    });
    sendToPlayer(defender.playerId, {
      type: 'battle_report',
      victory: !attackerWon,
      isDefense: true,
      opponentName: attacker.playerName,
      opponentCoords: `(${attacker.x}, ${attacker.y})`,
      lootWood,
      lootFood,
      lootIron,
      lootGold,
    });
    saveState();
  } else if (march.kind === 'scout' && attacker && defender) {
    sendToPlayer(attacker.playerId, {
      type: 'scout_report',
      targetName: defender.playerName,
      targetCoords: `(${defender.x}, ${defender.y})`,
      castleLevel: defender.castleLevel,
      power: defender.power,
      troopsCount: defender.troopsCount,
      wood: defender.wood,
      food: defender.food,
      iron: defender.iron,
      gold: defender.gold,
    });
  }

  broadcastWorldState();
}

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true, players: Object.keys(state.players).length, marches: state.marches.length }));
    return;
  }
  if (req.url === '/state') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      players: Object.values(state.players),
      marches: state.marches,
      throne: state.throne,
      chat: state.chat.slice(0, 20),
    }, null, 2));
    return;
  }
  res.writeHead(404);
  res.end('Not found');
});

server.on('upgrade', (req, socket) => {
  const key = req.headers['sec-websocket-key'];
  if (!key) {
    socket.destroy();
    return;
  }
  const accept = crypto
    .createHash('sha1')
    .update(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
    .digest('base64');

  socket.write(
    [
      'HTTP/1.1 101 Switching Protocols',
      'Upgrade: websocket',
      'Connection: Upgrade',
      `Sec-WebSocket-Accept: ${accept}`,
      '\r\n',
    ].join('\r\n'),
  );

  const client = { socket, playerId: null };
  clients.add(client);

  let buffer = Buffer.alloc(0);
  socket.on('data', (chunk) => {
    buffer = Buffer.concat([buffer, chunk]);
    while (buffer.length >= 2) {
      const b0 = buffer[0];
      const b1 = buffer[1];
      const opcode = b0 & 0x0f;
      const masked = (b1 & 0x80) !== 0;
      let len = b1 & 0x7f;
      let offset = 2;
      if (len === 126) {
        if (buffer.length < 4) return;
        len = buffer.readUInt16BE(2);
        offset = 4;
      } else if (len === 127) {
        if (buffer.length < 10) return;
        len = Number(buffer.readBigUInt64BE(2));
        offset = 10;
      }
      const maskLen = masked ? 4 : 0;
      if (buffer.length < offset + maskLen + len) return;

      const mask = masked ? buffer.subarray(offset, offset + 4) : null;
      offset += maskLen;
      const payload = Buffer.from(buffer.subarray(offset, offset + len));
      if (mask) {
        for (let i = 0; i < payload.length; i++) {
          payload[i] ^= mask[i % 4];
        }
      }
      buffer = buffer.subarray(offset + len);

      if (opcode === 0x8) {
        socket.end();
        return;
      }
      if (opcode === 0x9) {
        socket.write(encodeFrame(0xA, payload));
        continue;
      }
      if (opcode === 0x1) {
        try {
          const msg = JSON.parse(payload.toString('utf8'));
          handleMessage(client, msg);
        } catch {
          // ignore malformed JSON
        }
      }
    }
  });

  const cleanup = () => {
    clients.delete(client);
    if (client.playerId && state.players[client.playerId]) {
      const stillConnected = [...clients].some((c) => c.playerId === client.playerId);
      state.players[client.playerId].online = stillConnected;
      broadcastWorldState();
    }
  };
  socket.on('close', cleanup);
  socket.on('error', cleanup);
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`OpenCoK Multiplayer Server listening on ws://0.0.0.0:${PORT}`);
});
