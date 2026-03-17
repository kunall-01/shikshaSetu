import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/admin/main/childerndetail.dart';
import 'package:shikshasetutution/portals/admin/menupages/addstudent.dart';

class Parentdetail extends StatelessWidget {
  final Map<String, dynamic> parent;

  const Parentdetail({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Parent Detail'),
        centerTitle: true,
        backgroundColor: color(blue),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: color(blue),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        parent["name"].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  buildDetailCard(
                    context,
                    title: "Contact Info",
                    icon: Icons.phone,
                    details: [
                      "Mobile: ${parent["mobileno"]}",
                      "Address: ${parent["address"]}",
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDetailCard(
                    context,
                    title: "Personal Info",
                    icon: Icons.person,
                    details: [
                      "Date of Enrollment: ${parent["doe"]}",
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDetailCard(
                    context,
                    title: "Description",
                    icon: Icons.description,
                    details: [
                      parent["descr"] != ""
                          ? parent["descr"]
                          : "No description provided.",
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDetailCardstd(
                    context,
                    title: "Children",
                    icon: Icons.person_2,
                    details: parent["children"].isNotEmpty
                        ? parent["children"].map<Widget>((children) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChildrenDetail(subject: children),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 0,
                                color: const Color.fromARGB(255, 237, 237, 237),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.circle,
                                        size: 5,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              children['name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    8), // Add space between name and ID
                                            Text(
                                              "ID: ${children['stdid']}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                        : [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                "No students have been assigned yet.",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddStudent(
                selparentid: parent["parentid"],
              ),
            ),
          );
        }, // Chat icon
        tooltip: 'Add Student',
        backgroundColor: color(blue),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper Method for Detail Cards
  Widget buildDetailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> details,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color(blue), size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color(blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildDetailCardstd(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> details, // Change type to List<Widget>
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color(blue), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color(blue),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color(blue), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Total children: ${parent["children"]?.length ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color(white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...details,
          ],
        ),
      ),
    );
  }
}
