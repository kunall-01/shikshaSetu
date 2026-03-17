import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/main/tutordetail.dart';
import 'package:shikshasetutution/portals/admin/menupages/addtutor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/portals/admin/providers/TutorProvider.dart';
import 'package:shikshasetutution/components/common.dart';

class TutorCard extends StatefulWidget {
  final Map<String, dynamic> tutor;
  const TutorCard({super.key, required this.tutor});

  @override
  State<TutorCard> createState() => _TutorCardState();
}

class _TutorCardState extends State<TutorCard> {
  Future<void> fetchTutors(context, tutorid) async {
    try {
      showLoading(context);
      final apipost = {
        'id': tutorid,
      };

      var response = await http.post(
        Uri.parse(AppUrl.tutorBU),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];
        if (output["result"] == 'Y') {
          var edittutor = EncryptionService.decrypt(output["edit_tutor"]);
          setState(() {
            Provider.of<TutorProvider>(context, listen: false)
                .editTutor(tutorid, edittutor);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(edittutor['isblock'] == 1
                  ? 'Blocked ${widget.tutor["name"]}'
                  : 'UnBlocked ${widget.tutor["name"]}'),
            ),
          );
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
    } finally {
      hideLoadingDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: widget.tutor['isblock'] == 0
          ? color(white)
          : const Color.fromARGB(248, 220, 220, 220),
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Tutordetail(tutor: widget.tutor),
            ),
          )
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(
                  '${AppUrl.tutorprofilephoto}${widget.tutor["tutorid"]}-profile.jpg',
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  // This triggers the fallback content
                },
                child: Text(
                  widget.tutor["name"][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tutor Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tutor Name
                    Text(
                      widget.tutor["name"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Additional Details
                    Text("Mobile: ${widget.tutor["mobileno"]}"),
                    Text("Gender: ${widget.tutor["gender"]}"),
                    Text("Rating: ${widget.tutor["rating"]} ⭐"),
                    const SizedBox(height: 5),
                    Text(
                      widget.tutor["descr"],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    // Subjects
                    Wrap(
                      spacing: 5,
                      children: widget.tutor["subjects"]
                          .map<Widget>((subject) => Chip(
                                label: Text(subject["subjectname"]),
                                backgroundColor: Colors.blue[50],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Action Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (String choice) {
                  switch (choice) {
                    case 'Edit':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddTutor(tutor: widget.tutor),
                        ),
                      );
                      break;
                    case 'status':
                      fetchTutors(context, widget.tutor["tutorid"]);
                      break;
                    case 'Detail':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              Tutordetail(tutor: widget.tutor),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'Edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          const Icon(Icons.block_outlined, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(widget.tutor["isblock"] == 1
                              ? 'Unblock'
                              : 'Block'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Detail',
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Detail'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
