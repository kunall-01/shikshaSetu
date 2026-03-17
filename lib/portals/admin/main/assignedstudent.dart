import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shikshasetutution/components/common.dart'; // Assuming you have this for color and other utils
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';
import 'package:shikshasetutution/portals/admin/providers/TutorProvider.dart';

class Assignedstudent extends StatefulWidget {
  final String tutorid;
  const Assignedstudent({super.key, required this.tutorid});

  @override
  State<Assignedstudent> createState() => _AssignedstudentState();
}

class _AssignedstudentState extends State<Assignedstudent> {
  List<Map<String, dynamic>> dropdown1Items = [];
  List<Map<String, dynamic>> dropdown2Options = [];
  List<Map<String, dynamic>> filteredDropdown1Items = [];
  List<String> dropdown2Items = [];
  String? selectedValue1;
  String? selectedValue2;
  String? selectedValue2_;
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = "";

  // Fetch students and subjects from the backend
  Future<void> fetchStudentsAndSubjects(context, tutorid) async {
    try {
      final apipost = {
        'id': tutorid,
      };

      var response = await http.post(
        Uri.parse(AppUrl.getStdSubAssign),
        body: jsonEncode(apipost),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        var output = jsonResponse;

        if (output["result"] == 'Y') {
          var res = EncryptionService.decrypt(output["output"]);
          var studentsData = res["students"];
          var subjectsData = res["subjects"];

          setState(() {
            dropdown1Items = studentsData
                .map<Map<String, dynamic>>((student) => {
                      "name": student['name'],
                      "stdid": student['stdid'],
                    })
                .toList();
            dropdown2Options = subjectsData
                .map<Map<String, dynamic>>((student) => {
                      "subjectname": student['subjectname'],
                      "subjectcode": student['subjectcode'],
                    })
                .toList();
            filteredDropdown1Items = List.from(dropdown1Items);

            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = output["message"] ?? "Error: Failed to load data";
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: errorMessage!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
          );
        }
      } else {
        setState(() {
          errorMessage = "Error: Failed to load data";
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "Error: Failed to load data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudentsAndSubjects(context, widget.tutorid);
  }

  Future<void> submitdata(context, tutorid) async {
    if (selectedValue2_ == null || selectedValue2_!.trim().length < 2) {
      Fluttertoast.showToast(
          msg: "Please select Student.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (selectedValue2 == null || selectedValue2!.trim().length < 2) {
      Fluttertoast.showToast(
          msg: "Please select Subject.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      try {
        showLoadingDialog(context);
        var apipost = {
          "stdid": selectedValue2_,
          "subjectcode": selectedValue2,
          "tutorid": tutorid,
        };

        var response = await http.post(
          Uri.parse(AppUrl.assignstudentinsert),
          body: jsonEncode(apipost),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse;
          if (output["result"] == 'Y') {
            var tdata = EncryptionService.decrypt(output["data"]);
            Provider.of<TutorProvider>(context, listen: false)
                .editTutor(tutorid, tdata);

            Fluttertoast.showToast(
                msg: "Student successfully assigned!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);

            Future.delayed(Duration.zero, () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardPage(),
                ),
              );
            });
          } else {
            Fluttertoast.showToast(
                msg: output["message"],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);
          }
        } else if (response.statusCode == 401) {
          Fluttertoast.showToast(
              msg: "unable to fetch",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        } else {
          Fluttertoast.showToast(
              msg: "Something went wrong. Please try again.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER);
        }
      } catch (exception) {
        Fluttertoast.showToast(
            msg: "error accured",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      } finally {
        hideLoadingDialog(context);
      }
    }
  }

  void showCustomDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged:
                      filterDropdownItems, // Trigger the filter function as the user types
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              filteredDropdown1Items.isEmpty
                  ? const Expanded(
                      child: Text('No students found for assignment'))
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredDropdown1Items.length,
                        itemBuilder: (context, index) {
                          final item = filteredDropdown1Items[index];
                          return ListTile(
                            title: Text(item['name']),
                            onTap: () {
                              setState(() {
                                selectedValue1 = item['name'];
                                selectedValue2_ = item['stdid'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Student'),
        centerTitle: true,
        backgroundColor: color(blue),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          fetchStudentsAndSubjects(
                              context, widget.tutorid); // Retry fetch data
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color(blue),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Select a Student:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => showCustomDropdown(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedValue1 ?? 'Select a student',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Select a Subject:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Set the color of the enabled border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .black), // Set the color of the focused border
                            ),
                          ),
                          value: selectedValue2,
                          hint: const Text(
                            'Select Subject',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(179, 137, 136, 136),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color.fromARGB(179, 137, 136, 136),
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(179, 25, 25, 25),
                          ),
                          items: dropdown2Options
                              .map<DropdownMenuItem<String>>((data) {
                            return DropdownMenuItem<String>(
                              value: data['subjectcode'],
                              child: Text(data['subjectname']),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue2 = newValue;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () =>
                              {submitdata(context, widget.tutorid)},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color(blue),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, color: color(white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Function to filter the dropdown items based on the search query
  void filterDropdownItems(String query) {
    setState(() {
      searchQuery = query;
      filteredDropdown1Items = dropdown1Items
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
