import 'package:dio/dio.dart';
import 'package:flutter_swoole_chat/Helpers/exceptions.dart';
import 'package:flutter_swoole_chat/Helpers/network_constants.dart';
import 'package:flutter_swoole_chat/Models/user_response.dart';

import 'auth_repository.dart';

class UsersRepository {
  final Dio _dio;
  final AuthRepository _authRepository;

  UsersRepository({
    required Dio dio,
    required AuthRepository authRepository,
  })   : _dio = dio,
        _authRepository = authRepository;

  Future<UsersResponse> fetchUser({String? search}) async {
    try {
      final _resonse = await _dio.get(
        NetworkConstants.users,
        options: Options(
          followRedirects: false,
          headers: {
            "Accept": 'application/json',
            "Authorization": _authRepository.userToken,
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
        queryParameters: search != null ? {"search": search} : null,
      );
      if (_resonse.statusCode == 200) {
        final _result = UsersResponse.fromJson(_resonse.data);
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
}
