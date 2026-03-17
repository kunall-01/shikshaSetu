import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:http/http.dart' as http;

class Adminprovider extends ChangeNotifier {
  List<Map<String, dynamic>> _admins = [];
  List<Map<String, dynamic>> get admins => _admins;

  Future<void> fetchAdminList() async {
    try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        var userid = prefs.getString("userid");
      final response =
          await http.get(Uri.parse('${AppUrl.getalladmin}/$userid'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          var decryptedData = EncryptionService.decrypt(output["data"]);
          _admins = List<Map<String, dynamic>>.from(decryptedData);
          notifyListeners();
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

  void addadmin(Map<String, dynamic> newadmin) {
    _admins.add(newadmin);
    notifyListeners();
  }

  void editadmin(String id, Map<String, dynamic> data) {
    final index = _admins.indexWhere((admin) => admin["id"] == id);
    if (index != -1) {
      _admins[index] = data;
    }
    notifyListeners();
  }

  Future<void> deleteAdmin(String id) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrl.deleteadmin),
        body: jsonEncode({"id": id}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];

        if (output['result'] == 'Y') {
          // Successfully deleted, remove from local list
          _admins.removeWhere((admin) => admin["id"] == id);
          Fluttertoast.showToast(
              msg: "Admin deleted successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
          notifyListeners();
        } else {
          Fluttertoast.showToast(
              msg: output['message'] ?? "Error deleting admin",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: Failed to delete admin",
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

  Future<void> blockUnblockAdmin(String id) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrl.blockunblockadmin),
        body: jsonEncode({"id": id}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];

        if (output['result'] == 'Y') {
          // Successfully updated status, update local list
          final updatedAdmin = _admins.firstWhere((admin) => admin["id"] == id);
          updatedAdmin["isblock"] = updatedAdmin["isblock"] == 0 ? 1 : 0;
          Fluttertoast.showToast(
              msg: "Admin status updated successfully!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
          notifyListeners();
        } else {
          Fluttertoast.showToast(
              msg: output['message'] ?? "Error updating admin status",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: Failed to update admin status",
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
}
