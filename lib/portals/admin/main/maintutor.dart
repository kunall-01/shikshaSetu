import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/admin/main/tutorcard.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/portals/admin/providers/TutorProvider.dart';

class Maintutor extends StatefulWidget {
  const Maintutor({super.key});

  @override
  State<Maintutor> createState() => _MaintutorState();
}

class _MaintutorState extends State<Maintutor> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String searchQuery = "";
  List<dynamic> filteredUsers = [];
  String selectedFilter = "unblock";
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoading(context);
      Provider.of<TutorProvider>(context, listen: false)
          .fetchTutors()
          .then((_) {
        setState(() {
          filteredUsers =
              Provider.of<TutorProvider>(context, listen: false).tutors;
          onFilterChanged(selectedFilter);
          hideLoadingDialog(context);
        });
      });
    });
  }

  void filterByStatus(String filter, List<dynamic> tutors) {
    setState(() {
      if (filter == "all") {
        filteredUsers = tutors; // Include all tutors
      } else if (filter == "block") {
        filteredUsers = tutors.where((user) => user['isblock'] == 1).toList();
      } else if (filter == "unblock") {
        filteredUsers = tutors.where((user) => user['isblock'] == 0).toList();
      }
    });
  }

  void filterUsers(String query, String filter) {
    final tutors = Provider.of<TutorProvider>(context, listen: false).tutors;

    // Step 1: Filter based on search query
    List<dynamic> searchFilteredUsers = tutors.where((user) {
      return query.isEmpty ||
          user['name']!.toLowerCase().contains(query.toLowerCase()) ||
          user['tutorid']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Step 2: Apply the selected filter (status filter: block, unblock, all)
    filterByStatus(filter, searchFilteredUsers);
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterUsers(query,
          selectedFilter); // Call filter with both query and selected filter
    });
  }

  void onFilterChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedFilter = value; // Update selected filter
      });
      filterUsers(searchController.text,
          value); // Call filter with selected filter and current search query
    }
  }

  void unfocusSearchBox() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: unfocusSearchBox,
        child: Consumer<TutorProvider>(
          builder: (context, tutorProvider, child) {
            final tutors =
                filteredUsers.isNotEmpty ? filteredUsers : tutorProvider.tutors;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Tutor List", style: TextStyle(fontSize: 24)),
                    ),
                    GestureDetector(
                      onTap: () {
                        showLoading(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<TutorProvider>(context, listen: false)
                              .fetchTutors()
                              .then((_) {
                            setState(() {
                              filteredUsers = Provider.of<TutorProvider>(
                                      context,
                                      listen: false)
                                  .tutors;
                              onFilterChanged(selectedFilter);
                              hideLoadingDialog(context);
                            });
                          });
                        });
                      },
                      child: Icon(
                        Icons.refresh,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Tutor',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: color(deepseablue),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: color(darkpink),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: onSearchChanged,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                width: 1, color: color(deepseablue))),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: DropdownButton<String>(
                          value: selectedFilter,
                          items: const [
                            DropdownMenuItem(
                              value: "all",
                              child: Text("All"),
                            ),
                            DropdownMenuItem(
                              value: "block",
                              child: Text("Block"),
                            ),
                            DropdownMenuItem(
                              value: "unblock",
                              child: Text("Unblock"),
                            ),
                          ],
                          onChanged: onFilterChanged,
                          underline: const SizedBox(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: tutors.length,
                    itemBuilder: (context, index) {
                      final tutor = tutors[index];
                      return TutorCard(tutor: tutor);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
