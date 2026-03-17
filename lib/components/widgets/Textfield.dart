import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final double height;
  final bool readOnly;
  final Function()? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.height = 55,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: height,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 234, 234, 234).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.5))),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: InputBorder.none,
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 35, 35, 35),
              size: 22,
            ),
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(179, 137, 136, 136),
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Color.fromARGB(179, 25, 25, 25),
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
      ),
    );
  }
}
