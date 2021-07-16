import 'package:flutter_swoole_chat/Models/home_chat_models.dart';

import 'chat_events.dart';

class MessagesResponse {
  MessagesResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  final int currentPage;
  final List<ChatMessage> data;
  final String firstPageUrl;
  final int? from;
  final int? lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  factory MessagesResponse.fromJson(Map<String, dynamic> rawJSON) {
    final json = rawJSON["messages"];
    return MessagesResponse(
      currentPage: json["current_page"],
      data: List<ChatMessage>.from(json["data"].map((x) => ChatMessage.fromJson(x))),
      firstPageUrl: json["first_page_url"],
      from: json["from"] == null ? null : json["from"],
      lastPage: json["last_page"],
      lastPageUrl: json["last_page_url"],
      path: json["path"],
      perPage: json["per_page"],
      to: json["to"],
      total: json["total"],
      nextPageUrl: json["next_page_url"] == null ? null : json["next_page_url"],
      prevPageUrl: json["prev_page_url"] == null ? null : json["prev_page_url"],
    );
  }
}
