import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';
import 'package:flutter_swoole_chat/Helpers/exceptions.dart';
import 'package:flutter_swoole_chat/Screens/home/home_screen.dart';
import 'package:flutter_swoole_chat/Widgets/widget.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RoundedLoadingButtonController _btnController;
  late final GlobalKey<FormState> _formKey;

  late final TextEditingController _nameTextController;
  late final TextEditingController _emailTextController;
  late final TextEditingController _passwordTextController;

  @override
  void initState() {
    _nameTextController = TextEditingController();
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    _btnController = RoundedLoadingButtonController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CTextField(
                  controller: _nameTextController,
                  hintText: "Name",
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
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
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20.0),
                RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: _performRegister,
                  color: Colors.blue,
                  child: Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performRegister() async {
    final _provider = AuthProvider.get(context);
    try {
      final RegisterUser _user = RegisterUser(
        name: _nameTextController.text.trim(),
        email: _emailTextController.text.trim(),
        password: _passwordTextController.text.trim(),
      );
      await _provider.registerUser(user: _user);
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
