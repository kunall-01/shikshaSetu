import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/components/widgets/Textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/components/widgets/dropdownfield.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/tutors/other/tstudentdetail.dart';

class Addmarks extends StatefulWidget {
  final String stdid;
  final Map<String, dynamic>? editmarks;
  const Addmarks({super.key, required this.stdid, this.editmarks});

  @override
  // ignore: library_private_types_in_public_api
  _AddmarksState createState() => _AddmarksState();
}

class _AddmarksState extends State<Addmarks> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'addmarkskey');

  TextEditingController examname = TextEditingController();

  TextEditingController marks = TextEditingController();
  TextEditingController totalmarks = TextEditingController();
  TextEditingController examdate = TextEditingController();
  String? selectedValue2;
  List<Map<String, dynamic>> dropdown2Options = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchSubjects(context));

    if (widget.editmarks != null) {
      examname = TextEditingController(text: widget.editmarks!["examname"]);
      marks = TextEditingController(text: widget.editmarks!["marks"]);
      totalmarks = TextEditingController(text: widget.editmarks!["totalmarks"]);
      examdate = TextEditingController(text: widget.editmarks!["examdate"]);
      selectedValue2 = widget.editmarks!["subjectcode"];
    }
  }

  Future<void> addmarks(context, Map<String, dynamic> formData) async {
    if (formData["examname"] == null || formData["examname"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Exam Name is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["subjectcode"] == null || formData["subjectcode"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Subject Code is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["marks"] == null || formData["marks"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Marks are required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["totalmarks"] == null || formData["totalmarks"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Total Marks are required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["examdate"] == null || formData["examdate"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Exam Date are required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");

      formData['stdid'] = widget.stdid;
      formData['tutorid'] = tutorid;

      // Make the POST request
      var response = await http.post(
        Uri.parse(AppUrl.trAddmarks),
        body: jsonEncode(formData),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];
        if (output["result"] == 'Y') {
          _deleteallformdata();
          Fluttertoast.showToast(
              msg: "Data successfully added!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);

          var stdid = formData['stdid'];
          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Tstudentdetail(stdid: stdid),
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
            msg: "Unauthorized access.",
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
          msg: "An error occurred. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    } finally {
      hideLoadingDialog(context);
    }
  }

  Future<void> editmarks(context, Map<String, dynamic> formData) async {
    if (formData["examname"] == null || formData["examname"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Exam Name is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["subjectcode"] == null || formData["subjectcode"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Subject Code is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["marks"] == null || formData["marks"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Marks are required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["marks"] == null || formData["marks"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Marks are required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    if (formData["examdate"] == null || formData["examdate"].isEmpty) {
      Fluttertoast.showToast(
          msg: "Total Marks are required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    }

    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");

      formData['stdid'] = widget.stdid;
      formData['tutorid'] = tutorid;

      // Make the POST request
      var response = await http.put(
        Uri.parse(AppUrl.editstudentmarks),
        body: jsonEncode(formData),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];
        if (output["result"] == 'Y') {
          _deleteallformdata();
          Fluttertoast.showToast(
              msg: "Data successfully Edited!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);

          var stdid = formData['stdid'];

          Future.delayed(Duration.zero, () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Tstudentdetail(stdid: stdid),
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
            msg: "Unauthorized access.",
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
          msg: "An error occurred. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    } finally {
      hideLoadingDialog(context);
    }
  }

  // Fetch students and subjects from the backend
  Future<void> fetchSubjects(context) async {
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");

      final apipost = {
        'tutorid': tutorid,
      };

      var response = await http.post(
        Uri.parse(AppUrl.trGetSuboftutor),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse;

        if (output["result"] == 'Y') {
          var res = EncryptionService.decrypt(output["output"]);
          var subjectsData = res["subjects"];

          setState(() {
            dropdown2Options = subjectsData
                .map<Map<String, dynamic>>((student) => {
                      "subjectname": student['subjectname'],
                      "subjectcode": student['subjectcode'],
                    })
                .toList();
          });
        } else {
          Fluttertoast.showToast(
            msg: "Error: Failed to load data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Error: Failed to load data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } finally {
      hideLoadingDialog(context);
    }
  }

  void _deleteallformdata() {
    setState(() {
      examname = TextEditingController();
      marks = TextEditingController();
      totalmarks = TextEditingController();
      examdate = TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Marks', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: color(deepseablue),
        foregroundColor: color(white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomDropdownField(
                      value: selectedValue2,
                      hintText: 'Select Subject',
                      icon: Icons.book,
                      items: dropdown2Options
                          .map<DropdownMenuItem<String>>((data) {
                        return DropdownMenuItem<String>(
                          value: data['subjectcode'],
                          child: Text(data['subjectname']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue2 = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: examname,
                      hintText: 'Exam Name',
                      icon: Icons.menu_book,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter Subject Name'
                          : null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                        controller: marks,
                        hintText: 'Marks Obtained',
                        icon: Icons.description),
                    CustomTextField(
                        controller: totalmarks,
                        hintText: 'Total Marks',
                        icon: Icons.description),
                    CustomTextField(
                        controller: examdate,
                        hintText: 'Exam Date',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            examdate.text = "${pickedDate.toLocal()}"
                                .split(' ')[0]; // Formatting date
                          }
                        }),
                    const SizedBox(height: 16),
                    buildLoginButton(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Container(
      height: 48,
      width: 500,
      decoration: BoxDecoration(
        color: color('#2f474e'),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          FocusScope.of(context).unfocus();

          var formdata = {
            "examname": examname.text,
            "subjectcode": selectedValue2,
            "marks": marks.text,
            "totalmarks": totalmarks.text,
            "examdate": examdate.text,
          };
          if (widget.editmarks == null) {
            addmarks(context, formdata);
          } else {
            editmarks(context, formdata);
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
