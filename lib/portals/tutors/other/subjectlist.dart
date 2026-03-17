import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';

class Subjectlist extends StatefulWidget {
  const Subjectlist({super.key});

  @override
  State<Subjectlist> createState() => _SubjectlistState();
}

class _SubjectlistState extends State<Subjectlist> {
  List<Map<String, dynamic>> dropdown2Options = [];

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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchSubjects(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Subject List",
          style: TextStyle(color: color(white)),
        ),
        centerTitle: true,
        backgroundColor: color(deepseablue),
        foregroundColor: color(white),
      ),
      body: dropdown2Options.isEmpty
          ? const Center(
              child: Text(
                "No Subject found.",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: dropdown2Options.length,
              itemBuilder: (context, index) {
                final subjects = dropdown2Options[index];
                return Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 233, 233, 233),
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () => {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: color(deepseablue),
                            child: Text(
                              subjects["subjectname"]
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  "?",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tutor Name
                                Text(
                                  "Subject Name: ${capitalizeFirstLetter(subjects["subjectname"])}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                    "Subject Code: ${subjects["subjectcode"]}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
