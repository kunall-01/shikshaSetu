import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:intl/intl.dart';
import 'package:shikshasetutution/portals/tutors/other/addmarks.dart';

class Showmarks extends StatefulWidget {
  final String stdid;
  const Showmarks({super.key, required this.stdid});

  @override
  // ignore: library_private_types_in_public_api
  _ShowmarksState createState() => _ShowmarksState();
}

class _ShowmarksState extends State<Showmarks> {
  List<dynamic> userData = [];
  bool isLoading = true;

  Future<void> getmarksdata() async {
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
        Uri.parse(AppUrl.getmarksbytutorandstudent).replace(
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
    getmarksdata();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : userData.isEmpty
            ? const Center(child: Text("No records found"))
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: userData.length,
                  itemBuilder: (context, index) {
                    final entry = userData[index];
                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                  const SizedBox(height: 8),
                                  Text('Student ID: ${entry['stdid']}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54)),
                                  Text('Marks Obtained: ${entry['marks']}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54)),
                                  Text('Total Marks: ${entry['totalmarks']}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54)),
                                  Text('Exam: ${entry['examname']}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54)),
                                  Text(
                                    'Exam Date:  ${entry['examdate'] ?? DateFormat('dd-MM-yyyy').format(DateTime.parse(entry['doe']))}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: color(blue)),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Addmarks(
                                        stdid: entry['stdid'],
                                        editmarks: entry)));
                              },
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
