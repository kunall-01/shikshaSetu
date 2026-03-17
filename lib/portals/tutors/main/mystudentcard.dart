import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/tutors/other/addhomework.dart';
import 'package:shikshasetutution/portals/tutors/other/addmarks.dart';
import 'package:shikshasetutution/portals/tutors/other/tstudentdetail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';

class Mystudentcard extends StatefulWidget {
  final Map<String, dynamic> chlids;
  const Mystudentcard({super.key, required this.chlids});

  @override
  State<Mystudentcard> createState() => _MystudentcardState();
}

class _MystudentcardState extends State<Mystudentcard> {
  double _rating = 0; // Rating variable

  @override
  void initState() {
    super.initState();
    // ⭐ Set default rating from widget.chlids["rating"]
    _rating = (widget.chlids["rating"] ?? 0).toDouble();
  }

  Future<void> rateStudent(int rating) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var tutorid = prefs.getString("userid");

      var apipost = {
        "tutorid": tutorid,
        "stdid": widget.chlids["stdid"],
        "rating": rating
      };

      var response = await http.post(
        Uri.parse(AppUrl.rateStudent), // ✅ Replace with your API URL
        body: jsonEncode(apipost),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];

        if (output['result'] == 'Y') {
          setState(() {
            _rating = rating.toDouble(); // Update UI rating
          });
        } else {
          Fluttertoast.showToast(
              msg: "Failed to rate. Try again!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Server Error: ${response.statusCode}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 233, 233, 233),
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Tstudentdetail(
                    stdid: widget.chlids["stdid"],
                  )));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: color(deepseablue),
                    child: Text(
                      widget.chlids["name"]?.substring(0, 1).toUpperCase() ??
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
                        Text(
                          "Name: ${capitalizeFirstLetter(widget.chlids["name"])}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("Age: ${widget.chlids["age"]}"),
                        const SizedBox(height: 5),
                        Text("Standard: ${widget.chlids["standard"]}"),
                        const SizedBox(height: 5),
                        Text("Subject Code: ${widget.chlids["subjectcode"]}"),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (String choice) {
                      switch (choice) {
                        case 'AddHomework':
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  Addhomework(stdid: widget.chlids["stdid"])));
                          break;
                        case 'AddMarks':
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  Addmarks(stdid: widget.chlids["stdid"])));
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 'AddHomework',
                          child: Row(
                            children: [
                              Icon(Icons.add_home_work,
                                  color: color(deepseablue)),
                              const SizedBox(width: 8),
                              const Text('Add Homework'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'AddMarks',
                          child: Row(
                            children: [
                              Icon(Icons.add_home_work,
                                  color: color(deepseablue)),
                              const SizedBox(width: 8),
                              const Text('Add Marks'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ⭐ Star Rating Section ⭐
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color.fromARGB(255, 243, 183, 5),
                      size: 28,
                    ),
                    onPressed: () {
                      rateStudent(index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
