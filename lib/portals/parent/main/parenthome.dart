import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/parent/main/childCard.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';

class Parenthome extends StatefulWidget {
  const Parenthome({super.key});

  @override
  State<Parenthome> createState() => _ParenthomeState();
}

class _ParenthomeState extends State<Parenthome> {
 
  List<Map<String, dynamic>> _mychilds = [];

  Future<void> getchildren() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userid = prefs.getString("userid");

      var apipost = {"parentid": userid};

      var response = await http.post(
        Uri.parse(AppUrl.pr_getallchild),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          var decryptedData = output["data"];
          setState(() {
            _mychilds = List<Map<String, dynamic>>.from(decryptedData);
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
    getchildren();
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
              child: Text("Parent Portal",
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
                //Navigator.pushNamed(context, '/login');
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const Login(
                //       logintype: 'Admin',
                //     ),
                //   ),
                // );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                // width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  //color: const Color.fromARGB(101, 135, 250, 244),
                  color: color(parentthemecolor),
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
                            '${_mychilds.length}',
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
                        'Total Children',
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
              height: 15,
            ),
            Text(
              "Children's List",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                  color: color(deepseablue)),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _mychilds.length,
                itemBuilder: (context, index) {
                  final mychilds = _mychilds[index];
                  return Childcard(chlids: mychilds);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
