// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/models/authconstant.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> userData = {};
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("userid");
      final response = await http.get(
        Uri.parse('${AppUrl.getmyadminprofile}/$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          setState(() {
            userData = output['data'];
            _nameController.text = userData['name'];
            _emailController.text = userData['email'];
          });
        } else {
          Fluttertoast.showToast(
              msg: "Error: ${output['message']}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: Failed to load profile data",
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: color(lightblue),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing
                  ? Icons.close
                  : Icons.edit, // Toggle edit/cancel button
            ),
            onPressed: _toggleEditMode,
          )
        ],
      ),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildProfileInfoCard(),
                  const SizedBox(height: 20),
                  if (_isEditing)
                    _buildSubmitButton(
                        userData, _nameController, _emailController),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfilePhoto(),
            const SizedBox(height: 20),
            _buildEditableProfileItem("Name", _nameController),
            _buildEditableProfileItem("Email", _emailController),
            _buildProfileItem("Phone", userData["mobileno"]),
            _buildProfileItem("Aadhar No.", userData["aadharno"]),
            _buildProfileItem("Gender", userData["gender"]),
            _buildProfileItem("Date of Entry", userData["doe"]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: color(blue),
      child: Text(
        userData["name"]?.substring(0, 1).toUpperCase() ?? '',
        style: const TextStyle(fontSize: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildEditableProfileItem(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          _isEditing
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: label,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: color(deepseablue),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: color(deepseablue),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Text(controller.text),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
      formdata, TextEditingController _name, TextEditingController _email) {
    return ElevatedButton(
      onPressed: () => {submitdata(context, formdata, _name, _email)},
      style: ElevatedButton.styleFrom(
        backgroundColor: color(blue),
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        "Submit Changes",
        style: TextStyle(color: color(deepseablue)),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // void _submitChanges() {
  //   Fluttertoast.showToast(
  //     msg: "Profile updated successfully!",
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.CENTER,
  //   );
  //   _toggleEditMode();
  // }

  Future<void> submitdata(context, Map<String, dynamic> formData,
      TextEditingController _name, TextEditingController _email) async {
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

    formData["name"] = _name.text;
    formData["email"] = _email.text;

    var apiPost = {
      "id": formData["id"],
      "name": formData["name"],
      "email": formData["email"],
    };

    try {
      showLoadingDialog(context);

      var response = await http.post(
        Uri.parse(AppUrl.myadminprofileedit),
        body: jsonEncode(apiPost),
        headers: {'content-type': 'application/json'},
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse['output'];
        if (output["result"] == 'Y') {
          _toggleEditMode();
          Fluttertoast.showToast(
            msg: "Profile updated successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("name", formData["name"] ?? "");
          await prefs.setString("email", formData["email"] ?? "");
        } else {
          Fluttertoast.showToast(
            msg: output["message"] ?? "Failed to update profile.",
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
}
