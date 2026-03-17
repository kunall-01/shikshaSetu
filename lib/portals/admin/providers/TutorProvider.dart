import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:http/http.dart' as http;

class TutorProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tutors = [];
  List<Map<String, dynamic>> get tutors => _tutors;

  Future<void> fetchTutors() async {
    try {
      final response = await http.get(Uri.parse(AppUrl.gettutor));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var decryptedData = EncryptionService.decrypt(data["output"]);
        _tutors = List<Map<String, dynamic>>.from(decryptedData);
        notifyListeners();
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

  void addTutor(Map<String, dynamic> newTutor) {
    _tutors.add(newTutor);
    notifyListeners();
  }

  void editTutor(String tutorId, Map<String, dynamic> updatedTutor) {
    // Find the index of the tutor with the given tutorId
    final index = _tutors.indexWhere((tutor) => tutor["tutorid"] == tutorId);

    if (index != -1) {
      // Update the tutor at the found index with the new data
      _tutors[index] = updatedTutor;
      notifyListeners(); // Notify listeners about the change
    }
  }
}
