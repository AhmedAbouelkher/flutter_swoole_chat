import 'Auth/models.dart';
import 'chat_events.dart';

class Chats {
  Chats({
    required this.data,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.basePageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  final List<Chat> data;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String basePageUrl;
  final String? nextPageUrl;
  final String? prevPageUrl;

  factory Chats.fromJson(Map<String, dynamic> rawJSON) {
    final json = rawJSON["chats"];
    return Chats(
      data: List<Chat>.from(json["data"].map((x) => Chat.fromJson(x))),
      total: json["total"] == null ? null : json["total"],
      perPage: json["per_page"] == null ? null : json["per_page"],
      currentPage: json["current_page"] == null ? null : json["current_page"],
      lastPage: json["last_page"] == null ? null : json["last_page"],
      basePageUrl: json["base_page_url"] == null ? null : json["base_page_url"],
      nextPageUrl: json["next_page_url"] == null ? null : json["next_page_url"],
      prevPageUrl: json["prev_page_url"] == null ? null : json["prev_page_url"],
    );
  }
}

class Chat {
  Chat({
    this.id,
    this.user,
    this.latestMassage,
  });

  final int? id;
  final User? user;
  final ChatMessage? latestMassage;

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"] == null ? null : json["id"],
        user: User.fromJson(json["user"]),
        latestMassage: json["latest_massage"] == null ? null : ChatMessage.fromJson(json["latest_massage"]),
      );

  @override
  String toString() => 'Chat(id: $id, user: $user, latestMassage: $latestMassage)';
}
