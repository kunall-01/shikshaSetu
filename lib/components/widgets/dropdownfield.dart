import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final String hintText;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 55,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 234, 234, 234).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 35, 35, 35),
              size: 22,
            ),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(179, 137, 136, 136),
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color.fromARGB(179, 137, 136, 136),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: Color.fromARGB(179, 25, 25, 25),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
