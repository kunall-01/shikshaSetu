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
import 'package:intl/intl.dart';
import 'package:shikshasetutution/portals/tutors/other/tstudentdetail.dart';

class Addhomework extends StatefulWidget {
  final String stdid;
  final Map<String, dynamic>? parents;
  const Addhomework({super.key, required this.stdid, this.parents});

  @override
  // ignore: library_private_types_in_public_api
  _AddhomeworkState createState() => _AddhomeworkState();
}

class _AddhomeworkState extends State<Addhomework> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'addhomeworkkey');

  String? selectedValue2;
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController submissiondate = TextEditingController();
  TextEditingController homeworkController = TextEditingController();

  List<Map<String, dynamic>> dropdown2Options = [];
  @override
  void initState() {
    if (widget.parents != null) {
      titlecontroller = TextEditingController(text: widget.parents!["topic"]);
      submissiondate =
          TextEditingController(text: widget.parents!["submissiondate"]);
      homeworkController =
          TextEditingController(text: widget.parents!["homework"]);
      selectedValue2 = widget.parents!["subjectcode"];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => fetchSubjects(context));
    super.initState();
  }

  Future<void> submitdata(context, formData) async {
    // Validate "subjectcode"
    if (formData["subjectcode"] == null ||
        formData["subjectcode"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Subject code is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // Validate "title"
    if (formData["title"] == null || formData["title"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Title is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // Validate "submissiondate"
    if (formData["submissiondate"] == null ||
        formData["submissiondate"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Submission date is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // Validate "homework"
    if (formData["homework"] == null || formData["homework"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Homework description is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // If all fields are valid, send the request
    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");

      formData['stdid'] = widget.stdid;
      formData['tutorid'] = tutorid;

      var response = await http.post(
        Uri.parse(AppUrl.addhomework),
        body: jsonEncode(formData),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];

        if (output["result"] == 'Y') {
          Fluttertoast.showToast(
            msg: "Homework successfully added!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );

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
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: "Error occurred: $exception",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } finally {
      hideLoadingDialog(context);
    }
  }

  Future<void> submiteditdata(context, formData) async {
    // Validate "subjectcode"
    if (formData["subjectcode"] == null ||
        formData["subjectcode"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Subject code is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // Validate "title"
    if (formData["title"] == null || formData["title"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Title is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // Validate "submissiondate"
    if (formData["submissiondate"] == null ||
        formData["submissiondate"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Submission date is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // Validate "homework"
    if (formData["homework"] == null || formData["homework"]?.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Homework description is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    try {
      showLoadingDialog(context);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");

      formData['stdid'] = widget.stdid;
      formData['tutorid'] = tutorid;

      var response = await http.put(
        Uri.parse(AppUrl.editstudenthomework),
        body: jsonEncode(formData),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];

        if (output["result"] == 'Y') {
          Fluttertoast.showToast(
            msg: "Homework successfully Edited!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );

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
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: "Error occurred: $exception",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
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

      final apipost = {'tutorid': tutorid, 'stdid': widget.stdid};

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

  void _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        submissiondate.text = formattedDate;
      });
    }
  }

  // void _deleteallformdata() {
  //   setState(() {
  //     titlecontroller = TextEditingController();
  //     homeworkController = TextEditingController();
  //     submissiondate = TextEditingController();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Homework', textAlign: TextAlign.center),
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
                      controller: titlecontroller,
                      hintText: 'Title',
                      icon: Icons.title,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter Title' : null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: submissiondate,
                      hintText: 'Submission date',
                      icon: Icons.date_range,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter Submission date'
                          : null,
                      onTap: () =>
                          _selectDate(context), // Open date picker on tap
                      readOnly: true, // Make field read-only
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: homeworkController,
                      hintText: 'Home work',
                      icon: Icons.home,
                      validator: null,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      height: 150,
                    ),
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

          if (widget.parents != null) {
            var formdata = {
              "subjectcode": selectedValue2,
              "title": titlecontroller.text,
              "submissiondate": submissiondate.text,
              "homework": homeworkController.text,
              "homeworkid": widget.parents?["homeworkid"]
            };
            submiteditdata(context, formdata);
          } else {
            var formdata = {
              "subjectcode": selectedValue2,
              "title": titlecontroller.text,
              "submissiondate": submissiondate.text,
              "homework": homeworkController.text,
            };
            submitdata(context, formdata);
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
