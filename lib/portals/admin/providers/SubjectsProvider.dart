import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:http/http.dart' as http;

class Subjectsprovider extends ChangeNotifier {
  List<Map<String, dynamic>> _allsubject = [];
  List<Map<String, dynamic>> get allsubject => _allsubject;

  Future<void> getsubjects() async {
    try {
      final response = await http.get(Uri.parse(AppUrl.fetchsubject));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'Y') {
          var decryptedData = EncryptionService.decrypt(data["output"]);
          _allsubject = List<Map<String, dynamic>>.from(decryptedData);
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

  void addsubject(Map<String, dynamic> data) {
    _allsubject.add(data);
    notifyListeners();
  }

  void editsubject(String subjectcode, Map<String, dynamic> updatedsubject) {
    final index =
        _allsubject.indexWhere((data) => data["subjectcode"] == subjectcode);
    if (index != -1) {
      _allsubject[index] = updatedsubject;
      notifyListeners();
    }
  }
}
