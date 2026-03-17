import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/models/authconstant.dart';

class PChating extends StatefulWidget {
  final Map<String, dynamic> contact;
  final String category;

  const PChating({super.key, required this.contact, required this.category});

  @override
  State<PChating> createState() => _PChatingState();
}

class _PChatingState extends State<PChating> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController messageController = TextEditingController();
  String loginid = "";

  getuserid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    loginid = prefs.getString("userid") ?? "";
  }

  @override
  void initState() {
    super.initState();
    _getPreviousChats();
    getuserid();
  }

  Future<void> _getPreviousChats() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userid");

      String catid = widget.category == 'Parent'
          ? widget.contact['parentid']
          : widget.category == 'Tutor'
              ? widget.contact['tutorid']
              : widget.contact['id'] ?? "";
      String chattingUnicode = '$catid-${userId!}';

      var response = await http.get(
        Uri.parse(
            '${AppUrl.getChats}?chattingUnicode=$chattingUnicode&reciverid=$catid&senderid=$userId'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["output"] == 'Y') {
          var chatting = data['chatting_list'];
          setState(() {
            messages = List<Map<String, dynamic>>.from(chatting['chats']);
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load chats. Error code: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: "Error: ${exception.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<void> _sendmsg(msg) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userid");

      String catid = widget.category == 'Parent'
          ? widget.contact['parentid']
          : widget.category == 'Tutor'
              ? widget.contact['tutorid']
              : widget.contact['id'] ?? "";
      String chattingUnicode = '$catid-${userId!}';

      var apipost = {
        "sender": userId,
        "receiver": catid,
        "sendertype": "Parent",
        "receivertype": widget.category,
        "chattingunicode": chattingUnicode,
        "msg": msg,
      };

      var response = await http.post(
        Uri.parse(AppUrl.sendchatmsg),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data["result"] == 'Y') {
          _getPreviousChats();
          setState(() {
            messageController.clear();
          });
        } else {
          Fluttertoast.showToast(
            msg: "No previous chats found.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to load chats. Error code: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: "Error: ${exception.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.contact['name']} (${widget.category})'),
        backgroundColor: color(lightblack),
        foregroundColor: color(white),
        actions: [
          IconButton(
              onPressed: () {
                _getPreviousChats();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var data = messages[index];
                bool isSender = data['sender'] == loginid;

                return Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 200, // Maximum width is 200 pixels
                    ),
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              !isSender ? Colors.grey[300] : color(lightblue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['msg'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                data['date'] ?? '', // Display date if available
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: color(blue),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          _sendmsg(messageController.text);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
