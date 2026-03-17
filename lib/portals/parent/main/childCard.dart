import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
//import 'package:shikshasetutution/models/authconstant.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:intl/intl.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/portals/parent/main/childdetail.dart';

class Childcard extends StatefulWidget {
  final Map<String, dynamic> chlids;
  const Childcard({super.key, required this.chlids});

  @override
  State<Childcard> createState() => _ChildcardState();
}

class _ChildcardState extends State<Childcard> {
  // Future<void> statusfunction(context, parentid) async {
  //   try {
  //     showLoading(context);
  //     final apipost = {
  //       'id': parentid,
  //     };

  //     var response = await http.post(
  //       Uri.parse(AppUrl.parentBU),
  //       body: jsonEncode(apipost),
  //       headers: {'content-type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //       var output = jsonResponse['output'];
  //       if (output["result"] == 'Y') {
  //         var editparent = output["edit_parent"][0];

  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(editparent['isblock'] == 1
  //                 ? 'Blocked ${widget.chlids["name"]}'
  //                 : 'UnBlocked ${widget.chlids["name"]}'),
  //           ),
  //         );
  //       }
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: "Error: Failed to load data",
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.CENTER);
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //         msg: "Error: $e",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER);
  //   } finally {
  //     hideLoadingDialog(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 233, 233, 233),
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Childdetail(
                  parentid: widget.chlids["parentid"],
                  childid: widget.chlids["stdid"]),
            ),
          )
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25, // Adjust the size of the avatar
                backgroundColor: color(darkskin),
                child: Text(
                  widget.chlids["name"]?.substring(0, 1).toUpperCase() ?? "?",
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
                      "Name: ${capitalizeFirstLetter(widget.chlids["name"])}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text("Age: ${widget.chlids["age"]}"),
                    const SizedBox(height: 5),
                    Text("Standard : ${widget.chlids["standard"]}"),
                    const SizedBox(height: 5),
                    Text(
                        "Enrollment date: ${DateFormat("dd-MM-yyyy").format(DateTime.parse(widget.chlids["doe"]))}"),
                  ],
                ),
              ),
            ],
          ),
        ),  
      ),
    );
  }
}
