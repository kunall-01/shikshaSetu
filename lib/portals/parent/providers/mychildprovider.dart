import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:http/http.dart' as http;

class Mychildprovider extends ChangeNotifier {
  List<Map<String, dynamic>> _mychilds = [];
  List<Map<String, dynamic>> get mychilds => _mychilds;

  Future<void> fetchParentChild() async {
    try {
      final response = await http.get(Uri.parse(AppUrl.pr_getallchild));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          var decryptedData = output["data"];
          _mychilds = List<Map<String, dynamic>>.from(decryptedData);
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

  void editparentchilds(String stdid, Map<String, dynamic> updatedchilds) {
    final index = _mychilds.indexWhere((child) => child["stdid"] == stdid);
    if (index != -1) {
      _mychilds[index] = updatedchilds;
    }
    notifyListeners();
  }
}
