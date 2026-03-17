import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/components/widgets/Textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/providers/TutorProvider.dart';

class AddTutor extends StatefulWidget {
  final Map<String, dynamic>? tutor;
  const AddTutor({super.key, this.tutor});

  @override
  // ignore: library_private_types_in_public_api
  _AddTutorState createState() => _AddTutorState();
}

class _AddTutorState extends State<AddTutor> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'addtutorkey');
  final _picker = ImagePicker();
  File? _imageFile;
  String image64 = "";
  String editimage = "";

  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController aadharNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController descrController = TextEditingController();
  String? _genderValue;

  List<dynamic> subjectsJson = [];
  List<Map<String, String>> _selectedSubjects = [];
  Future<void> _getsubjects(context) async {
    try {
      var response = await http.get(Uri.parse(AppUrl.getsubjects));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.containsKey('output')) {
          setState(() {
            subjectsJson = data['output'];
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

  Future<void> addtutor(context, formData) async {
    if (formData["id"] == null || formData["id"] == "") {
      Fluttertoast.showToast(
          msg: "Admin ID is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["id"]?.trim().length < 5) {
      Fluttertoast.showToast(
          msg: "ID must be at least 5 characters long",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["id"].contains(' ')) {
      Fluttertoast.showToast(
        msg: "Spaces are not allowed in Tutor ID.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    } else if (formData["pwd"] == null || formData["pwd"] == "") {
      Fluttertoast.showToast(
          msg: "Password is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["pwd"]?.trim().length < 4) {
      Fluttertoast.showToast(
          msg: "Password should be greater than 4.",
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
    } else if (formData["mobileno"] == null ||
        formData["mobileno"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Mobile number is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (!RegExp(r"^\d{10}$").hasMatch(formData["mobileno"]!.trim())) {
      Fluttertoast.showToast(
          msg: "Invalid Mobile Number. It must contain exactly 10 digits.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["aadharNo"] == null ||
        formData["aadharNo"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Aadhar number is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (!RegExp(r"^\d{12}$").hasMatch(formData["aadharNo"]!.trim())) {
      Fluttertoast.showToast(
          msg: "Invalid Aadhaar Number. It must contain exactly 12 digits.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["address"] == null ||
        formData["address"]!.trim().isEmpty) {
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
    } else if (formData["subjects"].isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select at least one subject.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    } else {
      formData["image"] = "N";

      if (image64.length > 10) {
        formData["image"] = image64;
      }
      try {
        showLoadingDialog(context);

        var response = await http.post(
          Uri.parse(AppUrl.addtutor),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = EncryptionService.decrypt(jsonResponse['output']);
          if (output["result"] == 'Y') {
            _deleteallformdata();
            var newTutor = output["new_tutor"];
            Provider.of<TutorProvider>(context, listen: false)
                .addTutor(newTutor);
            Fluttertoast.showToast(
                msg: "Tutor Successfully added!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);
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

  Future<void> edittutor(context, formData) async {
    if (formData["id"] == null || formData["id"] == "") {
      Fluttertoast.showToast(
          msg: "Tutor ID is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["pwd"] == null || formData["pwd"] == "") {
      Fluttertoast.showToast(
          msg: "Password is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["pwd"]?.trim().length < 4) {
      Fluttertoast.showToast(
          msg: "Password should be greater than 4.",
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
    } else if (formData["mobileno"] == null ||
        formData["mobileno"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Mobile number is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (!RegExp(r"^\d{10}$").hasMatch(formData["mobileno"]!.trim())) {
      Fluttertoast.showToast(
          msg: "Invalid Mobile Number. It must contain exactly 10 digits.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["aadharNo"] == null ||
        formData["aadharNo"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Aadhar number is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (!RegExp(r"^\d{12}$").hasMatch(formData["aadharNo"]!.trim())) {
      Fluttertoast.showToast(
          msg: "Invalid Aadhaar Number. It must contain exactly 12 digits.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["address"] == null ||
        formData["address"]!.trim().isEmpty) {
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
    } else if (formData["subjects"].isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select at least one subject.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    } else {
      formData["image"] = image64.length > 10 ? image64 : 'N';

      try {
        showLoadingDialog(context);

        var response = await http.post(
          Uri.parse(AppUrl.edittutor),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            _deleteallformdata();
            var edittutor = EncryptionService.decrypt(output["edit_tutor"]);
            Provider.of<TutorProvider>(context, listen: false)
                .editTutor(formData["id"], edittutor);
            Fluttertoast.showToast(
                msg: "Tutor Successfully Edited!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);

            Navigator.pop(context);
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

  void _deleteImage() {
    setState(() {
      _imageFile = null;
    });
  }

  void _deleteallformdata() {
    setState(() {
      idController = TextEditingController();
      passwordController = TextEditingController();
      mobileNoController = TextEditingController();
      nameController = TextEditingController();
      aadharNoController = TextEditingController();
      addressController = TextEditingController();
      descrController = TextEditingController();
      _genderValue = null;
      _imageFile = null;
      _selectedSubjects = [];
    });
  }

  @override
  void initState() {
    if (widget.tutor != null) {
      idController = TextEditingController(text: widget.tutor!["tutorid"]);
      passwordController = TextEditingController(text: widget.tutor!["pwd"]);
      nameController = TextEditingController(text: widget.tutor!["name"]);
      mobileNoController =
          TextEditingController(text: widget.tutor!["mobileno"]);
      aadharNoController =
          TextEditingController(text: widget.tutor!["aadharno"]);
      addressController = TextEditingController(text: widget.tutor!["address"]);
      descrController = TextEditingController(text: widget.tutor!["descr"]);
      _genderValue = widget.tutor!["gender"];
      editimage =
          '${AppUrl.tutorprofilephoto}${widget.tutor!["tutorid"]}-profile.jpg';

      widget.tutor!["subjects"]
          .map((subject) => {
                _selectedSubjects.add({
                  "subjectcode": subject['subjectcode']!,
                  "subjectname": subject['subjectname']!,
                })
              })
          .toList();
    }
    _getsubjects(context);
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
        title: Text(widget.tutor != null ? 'Edit Tutor' : 'Add Tutor',
            textAlign: TextAlign.center),
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
                  child: _imageFile == null && editimage == ""
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
                      : editimage != "" && _imageFile == null
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.network(editimage,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: 200),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: _deleteImage,
                                ),
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
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
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
                    widget.tutor == null
                        ? CustomTextField(
                            controller: idController,
                            hintText: 'Tutor ID',
                            icon: Icons.person,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter Tutor ID'
                                : null,
                          )
                        : CustomTextField(
                            controller: idController,
                            hintText: 'Tutor ID',
                            icon: Icons.person,
                            validator: null,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            height: 55,
                            readOnly: true,
                          ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter Password'
                          : null,
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
                        controller: mobileNoController,
                        hintText: 'Mobile Number',
                        icon: Icons.phone,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter Mobile Number'
                            : null,
                        obscureText: false,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 5),
                    CustomTextField(
                        controller: aadharNoController,
                        hintText: 'Aadhar Number',
                        icon: Icons.credit_card,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter Aadhar Number'
                            : null,
                        obscureText: false,
                        keyboardType: TextInputType.number),

                    const SizedBox(height: 5),
                    CustomTextField(
                        controller: addressController,
                        hintText: 'Address',
                        icon: Icons.home,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter Address'
                            : null),
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
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 234, 234, 234)
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 18, top: 10),
                            child: const Text(
                              'Subjects',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Column(
                            children: subjectsJson.map((subject) {
                              return CheckboxListTile(
                                title: Text(
                                    '${subject['subjectname']} (${subject['subjectcode']})'),
                                value: _selectedSubjects.any((item) =>
                                    item['subjectcode'] ==
                                    subject['subjectcode']),
                                onChanged: (bool? selected) {
                                  if (selected == true) {
                                    setState(() {
                                      _selectedSubjects.add({
                                        "subjectcode": subject['subjectcode']!,
                                        "subjectname": subject['subjectname']!,
                                      });
                                    });
                                  } else {
                                    setState(() {
                                      _selectedSubjects.removeWhere((item) =>
                                          item['subjectcode'] ==
                                          subject['subjectcode']);
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
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
            "id": idController.text,
            "pwd": passwordController.text,
            "name": nameController.text,
            "mobileno": mobileNoController.text,
            "aadharNo": aadharNoController.text,
            "address": addressController.text,
            "gender": _genderValue,
            "subjects": _selectedSubjects,
            "descr": descrController.text
          };

          if (widget.tutor != null) {
            edittutor(context, formdata);
          } else {
            addtutor(context, formdata);
          }
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
