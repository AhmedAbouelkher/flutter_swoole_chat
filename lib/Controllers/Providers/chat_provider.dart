import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Repositories/chat_repository.dart';
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
  List<ChatMessage>? _chatMessages;
  List<ChatMessage>? get chatMessages => _chatMessages;
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
    _chatMessages = null;
    notifyListeners();
    try {
      var messagesResponse = await _chatRepository.fetchChatMessages(chatID: chatID);
      _chatMessages = messagesResponse.data;
      _chatMesasgesNextPageUrl = messagesResponse.nextPageUrl;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  bool _fetchMoreMessages = true;

  Future<void> fetchMoreChatMessages() async {
    if (_chatMesasgesNextPageUrl == null) return;
    if (!_fetchMoreMessages) return;
    _fetchMoreMessages = false;
    log("FETCHING MORE MESSAGES");

    try {
      var messagesResponse = await _chatRepository.fetchChatMessages(nextPageURL: messagesNextPageURL);
      _chatMessages = messagesResponse.data + (_chatMessages ?? []);
      _chatMesasgesNextPageUrl = messagesResponse.nextPageUrl;
      _fetchMoreMessages = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
