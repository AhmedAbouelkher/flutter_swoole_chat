import 'Auth/models.dart';

class UsersResponse {
  UsersResponse({
    required this.users,
  });

  final Users users;

  factory UsersResponse.fromJson(Map<String, dynamic> json) => UsersResponse(
        users: Users.fromJson(json["users"]),
      );
}

class Users {
  Users({
    this.currentPage,
    required this.users,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  final List<User> users;
  final int? currentPage;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        currentPage: json["current_page"],
        users: List<User>.from(json["data"].map((x) => User.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );
}
