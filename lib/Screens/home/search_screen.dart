import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/user_provider.dart';
import 'package:flutter_swoole_chat/Models/home_chat_models.dart';
import 'package:flutter_swoole_chat/Widgets/widget.dart';

import 'chat_screen.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      try {
        UsersProvider.get(context).fetchUsers();
      } on Exception catch (e) {
        log(e.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthProvider.get(context).user;
    return Scaffold(
      appBar: AppBar(
        title: AppBarButtom(
          child: Container(
            color: Colors.white,
            child: CTextField(
              hintText: "Search users...",
              inputDecoration: InputDecoration(border: InputBorder.none),
              onChanged: (value) {
                UsersProvider.get(context).fetchUsers(search: value);
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<UsersProvider>(
          builder: (context, provider, _) {
            final _users = provider.users;
            if (_users == null) return Center(child: CircularProgressIndicator.adaptive());
            if (_users.isEmpty) return SizedBox();
            return ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (context, index) => Divider(height: 0),
              itemBuilder: (context, index) {
                final _user = _users[index];
                return ListTile(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          toUserId: _user.id,
                        ),
                      ),
                    );
                  },
                  enabled: currentUser?.id != _user.id,
                  leading: CircleAvatar(child: Text(_user.initials)),
                  title: Text(_user.name),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
