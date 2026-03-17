import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:http/http.dart' as http;

class Parentchildprovider extends ChangeNotifier {
  List<Map<String, dynamic>> _parentchilds = [];
  List<Map<String, dynamic>> get parentchilds => _parentchilds;

  Future<void> fetchParentChild() async {
    try {
      final response = await http.get(Uri.parse(AppUrl.getparentchild));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var output = data['output'];
        if (output['result'] == 'Y') {
          var decryptedData = output["data"];
          _parentchilds = List<Map<String, dynamic>>.from(decryptedData);
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

  void addparentchilds(Map<String, dynamic> newparentchilds) {
    _parentchilds.add(newparentchilds);
    notifyListeners();
  }

  void editparentchilds(
      String parentId, Map<String, dynamic> updatedparentchilds) {
    final index = _parentchilds
        .indexWhere((parentchild) => parentchild["parentid"] == parentId);
    if (index != -1) {
      _parentchilds[index] = updatedparentchilds;
    }
    notifyListeners();
  }
}
