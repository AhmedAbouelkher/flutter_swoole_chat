import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';
import 'package:flutter_swoole_chat/Helpers/exceptions.dart';
import 'package:flutter_swoole_chat/Screens/home/home_screen.dart';
import 'package:flutter_swoole_chat/Widgets/widget.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  late final TextEditingController _emailTextController;
  late final TextEditingController _passwordTextController;

  @override
  void initState() {
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              CTextField(
                controller: _emailTextController,
                hintText: "Email",
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              CTextField(
                controller: _passwordTextController,
                hintText: "Password",
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.go,
              ),
              SizedBox(height: 20.0),
              RoundedLoadingButton(
                controller: _btnController,
                onPressed: _performLogin,
                color: Colors.blue,
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performLogin() async {
    final _provider = AuthProvider.get(context);
    try {
      await _provider.login(
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );
      _btnController.success();
      print("GO HOME");

      Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      _btnController.error();
      setState(() {});
    } finally {
      Future.delayed(Duration(milliseconds: 1500), _btnController.reset);
    }
  }
}
