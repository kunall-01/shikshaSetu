import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';

import 'package:shikshasetutution/portals/admin/providers/adminProvider.dart';

class AdminCard extends StatefulWidget {
  final Map<String, dynamic> admin;
  const AdminCard({super.key, required this.admin});

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> {
  Future<void> submitdata(context, Map<String, dynamic> formData) async {
    // Validate each field
    if (formData["name"] == null || formData["name"].trim().length < 3) {
      Fluttertoast.showToast(
        msg: "Name is required and must be at least 3 characters.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (formData["email"] == null ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(formData["email"])) {
      Fluttertoast.showToast(
        msg: "Valid email is required.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (formData["mobileno"] == null ||
        formData["mobileno"].trim().length != 10 ||
        !RegExp(r'^\d+$').hasMatch(formData["mobileno"])) {
      Fluttertoast.showToast(
        msg: "Mobile number must be 10 digits.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (formData["aadharno"] == null ||
        formData["aadharno"].trim().length != 12 ||
        !RegExp(r'^\d+$').hasMatch(formData["aadharno"])) {
      Fluttertoast.showToast(
        msg: "Aadhar number must be 12 digits.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (formData["gender"] == null ||
        (formData["gender"] != "male" &&
            formData["gender"] != "female" &&
            formData["gender"] != "other" &&
            formData["gender"] != "Male" &&
            formData["gender"] != "Female" &&
            formData["gender"] != "Other")) {
      Fluttertoast.showToast(
        msg: "Gender must be 'male', 'female', or 'other'.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    try {
      showLoadingDialog(context);

      // Prepare API payload
      var apiPost = {
        "id": formData["id"],
        "name": formData["name"],
        "email": formData["email"],
        "mobileno": formData["mobileno"],
        "aadharno": formData["aadharno"],
        "gender": formData["gender"],
      };

      var response = await http.post(
        Uri.parse(AppUrl.editAdmin),
        body: jsonEncode(apiPost),
        headers: {'content-type': 'application/json'},
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];
        if (output["result"] == 'Y') {
          var adminid = formData["id"];
          var editAdminData = EncryptionService.decrypt(output["data"]);
          Provider.of<Adminprovider>(context, listen: false)
              .editadmin(adminid, editAdminData);

          Fluttertoast.showToast(
            msg: "Admin details successfully updated!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );

          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(
            msg: output["message"] ?? "Failed to update admin details.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed with status code: ${response.statusCode}.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (exception) {
      Fluttertoast.showToast(
        msg: "An error occurred: $exception",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } finally {
      hideLoadingDialog(context);
    }
  }

  void _editadmin(context, mydata) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: mydata["name"]);
        final mobileController =
            TextEditingController(text: mydata["mobileno"]);
        final emailController = TextEditingController(text: mydata["email"]);
        final aadharnoController =
            TextEditingController(text: mydata["aadharno"]);
        final genderController = TextEditingController(text: mydata["gender"]);
        return AlertDialog(
          title: const Text("Edit Admin"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: "Mobile No"),
                ),
                TextField(
                  controller: aadharnoController,
                  decoration: const InputDecoration(labelText: "Aadhar No"),
                ),
                TextField(
                  controller: genderController,
                  decoration: const InputDecoration(labelText: "Gender "),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                mydata["name"] = nameController.text;
                mydata["email"] = emailController.text;
                mydata["mobileno"] = mobileController.text;
                mydata["aadharno"] = aadharnoController.text;
                mydata["gender"] = genderController.text;

                submitdata(context, mydata);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteadmin(context, String adminid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Admin"),
        content: const Text("Are you sure you want to delete this admin ?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cancel deletion
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Adminprovider provider =
                  Provider.of<Adminprovider>(context, listen: false);
              provider.deleteAdmin(adminid);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: widget.admin['isblock'] == 0
          ? color(white)
          : const Color.fromARGB(248, 220, 220, 220),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Name and ID
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: createMaterialColor(color(blue)),
                  child: Text(
                    widget.admin["name"].substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.admin["name"],
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        "ID: ${widget.admin["id"]}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Divider for Separation
            Divider(
              thickness: 0.5,
              color: Colors.grey[100],
            ),

            // Detail Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Date of Entry", widget.admin["doe"]),
                _buildDetailRow("Email", widget.admin["email"]),
                _buildDetailRow("Mobile No", widget.admin["mobileno"]),
                _buildDetailRow("Aadhar No", widget.admin["aadharno"]),
                _buildDetailRow("Gender", widget.admin["gender"]),
              ],
            ),

            // Divider for Separation
            Divider(thickness: 1, color: Colors.grey[100]),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: "Edit",
                  color: createMaterialColor(color(blue)),
                  onPressed: () {
                    _editadmin(context, widget.admin);
                  },
                ),
                _buildActionButton(
                  icon: Icons.block_outlined,
                  label: "Block",
                  color: createMaterialColor(color('#c70c0c')),
                  onPressed: () {
                    Adminprovider provider =
                        Provider.of<Adminprovider>(context, listen: false);
                    provider.blockUnblockAdmin(widget.admin["id"]);
                  },
                ),
                // _buildActionButton(
                //   icon: Icons.settings,
                //   label: "Setting",
                //   color: createMaterialColor(color(deepseablue)),
                //   onPressed: () {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text('Delete ${widget.admin["name"]}'),
                //         duration: Durations.short4,
                //       ),
                //     );
                //   },
                // ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: "Delete",
                  color: createMaterialColor(color(darkpink)),
                  onPressed: () {
                    _deleteadmin(context, widget.admin["id"]);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Detail Rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // Helper for Action Buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
