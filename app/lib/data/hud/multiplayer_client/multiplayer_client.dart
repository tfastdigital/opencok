import 'dart:async';
import 'dart:convert';
import 'dart:io';

class MultiplayerClient {
  MultiplayerClient({
    required this.uri,
    required this.onMessage,
    this.onStatus,
  });

  final Uri uri;
  final void Function(Map<String, dynamic> message) onMessage;
  final void Function(bool connected)? onStatus;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _disposed = false;
  bool _connected = false;

  bool get connected => _connected;

  void start() {
    if (_disposed) return;
    unawaited(_connect());
  }

  Future<void> _connect() async {
    if (_disposed) return;
    try {
      final socket = await WebSocket.connect(
        uri.toString(),
      ).timeout(const Duration(seconds: 5));
      if (_disposed) {
        await socket.close();
        return;
      }
      _socket = socket;
      _connected = true;
      onStatus?.call(true);
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (_connected) {
          send({'type': 'ping'});
        }
      });
      _sub = socket.listen(
        (dynamic data) {
          if (data is String) {
            try {
              final decoded = jsonDecode(data);
              if (decoded is Map<String, dynamic>) {
                onMessage(decoded);
              }
            } catch (_) {}
          }
        },
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _sub?.cancel();
    _sub = null;
    _socket = null;
    if (_connected) {
      _connected = false;
      onStatus?.call(false);
    }
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), _connect);
  }

  void send(Map<String, dynamic> payload) {
    final socket = _socket;
    if (!_connected || socket == null) return;
    try {
      socket.add(jsonEncode(payload));
    } catch (_) {
      _handleDisconnect();
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _sub?.cancel();
    _socket?.close();
    _socket = null;
  }
}
