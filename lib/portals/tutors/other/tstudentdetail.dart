import 'package:flutter/material.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/portals/tutors/other/showhomework.dart';
import 'package:shikshasetutution/portals/tutors/other/showmarks.dart';

class Tstudentdetail extends StatefulWidget {
  final String stdid;
  const Tstudentdetail({super.key, required this.stdid});

  @override
  State<Tstudentdetail> createState() => _TstudentdetailState();
}

class _TstudentdetailState extends State<Tstudentdetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Homework'),
            Tab(text: 'Marks'),
          ],
        ),
        backgroundColor: color(deepseablue),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Showhomework(stdid: widget.stdid),
          Showmarks(stdid: widget.stdid),
        ],
      ),
    );
  }
}
