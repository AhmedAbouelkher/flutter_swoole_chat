import 'dart:convert';

import 'package:flutter_swoole_chat/Helpers/functions.dart';

abstract class ChatEvent {
  const ChatEvent();
}

abstract class UserTyping extends ChatEvent {}

class UserStartedTyping extends UserTyping {
  @override
  String toString() => "UserStartedTyping()";
}

class UserStoppedTyping extends UserTyping {
  @override
  String toString() => "UserStoppedTyping()";
}

enum MessageType { text, image, audio }

class ChatMessage extends ChatEvent {
  ChatMessage({
    this.id,
    required this.content,
    required this.messageType,
    this.createdAt,
    this.chatId,
    this.userId,
    this.seen,
    this.updatedAt,
  });

  final int? id;
  final String content;
  final MessageType messageType;
  final DateTime? createdAt;
  final int? chatId;
  final int? userId;
  final DateTime? updatedAt;
  final DateTime? seen;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json["id"] == null ? null : json["id"],
        content: json["message"],
        messageType: enumFromString<MessageType>(MessageType.values, json["message_type"]),
        createdAt: DateTime.parse(json["created_at"]),
        chatId: json["chat_id"] == null ? null : json["chat_id"],
        userId: json["user_id"] == null ? null : json["user_id"],
        seen: json["seen"] == null ? null : DateTime.parse(json["seen"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );
}
