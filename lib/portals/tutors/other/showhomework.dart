import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/tutors/other/addhomework.dart';

class Showhomework extends StatefulWidget {
  final String stdid;
  const Showhomework({super.key, required this.stdid});

  @override
  // ignore: library_private_types_in_public_api
  _ShowhomeworkState createState() => _ShowhomeworkState();
}

class _ShowhomeworkState extends State<Showhomework> {
  List<dynamic> userData = [];
  bool isLoading = true;

  Future<void> gethomeworkdata() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");
      var stdid = widget.stdid;

      if (tutorid == null) {
        Fluttertoast.showToast(
          msg: "User data not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      var response = await http.get(
        Uri.parse(AppUrl.gethomeworkofstudent).replace(
          queryParameters: {"tutorid": tutorid, "stdid": stdid},
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];

        if (output['result'] == 'Y') {
          setState(() {
            userData = output['data'];
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: output['result'] ?? 'No records found',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          setState(() {
            isLoading = false;
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
    gethomeworkdata();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : userData.isEmpty
            ? const Center(child: Text("No homework records found"))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: userData.length,
                itemBuilder: (context, index) {
                  final entry = userData[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subject: ${entry['subjectcode']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: color(blue)),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Addhomework(
                                        stdid: entry['stdid'],
                                        parents: entry,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Title: ${entry['topic']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Homework:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry['homework'] ?? 'No homework provided.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Submission Date: ${entry['submissiondate']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
