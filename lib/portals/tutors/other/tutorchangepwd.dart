import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/components/widgets/Textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/models/user.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';

class Tutorchangepwd extends StatefulWidget {
  const Tutorchangepwd({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TutorchangepwdState createState() => _TutorchangepwdState();
}

class _TutorchangepwdState extends State<Tutorchangepwd> {
  final _formKey =
      GlobalKey<FormState>(debugLabel: 'add_tutorChangePasswordStatekey');

  TextEditingController currentpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  Future<void> submitdata(formData, context) async {
    if (formData["cpwd"] == null || formData["cpwd"] == "") {
      Fluttertoast.showToast(
          msg: "Current password is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["cpwd"]?.trim().length < 4) {
      Fluttertoast.showToast(
          msg: "Current password should be greater than 4.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["npwd"] == null || formData["npwd"] == "") {
      Fluttertoast.showToast(
          msg: "New password is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["npwd"]?.trim().length < 4) {
      Fluttertoast.showToast(
          msg: "New password should be greater than 4.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["ncpwd"] == null || formData["ncpwd"] == "") {
      Fluttertoast.showToast(
          msg: "Confirm password is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["ncpwd"]?.trim().length < 4) {
      Fluttertoast.showToast(
          msg: "Confirm password should be greater than 4.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["ncpwd"] != formData["npwd"]) {
      Fluttertoast.showToast(
          msg: "New and Confirm password must be same.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      try {
        showLoadingDialog(context);
        var response = await http.post(
          Uri.parse(AppUrl.tutorchangepassword),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            _deleteallformdata();

            UserPreferences().removeUser();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardPage(),
                  ));
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

  void _deleteallformdata() {
    setState(() {
      currentpassword = TextEditingController();
      newpassword = TextEditingController();
      confirmpassword = TextEditingController();
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
        title: const Text('Change Password', textAlign: TextAlign.center),
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
                    CustomTextField(
                      controller: currentpassword,
                      hintText: 'Current Password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: newpassword,
                      hintText: 'New Password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: confirmpassword,
                      hintText: 'Confirm Password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: null,
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
    User user = Provider.of<UserProvider>(context).user;
    return Container(
      height: 48,
      width: 500,
      decoration: BoxDecoration(
        color: color(deepseablue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          var formdata = {
            "cpwd": currentpassword.text,
            "npwd": newpassword.text,
            "ncpwd": confirmpassword.text,
            "userid": user.userid,
          };
          submitdata(formdata, context);
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
