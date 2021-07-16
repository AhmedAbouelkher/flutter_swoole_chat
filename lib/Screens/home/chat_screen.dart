import 'package:flutter/material.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';

import 'package:flutter_swoole_chat/Controllers/Providers/chat_provider.dart';
import 'package:flutter_swoole_chat/Widgets/chat_bubbles.dart';
import 'package:flutter_swoole_chat/Widgets/widget.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  const ChatScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ScrollController _scrollController;
  int _userID = -1;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        _onScroll(_scrollController, () {
          ChatProvider.get(context).fetchMoreChatMessages();
        });
      });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ChatProvider.get(context).fetchChatMessages(chatID: widget.chat.id);
      _userID = AuthProvider.get(context).userID ?? -1;
    });
    super.initState();
  }

  void _onScroll(ScrollController controller, VoidCallback? trigger) {
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
    if (maxScroll - currentScroll <= 20) {
      trigger?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chat.user1.name),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Selector<ChatProvider, List<ChatMessage>?>(
                  selector: (_, provider) => provider.chatMessages,
                  builder: (context, messages, _) {
                    if (messages == null) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (messages.isEmpty) {
                      return Center(child: Text("Start sending messages to ${widget.chat.user2.name}..."));
                    }

                    final provider = ChatProvider.get(context);
                    return ListView.separated(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
                      itemCount: provider.hasNextPage ? messages.length + 1 : messages.length,
                      separatorBuilder: (context, index) => SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        if (index >= messages.length) return Center(child: CircularProgressIndicator());
                        final _message = messages[index];
                        final _type = _bubbleType(_message.userId!, _userID);

                        if (_message.messageType == MessageType.text) {
                          return TextBubble(
                            message: _message,
                            type: _type,
                          );
                        }

                        return Text(_message.content);
                      },
                    );
                  },
                ),
              ),
              Positioned.fill(
                top: null,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Expanded(
                        child: CTextField(
                          hintText: "Type your message...",
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  BubbleType _bubbleType(int userID, int currentUserID) {
    return userID == currentUserID ? BubbleType.sendBubble : BubbleType.receiverBubble;
  }
}
