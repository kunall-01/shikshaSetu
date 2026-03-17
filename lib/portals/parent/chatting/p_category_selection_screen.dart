import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/parent/chatting/p_contact_selection_screen.dart';

class PCategorySelectionScreen extends StatelessWidget {
  const PCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String selectedCategory = 'Tutor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Type'),
        backgroundColor: color(lightblack),
        foregroundColor: color(white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Choose Type',
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: color(deepseablue),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Tutor', child: Text('Tutor')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin'))
              ],
              onChanged: (value) {
                selectedCategory = value!;
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PContactSelectionScreen(
                          category: selectedCategory,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: color(deepseablue),
                      foregroundColor: color(white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.0))),
                  child: const Text('Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
