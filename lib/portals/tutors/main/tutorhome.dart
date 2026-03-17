import 'package:flutter/material.dart';

import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/tutors/main/students.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/tutors/other/subjectlist.dart';

class TutorHome extends StatefulWidget {
  const TutorHome({super.key});

  @override
  State<TutorHome> createState() => _TutorHomeState();
}

class _TutorHomeState extends State<TutorHome> {
  var totalstudent = 0;
  var totalsubject = 0;
  late Map<String, dynamic> userData = {};

  Future<void> getdashdata() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("userid");

      var apipost = {"tutorid": userid};

      var response = await http.post(
        Uri.parse(AppUrl.trgetdashdata),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          setState(() {
            userData = output['tutor'];
            totalstudent = output['totalstudent'];
            totalsubject = output['totalsubject'];
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
    getdashdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color('#eeeeee'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text("Tutor Portal",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: color(deepseablue))),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Students()));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                // width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  //color: const Color.fromARGB(101, 135, 250, 244),
                  color: color('#436D7B'),
                  border: Border.all(
                    color: const Color.fromARGB(255, 210, 210, 210),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt,
                            color: color('#ebeef0'),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '$totalstudent',
                            style: TextStyle(
                                color: color('#ebeef0'),
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Total Students',
                        style: TextStyle(
                            color: color('#ebeef0'),
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                //Navigator.pushNamed(context, '/login');
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const Login(
                //       logintype: 'Admin',
                //     ),
                //   ),
                // );
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Subjectlist()));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                // width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  //color: const Color.fromARGB(101, 135, 250, 244),
                  color: color('#436D7B'),
                  border: Border.all(
                    color: const Color.fromARGB(255, 210, 210, 210),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt,
                            color: color('#ebeef0'),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '$totalsubject',
                            style: TextStyle(
                                color: color('#ebeef0'),
                                fontSize: 20,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Total Subjects',
                        style: TextStyle(
                            color: color('#ebeef0'),
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
