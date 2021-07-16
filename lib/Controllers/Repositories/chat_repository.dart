import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';

import 'package:flutter_swoole_chat/Helpers/network_constants.dart';
import 'package:flutter_swoole_chat/Helpers/exceptions.dart';
import 'package:flutter_swoole_chat/Models/chat_messages_models.dart';
import 'package:flutter_swoole_chat/Models/home_chat_models.dart';
import '../../Models/chat_events.dart';

export 'package:flutter_swoole_chat/Models/chat_messages_models.dart';

export 'package:flutter_swoole_chat/Models/home_chat_models.dart';
export '../../Models/chat_events.dart';

const kUserTokenKey = "user_token_key";

class ChatRepository {
  final Dio _dio;
  final AuthRepository _authRepository;

  ChatRepository({
    required Dio dio,
    required AuthRepository authRepository,
  })   : _dio = dio,
        _authRepository = authRepository;

  Future<Chats> fetchChats() async {
    try {
      final _resonse = await _dio.get(
        NetworkConstants.chatAPI,
        options: Options(
          followRedirects: false,
          headers: {
            'Accept': 'application/json',
            "Authorization": _authRepository.userToken,
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
      );
      if (_resonse.statusCode == 200) {
        final _result = Chats.fromJson(_resonse.data);
        return _result;
      } else {
        return Future.error(
          APIReqestError(
            body: _resonse.data,
            statusCode: _resonse.statusCode,
            message: _resonse.statusMessage,
          ),
        );
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<MessagesResponse> fetchChatMessages({int? chatID, String? nextPageURL}) async {
    final _path = nextPageURL ?? NetworkConstants.chatAPI + chatID.toString();
    try {
      final _resonse = await _dio.get(
        _path,
        options: Options(
          followRedirects: false,
          headers: {
            'Accept': 'application/json',
            "Authorization": _authRepository.userToken,
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
      );
      if (_resonse.statusCode == 200) {
        final _result = MessagesResponse.fromJson(_resonse.data);
        return _result;
      } else {
        return Future.error(
          APIReqestError(
            body: _resonse.data,
            statusCode: _resonse.statusCode,
            message: _resonse.statusMessage,
          ),
        );
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<void> sendMessageFile({
    required File file,
    required int chatID,
    MessageType type = MessageType.image,
  }) async {}
}
