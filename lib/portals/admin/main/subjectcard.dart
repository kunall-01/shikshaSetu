import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/providers/SubjectsProvider.dart';

class Subjectcard extends StatelessWidget {
  final Map<String, dynamic> mydata;
  const Subjectcard({super.key, required this.mydata});

  Future<void> submitdata(context, formData) async {
    if (formData["subjectname"] == null ||
        formData["subjectname"]?.trim().length < 3) {
      Fluttertoast.showToast(
          msg: "subjectname is Required or Invalid.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      try {
        showLoadingDialog(context);

        var apipost = {
          "subjectname": formData["subjectname"],
          "subjectcode": formData["subjectcode"],
          "descr": formData["descr"],
        };

        var response = await http.post(
          Uri.parse(AppUrl.editsubject),
          body: jsonEncode(apipost),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            var subjectcode = formData["subjectcode"];
            var editsubject = EncryptionService.decrypt(output["data"]);
            Provider.of<Subjectsprovider>(context, listen: false)
                .editsubject(subjectcode, editsubject);
            Fluttertoast.showToast(
                msg: "Subject Successfully Edited!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);

            Navigator.pop(context);
            // Future.delayed(Duration.zero, () {
            //   Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(
            //       builder: (context) => const AdminDashboardPage(),
            //     ),
            //   );
            // });
          } else {
            Fluttertoast.showToast(
                msg: output["result"],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);
          }
        } else if (response.statusCode == 401) {
          Fluttertoast.showToast(
              msg: "unable to fetch",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        } else {
          Fluttertoast.showToast(
              msg: "Something went wrong. Please try again.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        }
      } catch (exception) {
        Fluttertoast.showToast(
            msg: "error accured",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      } finally {
        hideLoadingDialog(context);
      }
    }
  }

  void _editSubject(context, mydata) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController =
            TextEditingController(text: mydata["subjectname"]);
        final codeController =
            TextEditingController(text: mydata["subjectcode"]);
        final descrController = TextEditingController(text: mydata["descr"]);
        return AlertDialog(
          title: const Text("Edit Subject"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Subject Name"),
                ),
                TextField(
                  controller: codeController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Subject Code"),
                ),
                TextField(
                  controller: descrController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                mydata["subjectname"] = nameController.text;
                mydata["subjectcode"] = codeController.text;
                mydata["descr"] = descrController.text;
                submitdata(context, mydata);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubject(BuildContext context, Map<String, dynamic> mydata) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Subject"),
        content: const Text("Are you sure you want to delete this subject?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel deletion
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color(deepseablue),
                      child: Text(
                        mydata["subjectname"]!.substring(0, 1),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    title: Text(
                      mydata["subjectname"]!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Code: ${mydata["subjectcode"]}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.date_range,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(mydata["doe"]!))}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  if (mydata["descr"]!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15.0),
                      child: Text(
                        'Description: ${mydata["descr"]}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (String choice) {
                switch (choice) {
                  case 'Edit':
                    _editSubject(context, mydata);
                    break;
                  // case 'Delete':
                  //   _deleteSubject(context, mydata);
                  //   break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'Edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  // const PopupMenuItem(
                  //   value: 'Delete',
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.delete, color: Colors.red),
                  //       SizedBox(width: 8),
                  //       Text('Delete'),
                  //     ],
                  //   ),
                  // ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
