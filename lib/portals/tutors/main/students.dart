import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/tutors/main/mystudentcard.dart';

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  List<Map<String, dynamic>> _mystudents = [];

  Future<void> getmystudents() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("userid");

      var apipost = {"tutorid": userid};

      var response = await http.post(
        Uri.parse(AppUrl.trgetallstudents),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          var decryptedData = output["data"];
          setState(() {
            _mystudents = List<Map<String, dynamic>>.from(decryptedData);
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: Failed to load data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    }
  }

  @override
  void initState() {
    getmystudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student List",
          style: TextStyle(color: color(white)),
        ),
        centerTitle: true,
        backgroundColor: color(deepseablue),
        foregroundColor: color(white),
      ),
      body: _mystudents.isEmpty
          ? const Center(
              child: Text(
                "No students found.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _mystudents.length,
              itemBuilder: (context, index) {
                final mychilds = _mystudents[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Mystudentcard(chlids: mychilds),
                );
              },
            ),
    );
  }
}
