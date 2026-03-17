import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';
import 'package:shikshasetutution/portals/admin/main/assignedstudent.dart';
import 'package:shikshasetutution/portals/admin/providers/TutorProvider.dart';

class Tutordetail extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const Tutordetail({super.key, required this.tutor});

  Future<void> delete(context, formdata) async {
    try {
      showLoadingDialog(context);
      var tutorid = formdata["tutorid"];
      var response = await http.post(
        Uri.parse(AppUrl.assignstudentdelete),
        body: jsonEncode(formdata),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse;
        if (output["result"] == 'Y') {
          var tdata = EncryptionService.decrypt(output["data"]);
          Provider.of<TutorProvider>(context, listen: false)
              .editTutor(tutorid, tdata);

          Fluttertoast.showToast(
              msg: "Student successfully delete!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);

          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const AdminDashboardPage(),
              ),
            );
          });
        } else {
          Fluttertoast.showToast(
              msg: output["message"],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('${tutor["name"]} Detail'),
        centerTitle: true,
        backgroundColor: color(blue),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: color(blue),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: Image.network(
                            '${AppUrl.tutorprofilephoto}${tutor["tutorid"]}-profile.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to the first letter of the name if image fails to load
                              return Center(
                                child: Text(
                                  tutor["name"][0]
                                      .toUpperCase(), // Displaying the first letter
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tutor["name"],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "⭐ ${tutor["rating"]} Rating",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  buildDetailCard(
                    context,
                    title: "Contact Info",
                    icon: Icons.phone,
                    details: [
                      "Mobile: ${tutor["mobileno"]}",
                      "Address: ${tutor["address"]}",
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDetailCard(
                    context,
                    title: "Personal Info",
                    icon: Icons.person,
                    details: [
                      "Gender: ${tutor["gender"]}",
                      "Aadhar No: ${tutor["aadharno"]}",
                      "Date of Enrollment: ${tutor["doe"]}",
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDetailCard(
                    context,
                    title: "Description",
                    icon: Icons.description,
                    details: [
                      tutor["descr"] != ""
                          ? tutor["descr"]
                          : "No description provided.",
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDetailCard(
                    context,
                    title: "Subjects",
                    icon: Icons.book,
                    details: tutor["subjects"]
                        .map<String>((subject) =>
                            "${subject["subjectname"]} (${subject["subjectcode"]})")
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  buildDetailCardstd(context,
                      title: "Students",
                      icon: Icons.book,
                      details: tutor["students"].length > 0
                          ? tutor["students"]
                              .map<String>((data) =>
                                  "${capitalizeFirstLetter(data["stdname"])} (${data["stdid"]} / ${data["subjectcode"]})")
                              .toList()
                          : ["No students have been assigned yet."],
                      onDelete: (detail) {
                    Map<String, String>? result = extractmethod(detail);
                    if (result != null) {
                      // print('Student ID: ${result['stdId']}');
                      // print('Subject Code: ${result['subjectCode']}');
                      // print('Subject Code: ${tutor["tutorid"]}');
                      var t = {
                        "stdid": result['stdId'],
                        "tutorid": tutor['tutorid'],
                        "subjectcode": result['subjectCode'],
                      };
                      delete(context, t);
                    }
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Method for Detail Cards
  Widget buildDetailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> details,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color(blue), size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color(blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildDetailCardstd(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> details,
    required Function(String) onDelete,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color(blue), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color(blue),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Assignedstudent(
                          tutorid: tutor["tutorid"],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color(blue), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Assign Student',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color(white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Details List with Delete Button
            ...details.map((detail) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Detail Text
                      Expanded(
                        child: Text(
                          detail,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),

                      detail == 'No students have been assigned yet.'
                          ? Container()
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(
                                  context, detail, onDelete),
                            ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Function to show confirmation dialog
  void _showDeleteConfirmationDialog(
      BuildContext context, String detail, Function(String) onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete '$detail'?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(detail);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
