import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/portals/parent/others/childhomework.dart';
import 'package:shikshasetutution/portals/parent/others/childmarks.dart';

class Childdetail extends StatefulWidget {
  final String parentid;
  final String childid;
  const Childdetail({super.key, required this.parentid, required this.childid});

  @override
  State<Childdetail> createState() => _ChilddetailState();
}

class _ChilddetailState extends State<Childdetail>
    with SingleTickerProviderStateMixin {
  var _childdetl = {};
  late TabController _tabController;
  Future<void> getchilddetail() async {
    try {
      var apipost = {"parentid": widget.parentid, "stdid": widget.childid};
      var response = await http.post(
        Uri.parse(AppUrl.pr_getchilddetail),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          setState(() {
            _childdetl = output["data"];
          });
          getimage();
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

  // ignore: non_constant_identifier_names
  String ImageUrl = "";
  Future<void> getimage() async {
    String url = '${AppUrl.stdprofilephoto}${_childdetl["stdid"]}-sprofile.jpg';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          ImageUrl = url;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error loading profile photo.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    }
  }

  @override
  void initState() {
    getchilddetail();

    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _childdetl.isEmpty
        ? Scaffold(
            backgroundColor: color('#eeeeee'),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "Child Details",
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: color(darkpink),
              foregroundColor: color(white),
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Detail'),
                  Tab(text: 'Homework'),
                  Tab(text: 'Marks'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section with Network Image
                        Center(
                          child: ImageUrl != ""
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundColor: color(darkpink),
                                  backgroundImage: NetworkImage(
                                    '${AppUrl.stdprofilephoto}${_childdetl["stdid"]}-sprofile.jpg',
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: color(darkpink),
                                  child: _childdetl['name'] != null &&
                                          _childdetl['name'].isNotEmpty
                                      ? Text(
                                          _childdetl['name'][0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        _buildNameIdCard(_childdetl),
                        const SizedBox(height: 20),

                        _buildDetailCard(
                          "Details",
                          {
                            "Age": _childdetl['age'],
                            "Standard": _childdetl['standard'],
                            "Gender": _childdetl['gender'],
                            "Date of Enrollment": _childdetl['doe'],
                          },
                        ),
                        const SizedBox(height: 10),

                        // Tutor Information
                        if (_childdetl['tutors'].isNotEmpty)
                          _buildTutorSection(_childdetl['tutors']),

                        // Homework & Exam Marks
                        //_buildHomeworkSection(),
                        // _buildExamMarksSection()
                      ],
                    ),
                  ),
                ),
                Childhomework(
                  stdid: widget.childid,
                ),
                Childmarks(
                  stdid: widget.childid,
                )
              ],
            ),
          );
  }

  Widget _buildNameIdCard(data) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: color(skin),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Name
              Text(
                data['name'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color(deepseablue),
                ),
              ),
              const SizedBox(height: 8),
              // ID
              Text(
                "ID: ${data['stdid']}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Subtle color for the ID
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, Map<String, String> details) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color(darkpink),
              ),
            ),
            const SizedBox(height: 8),
            ...details.entries.map<Widget>((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorSection(List tutors) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tutors",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color(darkpink),
              ),
            ),
            const SizedBox(height: 8),
            ...tutors.map<Widget>((tutor) {
              return Row(
                children: [
                  Icon(Icons.person, size: 20, color: color(blue)),
                  const SizedBox(width: 8),
                  Text(
                    tutor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Subject: ${tutor['subjectname']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
