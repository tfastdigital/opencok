# OpenCoK

OpenCoK is an independent, open-source strategy game project inspired by Clash of Kings. It includes a Flutter client, a Go WebSocket gateway, a Bun realm service, and shared game and persistence packages. Android is the current device test target. The project uses its own client.

## Set up the development environment

Install the toolchains listed in [mise.toml](mise.toml). The default branch uses Bun for the TypeScript workspace, Go for the game gateway, and Flutter with the Android SDK and JDK 21 for Android development.

```sh
git clone --branch develop https://github.com/tfastdigital/opencok.git
cd opencok
bun install --frozen-lockfile
```

## Run the game stack

Start the realm and gateway in separate terminals:

```sh
# Repository root
bun --no-env-file apps/realm/src/main.ts
```

```sh
# Repository root, in a second terminal
cd gameserver
go run ./cmd/gameserver -realm-url http://127.0.0.1:9940
```

Check `http://127.0.0.1:9940/healthz` and `http://127.0.0.1:9933/healthz`. The Flutter gateway endpoint is `ws://127.0.0.1:9933/ws`. See the [gateway usage guide](gameserver/README.md), [binary protocol](gameserver/PROTOCOL.md), and [realm source](apps/realm/src/main.ts).

Start Flutter from a third terminal:

```sh
cd app
flutter pub get
flutter run --dart-define=GATEWAY_URL=ws://127.0.0.1:9933/ws
```

## Build and test on Android

For a physical USB test device, enable USB debugging and authorize the host. If you use the loopback endpoint above, forward the gateway port to each phone before launching the app.

```sh
adb devices
adb -s DEVICE_SERIAL reverse tcp:9933 tcp:9933
```

From `app/`, build for both 32-bit ARM and 64-bit ARM phones:

```sh
flutter build apk --release --target-platform android-arm,android-arm64 --dart-define=GATEWAY_URL=ws://127.0.0.1:9933/ws
adb -s DEVICE_SERIAL install -r build/app/outputs/flutter-apk/app-release.apk
```

Use the same signing key as the installed app for an in-place update. For distributed builds, use your release signing configuration and the deployed `wss://` endpoint. Reapply USB forwarding if ADB restarts.

## Run checks

| Check | Working directory | Command |
| --- | --- | --- |
| Flutter unit and widget tests | `app/` | `flutter test` |
| Flutter → Go → Bun integration | `app/` with both services running | `flutter test --dart-define=GAMESERVER_TEST_URL=ws://127.0.0.1:9933/ws` |
| Go gateway and protocol | `gameserver/` | `go test ./...` |
| Realm tests | Repository root | `bun --no-env-file test apps/realm/tests` |
| Workspace contracts and persistence | Repository root | `bun run test` |

The live database suites need a working Docker engine. Use an isolated test database for migration, seed, and recovery exercises.

## Data and deployment

The [Docker Compose files](docker/) describe the service stack. Copy [the environment example](docker/.env.example) to a separate local configuration and provision the required services before starting a deployment. See the [persistence package](packages/persistence/) for migration, seed, and database workflows. Back up persistent data before a migration. Rehearse the migration against a disposable copy and check service health, the client connection, and saved progress before release.

## Managed gameplay preview

A separate managed multiplayer checkout is used to develop and test live player saves, construction and troop queues, AI Lords, alliance diplomacy, and single-realm conquest. These features and the Node scripts below are pending publication on `develop`. Use these steps in a checkout that includes the managed `multiplayer/` directory.

1. Start `node multiplayer/server.mjs` with a dedicated `OPENCOK_STATE_FILE`. The default gameplay port is `9944`; `/health` reports availability. Keep state files and backups outside source control.
2. Build the preview client with `--dart-define=MULTIPLAYER_URL=ws://127.0.0.1:9944`. For USB testing, run `adb -s DEVICE_SERIAL reverse tcp:9944 tcp:9944`. The managed gameplay socket and Go gateway are separate endpoints.
3. Set `OPENCOK_ADMIN_PORT` and `OPENCOK_ADMIN_TOKEN_FILE` for local administration, then run `node multiplayer/admin.mjs status`. The optional dashboard uses `node multiplayer/admin-web.mjs` with a private `OPENCOK_ADMIN_LOGIN_FILE`. Keep the admin endpoints on loopback and use a secure tunnel for remote access.
4. Configure `OPENCOK_AI_POPULATION` for the preview realm. Dialogue can use local templates or an optional server-side DeepSeek credential supplied through `OPENCOK_DEEPSEEK_KEY_FILE`. Keep credentials out of Git and Android builds.
5. Run `node --test multiplayer/*.test.mjs` in the managed checkout, then verify gameplay, admin access, and restart recovery using disposable saves before deploying. The current conquest preview covers lord-level vassalage and strongholds. Cross-kingdom sovereignty and imperial offices are pending.

## License

OpenCoK's original code and documentation are available under the [MIT license](LICENSE). The Elex client, Clash of Kings assets, and other third-party materials remain subject to their respective rights and terms.

OpenCoK is not affiliated with or endorsed by Elex.
