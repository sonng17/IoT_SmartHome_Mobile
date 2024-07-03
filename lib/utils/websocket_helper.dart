import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebsocketHelper {
  static final WebsocketHelper _instance = WebsocketHelper._internal();

  factory WebsocketHelper() {
    return _instance;
  }

  WebsocketHelper._internal() {
    // nothing here
  }

  // WebSocketChannel? _channel;
  WebSocket? _channel;

  final StreamController _streamController = StreamController.broadcast(
      sync: true); // stream nhận được các command nhận được từ server

  Stream get stream async* {
    yield* _streamController.stream;
  }

  Timer? _mTimeout, _heartbeatTimeout;
  final _heartbeatInterval = 10;

  void initWebsocket() async {
    _channel = await connectWs();
    if (_channel != null) {
      _clearTimeout();
      // _startHeartbeat();
      _listenToMessage();
      sendCommand({"connect": "hello"});
      //_listen
    } else {
      _autoReconnect();
    }
  }

  Future<WebSocket?> connectWs() async {
    _channel = await WebSocket.connect("ws://10.0.2.2:8000");

    return _channel;
  }

  void sendCommand(Map command) {
    // print("send command to websocket: $command");
    _channel?.add(jsonEncode(command));
  }

  void sendData(dynamic data) {
    print("${DateTime.now()} send data buffer : ${data?.length}");

    _channel?.add(data);
  }

  _autoReconnect() {
    _clearTimeout();

    _mTimeout = Timer(
      const Duration(seconds: 5),
      () {
        initWebsocket();
      },
    );
  }

  _clearTimeout() {
    if (_mTimeout != null) {
      _mTimeout?.cancel();
      _mTimeout = null;
    }
    if (_heartbeatTimeout != null) {
      _heartbeatTimeout?.cancel();
      _heartbeatTimeout = null;
    }
  }

  _listenToMessage() {
    print("websocket listen");

    if (_channel != null) {
      _channel?.listen(
        (message) {
          print("${DateTime.now()}: websocket listen: $message");

          if (_streamController.isClosed) {
          } else {
            _streamController.sink.add(message);
          }
        },
        onDone: () {
          print("Websocket listen onDone");
          _autoReconnect();
        },
      );
    }
  }

  _startHeartbeat() {
    print("${DateTime.now()}---Websocket_helper---start-heartbeat");
    _heartbeatTimeout =
        Timer.periodic(Duration(seconds: _heartbeatInterval), (Timer timer) {
      _channel?.add(jsonEncode({"heardbeat": 1}));
    });
  }

  close() {
    _clearTimeout();
    // _channel?.sink.close(status.goingAway);
    _channel?.close();
    _streamController.close();
  }
}
