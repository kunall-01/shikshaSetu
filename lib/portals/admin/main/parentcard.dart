import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/main/parentdetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/portals/admin/menupages/addparent.dart';
import 'package:shikshasetutution/portals/admin/providers/ParentchildProvider.dart';

class ParentCard extends StatefulWidget {
  final Map<String, dynamic> parent;
  const ParentCard({super.key, required this.parent});

  @override
  State<ParentCard> createState() => _ParentCardState();
}

class _ParentCardState extends State<ParentCard> {
  Future<void> statusfunction(context, parentid) async {
    try {
      showLoading(context);
      final apipost = {
        'id': parentid,
      };

      var response = await http.post(
        Uri.parse(AppUrl.parentBU),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];
        if (output["result"] == 'Y') {
          var editparent = output["edit_parent"][0];
          setState(() {
            Provider.of<Parentchildprovider>(context, listen: false)
                .editparentchilds(parentid, editparent);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(editparent['isblock'] == 1
                  ? 'Blocked ${widget.parent["name"]}'
                  : 'UnBlocked ${widget.parent["name"]}'),
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
      color: widget.parent['isblock'] == 0
          ? color(white)
          : const Color.fromARGB(248, 220, 220, 220),
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Parentdetail(parent: widget.parent),
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
                backgroundColor: color(deepseablue),
                child: Text(
                  widget.parent["name"]?.substring(0, 1).toUpperCase() ?? "?",
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
                      "Name: ${widget.parent["name"]}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text("Parent Id: ${widget.parent["parentid"]}"),
                    const SizedBox(height: 5),
                    Text("Mobile: ${widget.parent["mobileno"]}"),
                    const SizedBox(height: 5),
                    Text("Childs: ${widget.parent["children"]?.length ?? 0}"),
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
                          builder: (context) =>
                              AddParent(parents: widget.parent),
                        ),
                      );
                      break;
                    case 'status':
                      statusfunction(context, widget.parent["parentid"]);
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
                          Text(widget.parent["isblock"] == 1
                              ? 'Unblock'
                              : 'Block'),
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
