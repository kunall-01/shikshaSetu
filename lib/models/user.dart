import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/default.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/models/paras.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';
import 'package:shikshasetutution/portals/parent/dashboardparent.dart';
import 'package:shikshasetutution/portals/tutors/dashboardtutor.dart';

// ignore: constant_identifier_names
enum Status { Uninitialized, Authenticated, Unauthenticated }

class UserProvider with ChangeNotifier {
  User _user = User();
  final Status _status = Status.Uninitialized;

  User get user => _user;
  Status get status => _status;

  void setUser(User? user) {
    _user = user!;
  }

  void loginProcess(context, Loginparas formData) async {
    var userlength = formData.userid!.trim().length;
    if (formData.userid == null || userlength < 5) {
      Fluttertoast.showToast(
          msg: "Invalid user id",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData.para2 == null || formData.para2!.length < 4) {
      Fluttertoast.showToast(
          msg: "Invalid password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      var id = formData.userid?.trim().toUpperCase();

      final apipost = {
        'userid': formData.para3 == 'Admin' ? id : formData.userid,
        'para1': "App Access",
        'para2': formData.para2,
        'para3': formData.para3,
      };

      try {
        showLoadingDialog(context);

        var response = await http.post(
          Uri.parse(AppUrl.login),
          body: jsonEncode(apipost),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            User authUser = User.fromJson(output);
            UserPreferences().saveUser(authUser);
            setUser(authUser);
            //notifyListeners();
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //     '/dashboard', (Route<dynamic> route) => false);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => formData.para3 == 'Admin'
                        ? const AdminDashboardPage()
                        : formData.para3 == 'Tutor'
                            ? const TutorDashboard()
                            : formData.para3 == 'Parent'
                                ? const ParentDasboard()
                                : const Default(),
                  ));
            });
          } else {
            Fluttertoast.showToast(
                msg: "Invalid id or password",
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
        //loading.hide();
        hideLoadingDialog(context);
      }
    }
  }
}

class UserPreferences {
  Future<bool> saveUser(User user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      return await prefs.setString("userid", user.userid ?? "") &&
          await prefs.setString("name", user.name ?? "") &&
          await prefs.setString("email", user.email ?? "") &&
          await prefs.setString("mobile", user.mobile ?? "") &&
          await prefs.setString("type", user.type ?? "") &&
          await prefs.setString("token", user.token ?? "") &&
          await prefs.setString("prid", user.prid ?? "");
    } catch (e) {
      return false;
    }
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userid = prefs.getString("userid");
    String? name = prefs.getString("name");
    String? email = prefs.getString("email");
    String? mobile = prefs.getString("mobile");
    String? type = prefs.getString("type");
    String? token = prefs.getString("token");
    String? prid = prefs.getString("prid");
    String? appversion = "1.0.0";

    // try {
    //   var response = await http.get(Uri.parse(AppUrl.getappversion));
    //   if (response.statusCode == 200) {
    //     appversion = response.body;
    //   }
    // } catch (exception) {
    //   appversion = "1.0.0";
    // } finally {}

    return User(
      userid: userid,
      name: name,
      email: email,
      mobile: mobile,
      type: type,
      token: token,
      prid: prid,
      appversion: appversion,
    );
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("userid");
    prefs.remove("name");
    prefs.remove("email");
    prefs.remove("mobile");
    prefs.remove("type");
    prefs.remove("token");
    prefs.remove("prid");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }
}

class User {
  String? userid;
  String? name = "";
  String? email = "";
  String? mobile = "";
  String? type;
  String? token;
  String? prid;
  String? appversion;

  User({
    this.userid,
    this.name,
    this.email,
    this.mobile,
    this.type,
    this.token,
    this.prid,
    this.appversion,
  });

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
      userid: responseData['userid'],
      name: responseData['name'],
      email: responseData['email'],
      mobile: responseData['mobile'],
      type: responseData['type'],
      token: responseData['token'],
      prid: responseData['prid'],
      appversion: responseData['appversion'],
    );
  }
}
