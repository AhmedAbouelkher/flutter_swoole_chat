import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Repositories/user_repository.dart';
import 'package:flutter_swoole_chat/Models/Auth/models.dart';

import 'package:provider/provider.dart';

export 'package:provider/provider.dart';

class UsersProvider extends ChangeNotifier {
  static UsersProvider get(BuildContext context) => context.read<UsersProvider>();

  final UsersRepository _usersRepository;

  UsersProvider({
    required UsersRepository usersRepository,
  }) : _usersRepository = usersRepository;

  List<User>? _users;

  List<User>? get users => _users;

  Future<void> fetchUsers({String? search}) async {
    _users = null;
    notifyListeners();
    try {
      final _result = await _usersRepository.fetchUser(search: search);
      _users = _result.users.users;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
