import 'package:flutter/material.dart';

import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/chat_provider.dart';
import 'package:flutter_swoole_chat/Screens/auth/auth_screen.dart';
import 'package:flutter_swoole_chat/Widgets/widget.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ChatProvider.get(context).fetchChats();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: KeyboardDismisser(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: _performLogout,
              icon: Icon(Icons.login_outlined),
            ),
            bottom: AppBarButtom(
              child: Container(
                color: Colors.white,
                child: CTextField(
                  hintText: "Search users...",
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Selector<ChatProvider, List<Chat>?>(
              selector: (_, provider) => provider.chats,
              builder: (context, chats, _) {
                if (chats == null) {
                  return Center(child: CircularProgressIndicator());
                }

                if (chats.isEmpty) {
                  return Center(child: Text("Empty"));
                }
                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (context, index) => Divider(
                    indent: _size.width * 0.15,
                    height: 0.0,
                  ),
                  itemBuilder: (context, index) {
                    final _chat = chats[index];
                    final _latestMessage = _chat.latestMassage;
                    return ListTile(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: _chat)));
                      },
                      leading: CircleAvatar(
                        child: Text(_chat.user1.initials),
                      ),
                      title: Text(_chat.user1.name),
                      subtitle: _buildChatListTileSubtitle(_latestMessage),
                      trailing: Icon(Icons.keyboard_arrow_right_outlined),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildChatListTileSubtitle(ChatMessage? message) {
    if (message == null) return null;
    switch (message.messageType) {
      case MessageType.text:
        return ClippedText(message.content, maxLength: 30);
      case MessageType.audio:
        return Text("🎤  Voicenote attachment");
      case MessageType.image:
        return Text("📷  Photo attachment");
    }
  }

  Future<void> _performLogout() async {
    final _result = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Are you sure?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
    if (_result == null) return;
    try {
      await AuthProvider.get(context).logout();
      Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

class ClippedText extends StatelessWidget {
  final String title;
  final int maxLength;
  final TextStyle? style;

  const ClippedText(
    this.title, {
    Key? key,
    this.maxLength = 50,
    this.style,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (title.length > maxLength) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: title.substring(0, maxLength)),
            TextSpan(text: "..."),
          ],
          style: style,
        ),
      );
    }
    return Text(title, style: style);
  }
}

class AppBarButtom extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  const AppBarButtom({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  Size get preferredSize => Size.fromHeight(50);
}
