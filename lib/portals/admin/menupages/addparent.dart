import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/components/widgets/Textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shikshasetutution/models/Encryption.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/portals/admin/providers/ParentchildProvider.dart';

class AddParent extends StatefulWidget {
  final Map<String, dynamic>? parents;
  const AddParent({super.key, this.parents});

  @override
  // ignore: library_private_types_in_public_api
  _AddParentState createState() => _AddParentState();
}

class _AddParentState extends State<AddParent> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'addparentkey');

  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController descrController = TextEditingController();

  @override
  void initState() {
    if (widget.parents != null) {
      idController = TextEditingController(text: widget.parents!["parentid"]);
      passwordController = TextEditingController(text: widget.parents!["pwd"]);
      nameController = TextEditingController(text: widget.parents!["name"]);
      mobileNoController =
          TextEditingController(text: widget.parents!["mobileno"]);

      addressController =
          TextEditingController(text: widget.parents!["address"]);
      descrController = TextEditingController(text: widget.parents!["descr"]);
    }
    super.initState();
  }

  Future<void> submitdata(context, formData) async {
    if (formData["id"] == null || formData["id"] == "") {
      Fluttertoast.showToast(
          msg: "Parent ID is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else if (formData["id"]?.trim().length < 5) {
      Fluttertoast.showToast(
          msg: "ID must be at least 5 characters long",
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
    } else if (formData["address"] == null ||
        formData["address"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Address is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      try {
        showLoadingDialog(context);

        var response = await http.post(
          Uri.parse(AppUrl.addparent),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            _deleteallformdata();
            Fluttertoast.showToast(
                msg: "Parent Successfully added!",
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

  Future<void> submiteditdata(context, formData) async {
    if (formData["id"] == null || formData["id"] == "") {
      Fluttertoast.showToast(
          msg: "Parent ID is required.",
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
    } else if (formData["address"] == null ||
        formData["address"]!.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Address is required.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
      return;
    } else {
      try {
        showLoadingDialog(context);

        var response = await http.post(
          Uri.parse(AppUrl.editparent),
          body: jsonEncode(formData),
          headers: {'content-type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          var output = jsonResponse['output'];
          if (output["result"] == 'Y') {
            _deleteallformdata();
            var editparent = EncryptionService.decrypt(output["edit_parent"]);
            Provider.of<Parentchildprovider>(context, listen: false)
                .editparentchilds(formData["id"], editparent);
            Fluttertoast.showToast(
                msg: "Parent Successfully Edited!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER);

            Navigator.pop(context);
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

  void _deleteallformdata() {
    setState(() {
      idController = TextEditingController();
      passwordController = TextEditingController();
      mobileNoController = TextEditingController();
      nameController = TextEditingController();
      addressController = TextEditingController();
      descrController = TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Parent', textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: color(lightblue),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    widget.parents == null
                        ? CustomTextField(
                            controller: idController,
                            hintText: 'Parent ID',
                            icon: Icons.person,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Please enter Parent ID'
                                : null,
                          )
                        : CustomTextField(
                            controller: idController,
                            hintText: 'Parent ID',
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
                      controller: addressController,
                      hintText: 'Address',
                      icon: Icons.home,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter Address'
                          : null,
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      controller: descrController,
                      hintText: 'Description (Optional)',
                      icon: Icons.home,
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
            "address": addressController.text,
            "descr": descrController.text
          };
          if (widget.parents != null) {
            submiteditdata(context, formdata);
          } else {
            submitdata(context, formdata);
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
