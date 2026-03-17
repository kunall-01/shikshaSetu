import 'package:flutter/material.dart';

class ChatNotificationScreen extends StatelessWidget {
  const ChatNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> notifications = [
      {
        "name": "John Doe",
        "message": "Hey! How are you?",
        "time": "2m ago",
        "avatarUrl": "https://randomuser.me/api/portraits/men/1.jpg",
      },
      {
        "name": "Alice Smith",
        "message": "Let's meet at 5 PM.",
        "time": "10m ago",
        "avatarUrl": "https://randomuser.me/api/portraits/women/2.jpg",
      },
      {
        "name": "David Johnson",
        "message": "Check out this cool photo!",
        "time": "30m ago",
        "avatarUrl": "https://randomuser.me/api/portraits/men/3.jpg",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Notifications"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var chat = notifications[index];
          return ChatNotification(
            senderName: chat["name"]!,
            message: chat["message"]!,
            time: chat["time"]!,
            avatarUrl: chat["avatarUrl"]!,
            onTap: () {
              // Navigate to chat screen (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Opening chat with ${chat['name']}")),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatNotification extends StatelessWidget {
  final String senderName;
  final String message;
  final String time;
  final String avatarUrl;
  final VoidCallback onTap;

  const ChatNotification({
    super.key,
    required this.senderName,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
