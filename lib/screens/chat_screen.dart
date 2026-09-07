import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:day11/service/gemini_api.dart';
import 'package:flutter/material.dart';

const _primaryColor = Color(0xFFE8734A);
const _backgroundColor = Color(0xFFFFF8F2);
const _botBubbleColor = Colors.white;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatUser user1 = ChatUser(id: '1', firstName: 'me');
  final ChatUser bot = ChatUser(id: '2', firstName: 'Whisk');

  List<ChatMessage> messagesList = [];
  bool isBotTyping = false;

  @override
  void initState() {
    super.initState();
    messagesList.add(
      ChatMessage(
        user: bot,
        createdAt: DateTime.now(),
        text:
            "Hi! I'm your recipe assistant 🍳\nTell me what meal you're making "
            "(breakfast, lunch, dinner, or snack) and what ingredients you have, "
            "and I'll suggest something to cook.",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 8),
            Text('Whisk'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: DashChat(
        currentUser: user1,
        messages: messagesList,
        typingUsers: isBotTyping ? [bot] : [],
        messageOptions: MessageOptions(
          containerColor: _botBubbleColor,
          currentUserContainerColor: _primaryColor,
          textColor: Colors.black87,
          currentUserTextColor: Colors.white,
          borderRadius: 16,
          showTime: true,
          avatarBuilder: (chatUser, onPressAvatar, onLongPressAvatar) {
            if (chatUser.id != bot.id) return SizedBox(width: 0);
            return CircleAvatar(
              radius: 16,
              backgroundColor: _primaryColor,
              child: Icon(Icons.restaurant_menu, color: Colors.white, size: 16),
            );
          },
        ),
        inputOptions: InputOptions(
          alwaysShowSend: true,
          inputDecoration: InputDecoration(
            hintText: "What are you cooking today?",
            filled: true,
            fillColor: Colors.white,
            contentPadding:
               EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          sendButtonBuilder: (send) => IconButton(
            icon: Icon(Icons.send_rounded, color: _primaryColor),
            onPressed: send,
          ),
        ),
        onSend: (ChatMessage message) async {
          setState(() {
            messagesList.insert(0, message);
            isBotTyping = true;
          });

          final history = messagesList.reversed
              .map((m) => {
                    "role": m.user.id == user1.id ? "user" : "model",
                    "text": m.text,
                  })
              .toList();

          final botReply = await GeminiApi().SendRequest(history);

          if (!mounted) return;
          setState(() {
            isBotTyping = false;
            messagesList.insert(
              0,
              ChatMessage(
                user: bot,
                createdAt: DateTime.now(),
                text: botReply,
              ),
            );
          });
        },
        ),
      ),
    );
  }
}
