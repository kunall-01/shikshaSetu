import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:intl/intl.dart';

class Childmarks extends StatefulWidget {
  final String stdid;
  const Childmarks({super.key, required this.stdid});

  @override
  // ignore: library_private_types_in_public_api
  _ChildmarksState createState() => _ChildmarksState();
}

class _ChildmarksState extends State<Childmarks> {
  List<dynamic> userData = [];
  bool isLoading = true;

  // Function to get marks data from the API
  Future<void> getmarksdata() async {
    try {
      var stdid = widget.stdid;

      var response = await http.get(
        Uri.parse(AppUrl.getmarksbytutorandstudentinparent).replace(
          queryParameters: {"stdid": stdid},
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];

        // Handle the case where there are no records
        if (output['result'] == 'Y') {
          setState(() {
            userData = output['data'];
            isLoading = false;
          });
        } else {
          // Fluttertoast.showToast(
          //   msg: output['result'] ?? 'No records found',
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.CENTER,
          // );
          setState(() {
            isLoading = false; // Stop loading if no records are found
          });
        }
      } else {
        Fluttertoast.showToast(
          msg: "Error: Failed to load data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getmarksdata(); // Fetch the marks data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator()) // Show loading indicator
        : userData.isEmpty
            ? const Center(
                child: Text(
                    "No records found")) // Show message when no records found
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: userData.length, // Display the user data
                  itemBuilder: (context, index) {
                    final entry = userData[index];
                    return Card(
                      elevation:
                          8, // Slightly higher elevation for a more modern look
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // More rounded corners
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Column for the main content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subject: ${entry['subjectcode']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Marks Obtained: ${entry['marks']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Total Marks: ${entry['totalmarks']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Exam: ${entry['examname']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(entry['doe']))}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}
