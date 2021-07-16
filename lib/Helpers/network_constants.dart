import 'package:flutter/material.dart';

class NetworkConstants {
  static const _url = "https://flutterchat.ga/api/";
  static const _authAPI = _url + "auth/";
  static const chatAPI = _url + "chats/";

  static const regiserUser = _authAPI + "register";
  static const loginUser = _authAPI + "login";
  static const updateUser = _authAPI + "UpdateUser";
  static const logout = _authAPI + "logout";
  static const userData = _authAPI + "user";

  static const socketURL = "wss://flutterchat.ga:6002";
}
