import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/admin/main/parentcard.dart';
import 'package:shikshasetutution/portals/admin/providers/ParentchildProvider.dart';

class Mainparent extends StatefulWidget {
  const Mainparent({super.key});

  @override
  State<Mainparent> createState() => _MainparentState();
}

class _MainparentState extends State<Mainparent> {
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
      Provider.of<Parentchildprovider>(context, listen: false)
          .fetchParentChild()
          .then((_) {
        setState(() {
          filteredUsers =
              Provider.of<Parentchildprovider>(context, listen: false)
                  .parentchilds;
          onFilterChanged(selectedFilter);
          hideLoadingDialog(context);
        });
      });
    });
  }

  void filterByStatus(String filter, List<dynamic> parents) {
    setState(() {
      if (filter == "all") {
        filteredUsers = parents; // Include all tutors
      } else if (filter == "block") {
        filteredUsers = parents.where((user) => user['isblock'] == 1).toList();
      } else if (filter == "unblock") {
        filteredUsers = parents.where((user) => user['isblock'] == 0).toList();
      }
    });
  }

  // void filterUsers(String query, String filter) {
  //   if (query.isEmpty) {
  //     setState(() {
  //       filteredUsers = Provider.of<Parentchildprovider>(context, listen: false)
  //           .parentchilds;
  //     });
  //   } else {
  //     setState(() {
  //       filteredUsers = Provider.of<Parentchildprovider>(context, listen: false)
  //           .parentchilds
  //           .where((user) {
  //         return user['name']!.toLowerCase().contains(query.toLowerCase()) ||
  //             user['parentid']!.toLowerCase().contains(query.toLowerCase()) ||
  //             user['mobileno']!.toLowerCase().contains(query.toLowerCase());
  //       }).toList();
  //     });
  //   }
  // }

  void filterUsers(String query, String filter) {
    final parents =
        Provider.of<Parentchildprovider>(context, listen: false).parentchilds;

    // Step 1: Filter based on search query
    List<dynamic> filteredUsers = parents.where((user) {
      return query.isEmpty ||
          user['name']!.toLowerCase().contains(query.toLowerCase()) ||
          user['parentid']!.toLowerCase().contains(query.toLowerCase()) ||
          user['mobileno']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Step 2: Apply the selected filter (status filter: block, unblock, all)
    filterByStatus(filter, filteredUsers);
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

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterUsers(query, selectedFilter);
    });
  }

  void unfocusSearchBox() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    onFilterChanged(selectedFilter);
    return Scaffold(
      body: GestureDetector(
        onTap: unfocusSearchBox,
        child: Consumer<Parentchildprovider>(
          // ignore: non_constant_identifier_names
          builder: (context, Pparentchildprovider, child) {
            final parentchilds = filteredUsers.isNotEmpty
                ? filteredUsers
                : Pparentchildprovider.parentchilds;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          Text("Parent List", style: TextStyle(fontSize: 24)),
                    ),
                    GestureDetector(
                      onTap: () {
                        showLoading(context);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<Parentchildprovider>(context,
                                  listen: false)
                              .fetchParentChild()
                              .then((_) {
                            setState(() {
                              filteredUsers = Provider.of<Parentchildprovider>(
                                      context,
                                      listen: false)
                                  .parentchilds;
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
                            labelText: 'Search Parent',
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
                    itemCount: parentchilds.length,
                    itemBuilder: (context, index) {
                      final parent = parentchilds[index];
                      return ParentCard(parent: parent);
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
