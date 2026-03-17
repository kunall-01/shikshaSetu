import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/portals/parent/chatting/p_chating.dart';

class PContactSelectionScreen extends StatefulWidget {
  final String category;

  const PContactSelectionScreen({super.key, required this.category});

  @override
  State<PContactSelectionScreen> createState() =>
      _PContactSelectionScreenState();
}

class _PContactSelectionScreenState extends State<PContactSelectionScreen> {
  List<dynamic> contacts = [];
  dynamic selectedContact; // Holds the selected contact
  var type = "tutor";
  @override
  void initState() {
    super.initState();
    _getParentAndTutorList();
  }

  Future<void> _getParentAndTutorList() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var id = prefs.getString("userid");
      var response = await http
          .get(Uri.parse('${AppUrl.parentchattinglist}?type=$type&Id=$id'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('output')) {
          setState(() {
            contacts = widget.category == 'Parent'
                ? data['output']['parents']
                : widget.category == 'Tutor'
                    ? data['output']['tutors']
                    : data['output']['admins'] ?? [];
          });
        }
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.category}'),
        centerTitle: true,
        backgroundColor: color(lightblack),
        foregroundColor: color(white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<dynamic>(
              value: selectedContact,
              decoration: InputDecoration(
                labelText: 'Choose ${widget.category}',
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: color(deepseablue),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: contacts.map<DropdownMenuItem<dynamic>>((contact) {
                return DropdownMenuItem<dynamic>(
                  value: contact,
                  child: Text(contact['name'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedContact = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: selectedContact != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PChating(
                                  contact: selectedContact,
                                  category: widget.category),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: color(deepseablue),
                      foregroundColor: color(white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0))),
                  child: const Text('Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
