class RegisterResponse {
  RegisterResponse({
    required this.accessToken,
    required this.user,
  });

  final String accessToken;
  final User user;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        accessToken: json["access_token"],
        user: User.fromJson(json["user"]),
      );
}

class User {
  User({
    required this.id,
    required this.name,
    this.email,
    this.updatedAt,
    this.createdAt,
    this.imagePath,
    this.image,
  });

  final int id;
  final String name;
  final String? email;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String? imagePath;
  final String? image;

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    return User(
      id: json["id"],
      name: json["name"],
      image: json["image"] == null ? null : json["image"],
      imagePath: json["image_path"] == null ? null : json["image_path"],
      email: json["email"] == null ? null : json["email"],
      updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );
  }

  String get initials {
    var _splittedName = name.split(" ");
    final _firstInitial = _splittedName.first.split("").first;
    final _lastInitial = _splittedName.last.split("").first;
    return _firstInitial + _lastInitial;
  }
}

class RegisterUser {
  RegisterUser({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "password_confirmation": password,
        "password": password,
        "mobile_token": "NONE",
      };
}
