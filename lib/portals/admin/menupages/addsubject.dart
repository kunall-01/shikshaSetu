import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/components/widgets/Textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/authconstant.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'addsubjectkey');

  TextEditingController subjectname = TextEditingController();
  TextEditingController subjectcode = TextEditingController();
  TextEditingController descr = TextEditingController();

  Future<void> addsubject(context, formData) async {
    if (formData["subjectname"] == null || formData["subjectname"] == "") {
      Fluttertoast.showToast(
          msg: "Subject Name is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["subjectcode"] == null ||
        formData["subjectcode"] == "") {
      Fluttertoast.showToast(
          msg: "Subject Code is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["subjectcode"].contains(' ')) {
      Fluttertoast.showToast(
        msg: "Spaces are not allowed in Subject Code.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    } else {
      formData["subjectname"] = capitalizeEachWord(formData["subjectname"]);
      formData["subjectcode"] = formData["subjectcode"].toUpperCase();
      try {
        showLoadingDialog(context);
        var response = await http.post(
          Uri.parse(AppUrl.addsubject),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            _deleteallformdata();
            Fluttertoast.showToast(
                msg: "Subject Successfully added!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);
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
            msg: "Error occurred",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      } finally {
        hideLoadingDialog(context);
      }
    }
  }

  void _deleteallformdata() {
    setState(() {
      subjectname = TextEditingController();
      subjectcode = TextEditingController();
      descr = TextEditingController();
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
        title: const Text('Add Subject', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: color(lightblue),
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
                    CustomTextField(
                      controller: subjectname,
                      hintText: 'Subject Name',
                      icon: Icons.menu_book,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter Subject Name'
                          : null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: subjectcode,
                      hintText: 'Subject Code',
                      icon: Icons.lock,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter Subject Code'
                          : null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                        controller: descr,
                        hintText: 'Description (optional)',
                        icon: Icons.description),
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
            "subjectname": subjectname.text,
            "subjectcode": subjectcode.text,
            "descr": descr.text
          };

          addsubject(context, formdata);
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
