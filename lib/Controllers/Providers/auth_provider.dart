import 'package:flutter/material.dart';

import 'package:flutter_swoole_chat/Controllers/Repositories/auth_repository.dart';
import 'package:provider/provider.dart';

export 'package:provider/provider.dart';
export 'package:flutter_swoole_chat/Controllers/Repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  static AuthProvider get(BuildContext context) => context.read<AuthProvider>();

  final AuthRepository _authRepository;
  AuthProvider({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  User? _user;
  User? get user => _user;
  int? get userID => _user?.id;

  String? get userToken => _authRepository.userToken;

  Future<void> registerUser({required RegisterUser user}) async {
    try {
      await _authRepository.registerUser(user: user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _authRepository.loginUser(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      return await _authRepository.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchUserData() async {
    try {
      await _authRepository.fetchUserData();
    } catch (e) {
      rethrow;
    }
  }
}
