import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/chat_provider.dart';
import 'package:flutter_swoole_chat/Helpers/network_constants.dart';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:provider/provider.dart';

export 'package:provider/provider.dart';

///Converts `enum` to `String`
String enumToString(_enum) {
  return _enum.toString().split(".").last;
}

///Error indicates that the user didn't connect to the socket
class NotConnected implements Exception {}

///Error indicates that the user didn't subscribe to a room
class NotSubscribed implements Exception {}

/// Incoming Events
///
/// see also:
/// - enum `OUTEvent`
enum INEvent {
  typing,
  stop_typing,
  joined_chat,
  reserve_massage,
  general_chat,
}

/// Outgoing Events
///
/// see also:
/// - enum `INEvent`
enum OUTEvent {
  send_message,
  leave_chat,
  join_chat,
  typing,
  stop_typing,
}

typedef DynamicCallback = void Function(dynamic data);

class SocketController {
  Socket? _socket;
  Chat? _chat;

  ///Current user room subscription
  Chat? get chat => _chat;

  ///`Boolean` represents the state of the socket if it is currently connected.
  bool get connected => _socket!.connected;

  ///`Boolean` represents the state of the socket if it is currently diconnected form the server.
  bool get disConnected => !connected;

  /// Initializes the controller and its streams
  ///
  /// see also:
  /// - `connect()`
  void init() {
    //TODO: Add headers
    _socket ??= io(
      NetworkConstants.chatAPI,
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().setExtraHeaders({}).build(),
    );
  }

  ///initializes the events listeners and sends the events to the stream controller sink
  void _initListeners() {
    _connectedAssetion();
    final _socket = this._socket!;

    _socket.on(enumToString(INEvent.joined_chat), (data) {
      _chat = Chat.fromJson(data);
    });

    _socket.on(enumToString(INEvent.reserve_massage), (response) {
      final _message = ChatMessage.fromJson(response);
      _addNewMessage(_message);
    });

    _socket.on(enumToString(INEvent.typing), (_) {
      _addTypingEvent(UserStartedTyping());
    });

    _socket.on(enumToString(INEvent.stop_typing), (_) {
      _addTypingEvent(UserStoppedTyping());
    });
  }

  ///Connects the device to the socket and initializes all the event listeners
  ///
  /// @Params:
  /// - `onConnectionError`: socket error callback method.
  /// - `connected`: socket conection success callback method.
  Socket connect({DynamicCallback? onConnectionError, VoidCallback? connected}) {
    assert(_socket != null, "Did you forget to call `init()` first?");

    final _socketS = _socket!.connect();

    _socket!.onConnect((_) {
      _initListeners();
      connected?.call();
      log("Connected to Socket");
    });

    _socket!.onConnectError((data) => onConnectionError?.call(data));
    return _socketS;
  }

  ///Disconnects the device from the socket.
  ///
  /// @Params:
  /// - `disconnected`: socket disconection success callback method.
  Socket disconnect({VoidCallback? disconnected}) {
    final _socketS = _socket!.disconnect();
    _socket!.onDisconnect((_) {
      disconnected?.call();
      log("Disconnected");
    });
    return _socketS;
  }

  void joinChat(int? chatID, int? toUserID) {
    _connectedAssetion();
    final _socket = this._socket!;
    _socket.emit(enumToString(OUTEvent.join_chat), {'chat_id': chatID, 'to_user_id': toUserID});
  }

  void leaveChat() {
    _connectedAssetion();
    final _socket = this._socket!;
    _socket.emit(enumToString(OUTEvent.leave_chat), {'chat_id': _chat!.id});
    //TODO: Clear prev chat messages
    _chat = null;
  }

  ///Sends a message to the users in the same room.
  ///
  void sendMessage(ChatMessage message) {
    _connectedAssetion();
    if (_chat == null) throw NotSubscribed();
    final _socket = this._socket!;

    //Stop typing then send a new message.
    _socket
      ..emit(
        enumToString(OUTEvent.stop_typing),
        {'chat_id': _chat!.id},
      )
      ..emit(
        enumToString(OUTEvent.send_message),
        {
          'chat_id': _chat!.id,
          'message': message.content,
        },
      );

    _addNewMessage(message);
  }

  ///Sends to the room that the current user is typing.
  void typing() {
    _connectedAssetion();
    if (_chat == null) throw NotSubscribed();
    final _socket = this._socket!;
    _socket.emit(enumToString(OUTEvent.typing), {'chat_id': _chat!.id});
  }

  ///Informs the room members that tha current user has stopped typing.
  void stopTyping() {
    _connectedAssetion();
    if (_chat == null) throw NotSubscribed();
    final _socket = this._socket!;
    _socket.emit(enumToString(OUTEvent.stop_typing), {'chat_id': _chat!.id});
  }

  ///Disposes all the objects which have been initialized and resests the whole controller.
  void dispose() {
    _socket?.dispose();
    _socket = null;
    _chat = null;
  }

  void _connectedAssetion() {
    assert(this._socket != null, "Did you forget to call `init()` first?");
    if (disConnected) throw NotConnected();
  }

  void _addNewMessage(ChatMessage message) => _addEvent(message);

  void _addTypingEvent(UserTyping event) {
    // _events!.removeWhere((e) => e is UserTyping);
    // _events = <ChatEvent>[event, ..._events!];
    // _newMessagesController?.sink.add(_events!);
  }

  ///Add new event to the steam sink
  ///
  ///see also:
  /// * `watchEvents` getter
  void _addEvent(event) {
    // _events = <ChatEvent>[event, ..._events!];
    // _newMessagesController?.sink.add(_events!);
  }
}
