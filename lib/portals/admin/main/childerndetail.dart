import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';
import 'package:shikshasetutution/portals/admin/providers/ParentchildProvider.dart';
import 'package:http/http.dart' as http;

class ChildrenDetail extends StatefulWidget {
  final Map<String, dynamic> subject;

  const ChildrenDetail({super.key, required this.subject});

  @override
  State<ChildrenDetail> createState() => _ChildrenDetailState();
}

class _ChildrenDetailState extends State<ChildrenDetail> {
  String ImageUrl = "";

  Future<void> submitdata(context, formData) async {
    if (formData["name"] == null || formData["name"]?.trim().length < 3) {
      Fluttertoast.showToast(
          msg: "Name is Required or Invalid.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["age"] == null || formData["age"]?.trim().length <= 0) {
      Fluttertoast.showToast(
          msg: "Age is Required or Invalid.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["standard"] == null ||
        formData["standard"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Address is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["gender"] == null ||
        formData["gender"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Gender is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (!["Male", "Female", "Other"]
        .contains(formData["gender"]!.trim())) {
      Fluttertoast.showToast(
          msg: "Invalid Gender. It must be 'Male', 'Female', or 'Other'.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      try {
        showLoadingDialog(context);

        var apipost = {
          "stdid": formData["stdid"],
          "parentid": formData["parentid"],
          "name": formData["name"],
          "standard": formData["standard"],
          "age": formData["age"],
          "gender": formData["gender"],
          "descr": formData["descr"],
        };
        var response = await http.post(
          Uri.parse(AppUrl.editstudent),
          body: jsonEncode(apipost),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            var parentid = formData["parentid"];
            var edittutor = output["data"][0];
            Provider.of<Parentchildprovider>(context, listen: false)
                .editparentchilds(parentid, edittutor);
            Fluttertoast.showToast(
                msg: "Student Successfully added!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);

            Navigator.pop(context);
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardPage(),
                ),
              );
            });
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
        final nameController = TextEditingController(text: mydata["name"]);
        final ageController = TextEditingController(text: mydata["age"]);
        final stdController = TextEditingController(text: mydata["standard"]);
        final genderController = TextEditingController(text: mydata["gender"]);
        return AlertDialog(
          title: const Text("Edit Child"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: "Age"),
                ),
                TextField(
                  controller: stdController,
                  decoration: const InputDecoration(labelText: "Standard"),
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: "Gender"),
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
                mydata["name"] = nameController.text;
                mydata["age"] = ageController.text;
                mydata["standard"] = stdController.text;
                mydata["gender"] = genderController.text;
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
        title: const Text("Delete Child"),
        content: const Text("Are you sure you want to delete this child?"),
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

  Future<void> getimage() async {
    String url =
        '${AppUrl.stdprofilephoto}${widget.subject["stdid"]}-sprofile.jpg';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          ImageUrl = url;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error loading profile photo.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    }
  }

  @override
  void initState() {
    getimage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child Details"),
        backgroundColor: color(blue),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () => {_editSubject(context, widget.subject)},
              icon: Icon(Icons.edit, color: color(deepseablue))),
          // IconButton(
          //     onPressed: () => {_deleteSubject(context, subject)},
          //     icon: Icon(
          //       Icons.delete,
          //       color: color(deepseablue),
          //     ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section with Network Image
              Center(
                child: ImageUrl != ""
                    ? CircleAvatar(
                        radius: 50,
                        backgroundColor: color(blue),
                        backgroundImage: NetworkImage(
                          '${AppUrl.stdprofilephoto}${widget.subject["stdid"]}-sprofile.jpg',
                        ),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: color(blue),
                        child: widget.subject['name'] != null &&
                                widget.subject['name'].isNotEmpty
                            ? Text(
                                widget.subject['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
              ),
              const SizedBox(height: 16),

              _buildNameIdCard(),
              const SizedBox(height: 20),

              // Combined Details Section in a single card
              _buildDetailCard(
                "Details",
                {
                  "Age": widget.subject['age'],
                  "Standard": widget.subject['standard'],
                  "Gender": widget.subject['gender'],
                  "Date of Enrollment": widget.subject['doe'],
                },
              ),
              const SizedBox(height: 10),

              // Tutor Information
              if (widget.subject['tutors'].isNotEmpty)
                _buildTutorSection(widget.subject['tutors']),

              // Homework & Exam Marks
              // _buildHomeworkSection(),
              // _buildExamMarksSection()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameIdCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: color(lightblue),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name
              Text(
                widget.subject['name'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color(deepseablue),
                ),
              ),
              const SizedBox(height: 8),
              // ID
              Text(
                "ID: ${widget.subject['stdid']}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Subtle color for the ID
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a detail card with multiple details
  Widget _buildDetailCard(String title, Map<String, String> details) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title of the section
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color(blue),
              ),
            ),
            const SizedBox(height: 8),
            // Iterate over the details map and display each detail
            ...details.entries.map<Widget>((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to display tutor information
  Widget _buildTutorSection(List tutors) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tutors",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color(blue),
              ),
            ),
            const SizedBox(height: 8),
            ...tutors.map<Widget>((tutor) {
              return Row(
                children: [
                  Icon(Icons.person, size: 20, color: color(blue)),
                  const SizedBox(width: 8),
                  Text(
                    tutor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Subject: ${tutor['subject']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

// Helper method to display homework
  Widget _buildHomeworkSection() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Homework title
              Text(
                "Homework",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color(blue), // Accent color for Homework section
                ),
              ),
              const SizedBox(height: 8),
              // Homework list or empty message
              if (widget.subject['homework'].isEmpty)
                Text(
                  "No homework assigned.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                )
              else
                ...widget.subject['homework'].map<Widget>((homework) {
                  return Text(
                    homework,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to display exam marks
  Widget _buildExamMarksSection() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam Marks title
              const Text(
                "Exam Marks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Accent color for Exam Marks section
                ),
              ),
              const SizedBox(height: 8),
              // Exam marks list or empty message
              if (widget.subject['exammarks'].isEmpty)
                Text(
                  "No exam marks available.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                )
              else
                ...widget.subject['exammarks'].map<Widget>((exammark) {
                  return Text(
                    "Mark: $exammark",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
