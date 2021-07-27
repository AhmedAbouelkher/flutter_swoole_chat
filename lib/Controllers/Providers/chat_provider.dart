import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Repositories/chat_repository.dart';
import 'package:flutter_swoole_chat/Controllers/socket_controller.dart';
import 'package:flutter_swoole_chat/Models/home_chat_models.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

export 'package:flutter_swoole_chat/Controllers/Repositories/chat_repository.dart';
export 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  static ChatProvider get(BuildContext context) => context.read<ChatProvider>();

  final ChatRepository _chatRepository;

  ChatProvider({
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  String? _chatMesasgesNextPageUrl;
  List<ChatEvent>? _chatEvents;
  List<ChatEvent>? get chatEvents => _chatEvents;
  String? get messagesNextPageURL => _chatMesasgesNextPageUrl;
  bool get hasNextPage => _chatMesasgesNextPageUrl != null;

  List<Chat>? _chats;
  List<Chat>? get chats => _chats;

  Future<void> fetchChats() async {
    try {
      _chats = (await _chatRepository.fetchChats()).data;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchChatMessages({required int chatID}) async {
    _chatEvents = null;
    notifyListeners();
    try {
      var messagesResponse = await _chatRepository.fetchChatMessages(chatID: chatID);
      _chatEvents = messagesResponse.data;
      _chatMesasgesNextPageUrl = messagesResponse.nextPageUrl;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  bool _fetchMoreMessages = true;

  Future<void> fetchMoreChatMessages() async {
    if (!_fetchMoreMessages) return;
    if (_chatMesasgesNextPageUrl == null) return;
    _fetchMoreMessages = false;
    log("FETCHING MORE MESSAGES");

    try {
      var messagesResponse = await _chatRepository.fetchChatMessages(nextPageURL: messagesNextPageURL);
      _addOLDMessages(messagesResponse.data);
      _chatMesasgesNextPageUrl = messagesResponse.nextPageUrl;

      _fetchMoreMessages = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  SocketController? _socketController;

  @visibleForTesting
  SocketController? get socketController => _socketController;

  void initSocket(String token) {
    _socketController = SocketController()
      ..init(token: token)
      ..connect(
        onConnectionError: (data) {
          log("CONNECTION ERROR with data: $data");
        },
      );
  }

  void joinChat(int? chatID, int? toUserID) {
    try {
      _socketController?.joinChat(chatID, toUserID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveChat() async {
    try {
      return await _socketController?.leaveChat();
    } catch (e) {
      rethrow;
    }
  }

  //TODO: Stopped typing doesn't work
  void listenToMessages() {
    _socketController?.listen(onData: (event) {
      if (event is ChatMessage) {
        _addNewMessages([event]);
      } else if (event is UserStartedTyping) {
        _addUserTypingEvent();
      } else if (event is UserStoppedTyping) {
        // _addUserStoppedTypingEvent();
        print(_chatEvents?.first);
        _chatEvents?.removeAt(0);
        print(_chatEvents?.first);
      }
      notifyListeners();
    });
  }

  void typing() {
    _socketController?.typing();
  }

  void stopTyping() {
    _socketController?.stopTyping();
  }

  Future<void> sendMessage(int currentUserID, {required String message}) async {
    var chatMessage = ChatMessage(
      content: message,
      messageType: MessageType.text,
      userId: currentUserID,
    );
    _socketController?.sendTextMessage(chatMessage);
  }

  void _addOLDMessages(List<ChatMessage> messages) {
    _chatEvents = [..._chatEvents ?? [], ...messages];
  }

  void _addNewMessages(List<ChatMessage> messages) {
    _chatEvents = [...messages, ..._chatEvents ?? []];
  }

  void _addUserTypingEvent() {
    _chatEvents = [UserStartedTyping(), ..._chatEvents ?? []];
  }

  void _addUserStoppedTypingEvent() {
    print(_chatEvents?.length);
    _chatEvents!.removeWhere((e) => e is UserStartedTyping);
    print(_chatEvents?.length);
  }
}
