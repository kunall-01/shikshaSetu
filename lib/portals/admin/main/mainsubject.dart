import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/admin/main/subjectcard.dart';
import 'package:shikshasetutution/portals/admin/providers/SubjectsProvider.dart';

class Mainsubject extends StatefulWidget {
  const Mainsubject({super.key});

  @override
  State<Mainsubject> createState() => _MainsubjectState();
}

class _MainsubjectState extends State<Mainsubject> {
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String searchQuery = "";
  List<dynamic> filtereddata = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoading(context);
      Provider.of<Subjectsprovider>(context, listen: false)
          .getsubjects()
          .then((_) {
        setState(() {
          filtereddata =
              Provider.of<Subjectsprovider>(context, listen: false).allsubject;
          hideLoadingDialog(context);
        });
      });
    });
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filtereddata =
            Provider.of<Subjectsprovider>(context, listen: false).allsubject;
      });
    } else {
      setState(() {
        filtereddata = Provider.of<Subjectsprovider>(context, listen: false)
            .allsubject
            .where((d) {
          return d['subjectname']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              d['subjectcode']!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterUsers(query);
    });
  }

  void unfocusSearchBox() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: unfocusSearchBox,
        child: Consumer<Subjectsprovider>(
          builder: (context, tutorProvider, child) {
            final alldata = filtereddata.isNotEmpty
                ? filtereddata
                : tutorProvider.allsubject;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child:
                          Text("Subject List", style: TextStyle(fontSize: 24)),
                    ),
                    GestureDetector(
                      onTap: () {
                        showLoading(context);

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Provider.of<Subjectsprovider>(context, listen: false)
                              .getsubjects()
                              .then((_) {
                            setState(() {
                              filtereddata = Provider.of<Subjectsprovider>(
                                      context,
                                      listen: false)
                                  .allsubject;
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
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: alldata.length,
                      itemBuilder: (context, index) {
                        final subject = alldata[index];
                        return Subjectcard(mydata: subject);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
