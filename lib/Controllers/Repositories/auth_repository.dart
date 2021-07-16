import 'package:dio/dio.dart';

import 'package:flutter_swoole_chat/Helpers/network_constants.dart';
import 'package:flutter_swoole_chat/Helpers/shared_prefs_utils.dart';
import 'package:flutter_swoole_chat/Models/Auth/models.dart';
import 'package:flutter_swoole_chat/Helpers/exceptions.dart';

export 'package:flutter_swoole_chat/Models/Auth/models.dart';

const kUserTokenKey = "user_token_key";

class AuthRepository {
  final Dio _dio;

  AuthRepository({
    required Dio dio,
  }) : _dio = dio;

  Future<RegisterResponse> registerUser({required RegisterUser user}) async {
    try {
      var json = user.toJson();
      final _resonse = await _dio.post(
        NetworkConstants.regiserUser,
        options: Options(
          followRedirects: false,
          headers: {
            "Accept": 'application/json',
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
        data: json,
      );
      if (_resonse.statusCode == 200) {
        final _result = RegisterResponse.fromJson(_resonse.data);
        await saveUserToken(_result.accessToken);
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

  Future<RegisterResponse> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final _resonse = await _dio.post(
        NetworkConstants.loginUser,
        options: Options(
          followRedirects: false,
          headers: {
            "Accept": 'application/json',
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
        data: {
          "email": email,
          "password": password,
          "mobile_token": "NONE",
        },
      );
      if (_resonse.statusCode == 200) {
        final _result = RegisterResponse.fromJson(_resonse.data);
        await saveUserToken(_result.accessToken);
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

  Future<void> logout() async {
    try {
      final _resonse = await _dio.post(
        NetworkConstants.logout,
        options: Options(
          followRedirects: false,
          headers: {
            "Accept": 'application/json',
            "Authorization": this.userToken,
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
      );
      if (_resonse.statusCode == 200) {
        await _clearToken();
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

  Future<User> fetchUserData() async {
    try {
      final _resonse = await _dio.get(
        NetworkConstants.userData,
        options: Options(
          followRedirects: false,
          contentType: 'application/json',
          headers: {
            "Authorization": this.userToken,
          },
          validateStatus: (status) {
            if (status == null) return false;
            return status < 500;
          },
        ),
      );
      if (_resonse.statusCode == 200) {
        return User.fromJson(_resonse.data["user"]);
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

  Future<bool> saveUserToken(String token) async {
    return PreferenceUtils.instance!.saveValueWithKey<String>(kUserTokenKey, token);
  }

  String? get userToken {
    final _userToken = PreferenceUtils.instance?.getValueWithKey(kUserTokenKey, hideDebugPrint: true);
    return _userToken == null ? null : "Bearer " + _userToken;
  }

  Future<bool> _clearToken() async {
    return await PreferenceUtils.instance!.removeValueWithKey(kUserTokenKey);
  }
}
