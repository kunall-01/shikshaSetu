import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/components/widgets/Textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';
import 'package:shikshasetutution/portals/admin/providers/ParentchildProvider.dart';

class AddStudent extends StatefulWidget {
  final String selparentid;
  const AddStudent({super.key, required this.selparentid});

  @override
  // ignore: library_private_types_in_public_api
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'add_AddStudentStatekey');
  final _picker = ImagePicker();
  File? _imageFile;
  String image64 = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController standardController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  String? _genderValue;
  String? parentid;

  List<dynamic> tutorJson = [];
  List<dynamic> parentJson = [];
  List<Map<String, String>> _selectedtutors = [];

  Future<void> _getparentandtutorlist(context) async {
    try {
      var response = await http.get(Uri.parse(AppUrl.getparentandtutorlist));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('output')) {
          setState(() {
            parentJson = data['output']['parents'];
            tutorJson = data['output']['tutors'];
          });
        }
      }
    } catch (exception) {
      Fluttertoast.showToast(
          msg: exception.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    } finally {}
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                    final bytes = File(pickedFile.path).readAsBytesSync();
                    image64 = base64Encode(bytes);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                    final bytes = File(pickedFile.path).readAsBytesSync();
                    image64 = base64Encode(bytes);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitdata(context, formData) async {
    if (formData["parentid"] == null ||
        formData["parentidparentid"] == "" ||
        formData["parentid"]!.trim().length < 5) {
      Fluttertoast.showToast(
          msg: "Please select Parent.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["name"] == null ||
        formData["name"]?.trim().length < 3) {
      Fluttertoast.showToast(
          msg: "Name is Required or Invalid.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["age"] == null || formData["age"]?.trim().length <= 0) {
      Fluttertoast.showToast(
          msg: "Age is Required or Invalid.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["standard"] == null ||
        formData["standard"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Address is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["gender"] == null ||
        formData["gender"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Gender is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (!["Male", "Female", "Other"]
        .contains(formData["gender"]!.trim())) {
      Fluttertoast.showToast(
          msg: "Invalid Gender. It must be 'Male', 'Female', or 'Other'.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      formData["image"] = "N";

      if (image64.length > 10) {
        formData["image"] = image64;
      }

      try {
        showLoadingDialog(context);

        var response = await http.post(
          Uri.parse(AppUrl.addstudent),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            _deleteallformdata();
            var parentid = formData["parentid"];
            var edittutor = output["data"][0];
            Provider.of<Parentchildprovider>(context, listen: false)
                .editparentchilds(parentid, edittutor);
            Fluttertoast.showToast(
                msg: "Student Successfully added!",
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
                msg: output["result"],
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

  void _deleteImage() {
    setState(() {
      _imageFile = null;
    });
  }

  void _deleteallformdata() {
    setState(() {
      standardController = TextEditingController();
      ageController = TextEditingController();
      nameController = TextEditingController();
      descrController = TextEditingController();
      _genderValue = null;
      _imageFile = null;
      _selectedtutors = [];
    });
  }

  @override
  void initState() {
    parentid = widget.selparentid;
    _getparentandtutorlist(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Student', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: color(lightblue),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color(blue), width: 2),
                    color: Colors.grey[200],
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: color(blue)),
                            const SizedBox(height: 10),
                            const Text('Upload your profile photo',
                                textAlign: TextAlign.center),
                          ],
                        )
                      : Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(_imageFile!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 200),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _deleteImage,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 234, 234, 234)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.list,
                            color: Color.fromARGB(255, 35, 35, 35),
                            size: 22,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: AbsorbPointer(
                              // Prevent user interaction
                              absorbing:
                                  true, // Set to false to enable selection
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                value: parentid,
                                hint: const Text(
                                  'Select Parent',
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
                                // ignore: unnecessary_null_comparison
                                items: parentJson != null
                                    ? parentJson.map<DropdownMenuItem<String>>(
                                        (parent) {
                                        return DropdownMenuItem<String>(
                                          value: parent['parentid'],
                                          child: Text(parent['name']),
                                        );
                                      }).toList()
                                    : [],
                                onChanged: null, // Disable selection
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Name',
                      icon: Icons.person_add,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter Name' : null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                        controller: standardController,
                        hintText: 'Standard',
                        icon: Icons.star,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter Standard'
                            : null),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: ageController,
                      hintText: 'Age',
                      icon: Icons.access_time,
                      validator: null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 5),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 234, 234, 234)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 18, top: 10),
                            child: const Text(
                              'Gender',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Radio<String>(
                                value: 'Male',
                                groupValue: _genderValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    _genderValue = value;
                                  });
                                },
                              ),
                              const Text('Male'),
                              Radio<String>(
                                value: 'Female',
                                groupValue: _genderValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    _genderValue = value;
                                  });
                                },
                              ),
                              const Text('Female'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Subjects Selection

                    CustomTextField(
                      controller: descrController,
                      hintText: 'Description (Optional)',
                      icon: Icons.description,
                      validator: null,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      height: 150,
                    ),

                    const SizedBox(height: 16),
                    buildLoginButton(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Container(
      height: 48,
      width: 500,
      decoration: BoxDecoration(
        color: color('#2f474e'),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          FocusScope.of(context).unfocus();

          var formdata = {
            "parentid": parentid,
            "name": nameController.text,
            "standard": standardController.text,
            "age": ageController.text,
            "gender": _genderValue,
            "tutors": _selectedtutors,
            "descr": descrController.text
          };

          submitdata(context, formdata);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
