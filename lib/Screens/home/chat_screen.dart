import 'package:flutter/material.dart';

import 'package:flutter_swoole_chat/Controllers/Providers/auth_provider.dart';
import 'package:flutter_swoole_chat/Controllers/Providers/chat_provider.dart';
import 'package:flutter_swoole_chat/Widgets/chat_bubbles.dart';
import 'package:flutter_swoole_chat/Widgets/widget.dart';

class ChatScreen extends StatefulWidget {
  final String? toUserName;
  final int? chatId;
  final int? toUserId;

  const ChatScreen({
    Key? key,
    this.toUserName,
    this.chatId,
    this.toUserId,
  })  : assert(toUserId == null || chatId == null),
        super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _textEditingController;
  int _currentUserID = -1;
  ChatProvider? _chatProvider;

  bool _isTextFieldHasContentYet = false;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _scrollController = ScrollController()
      ..addListener(() {
        _onScroll(_scrollController, () {
          ChatProvider.get(context).fetchMoreChatMessages();
        });
      });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _chatProvider = ChatProvider.get(context);

      if (widget.chatId != null) _chatProvider!.fetchChatMessages(chatID: widget.chatId!);
      _currentUserID = AuthProvider.get(context).userID;

      _chatProvider!.joinChat(widget.chatId, widget.toUserId);
      // ignore: invalid_use_of_visible_for_testing_member
      _chatProvider!.socketController?.joinedChat = Chat(id: widget.chatId);
      _chatProvider!.listenToMessages();

      //Start listening to the text editing controller
      _textEditingController.addListener(() {
        final _text = _textEditingController.text.trim();

        if (_text.isEmpty) {
          _chatProvider!.stopTyping();
          _isTextFieldHasContentYet = false;
        } else {
          if (_isTextFieldHasContentYet) return;
          _chatProvider!.typing();
          _isTextFieldHasContentYet = true;
        }
      });
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
  void dispose() {
    _chatProvider!.leaveChat();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.toUserName ?? ""),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.ac_unit),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Selector<ChatProvider, List<ChatEvent>?>(
                  selector: (_, provider) => provider.chatEvents,
                  builder: (context, events, _) {
                    if (widget.chatId == null) return _buildFirstTimeGreeting();
                    if (events == null) return Center(child: CircularProgressIndicator());
                    if (events.isEmpty) return _buildFirstTimeGreeting();

                    final provider = ChatProvider.get(context);
                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: provider.hasNextPage ? events.length + 1 : events.length,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
                      separatorBuilder: (context, index) => SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        if (index >= events.length) return Center(child: CircularProgressIndicator());
                        final _event = events[index];

                        if (_event is ChatMessage) {
                          final _message = _event;
                          final _type = _bubbleType(_message.userId ?? -1, _currentUserID);
                          if (_message.messageType == MessageType.text) {
                            return TextBubble(
                              message: _message,
                              type: _type,
                            );
                          }

                          return Text(_message.content);
                        } else if (_event is UserStartedTyping) {
                          print("STARTED TYPING");
                          return UserTypingBubble();
                        }

                        return SizedBox();
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
                          textInputType: TextInputType.multiline,
                          maxLines: 4,
                          controller: _textEditingController,
                          hintText: "Type your message...",
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          ChatProvider.get(context).sendMessage(
                            _currentUserID,
                            message: _textEditingController.text.trim(),
                          );
                          _textEditingController.clear();
                        },
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

  Center _buildFirstTimeGreeting() => Center(child: Text("Start sending messages to ${widget.toUserName ?? ""}..."));

  BubbleType _bubbleType(int userID, int currentUserID) {
    return userID == currentUserID ? BubbleType.sendBubble : BubbleType.receiverBubble;
  }
}
