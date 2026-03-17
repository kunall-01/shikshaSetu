import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/default.dart';
import 'package:shikshasetutution/models/authconstant.dart';
import 'package:shikshasetutution/models/user.dart';
import 'package:shikshasetutution/portals/tutors/chatting/notification.dart';
import 'package:shikshasetutution/portals/tutors/chatting/t_category_selection_screen.dart';
import 'package:shikshasetutution/portals/tutors/main/tutorhome.dart';
import 'package:shikshasetutution/portals/tutors/other/tutorchangepwd.dart';
import 'package:shikshasetutution/portals/tutors/other/tutorprofile.dart';

String primarycolor = deepseablue;
String secondarycolor = white;

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ListQueue<int> navigationQueue = ListQueue();
  List<Widget> pageList = [];
  int _currentIndex = 0;
  User? _user;

  void checkauth(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userid = prefs.getString("userid");
    if (userid == null || userid == "" || userid.isEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Default()),
        (route) => false,
      );
    }
  }

  Future<void> _loadUser() async {
    try {
      User user = await UserPreferences().getUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      setState(() {
        Fluttertoast.showToast(
            msg: "Something went wrong. Please try again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      });
    }
  }

  @override
  void initState() {
    pageList.add(const TutorHome());
    _loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkauth(context);
    return PopScope(
      canPop: navigationQueue.isNotEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (navigationQueue.isEmpty) {
            // Store the current context
            final currentContext = context;
            final bool? shouldExit = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Confirm'),
                  content: const Text('Do you want to exit the App?'),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false), // Do not exit
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true), // Exit
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );
            if (currentContext.mounted && (shouldExit ?? false)) {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            }
          } else {
            setState(() {
              navigationQueue.removeLast();
              int position = navigationQueue.isEmpty ? 0 : navigationQueue.last;
              _currentIndex = position;
            });
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: color(primarycolor),
          title: SizedBox(
            width: 130,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/logohr-white.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          // centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChatNotificationScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.notifications,
                size: 30,
                color: color(secondarycolor),
              ),
            ),
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.menu,
                  size: 30,
                  color: color(secondarycolor),
                ),
              ),
            ),
          ],
        ),
        drawer: CustomDrawer(user: _user),
        body: IndexedStack(
          index: _currentIndex,
          children: pageList,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TCategorySelectionScreen(),
              ),
            );
          }, // Chat icon
          tooltip: 'Chat', // Optional: Tooltip to describe the button
          backgroundColor: color(primarycolor),
          child: const Icon(
              Icons.chat), // Optional: Customize the background color
        ),
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final User? user;
  const CustomDrawer({super.key, this.user});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Section
          DrawerHeader(
            decoration: BoxDecoration(
              color: color(primarycolor),
            ),
            child: Row(
              children: [
                // Profile Photo
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      '${AppUrl.tutorprofilephoto}${user!.userid}-profile.jpg'),
                ),
                const SizedBox(width: 16),
                // Name and Edit Icon
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user!.name}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color(white)),
                      ),
                      Row(
                        children: [
                          Text(
                            '${user!.userid}',
                            style: TextStyle(
                              color: color(lightblue),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu Section
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.person,
                  title: "My Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Tutorprofile(),
                      ),
                    );
                  },
                ),
                // _buildMenuItem(
                //   icon: Icons.schedule,
                //   title: "Meeting Schedule",
                //   onTap: () {
                //     // Handle Meeting Schedule
                //     Navigator.pop(context);
                //   },
                // ),
                _buildMenuItem(
                  icon: Icons.lock,
                  title: "Change Password",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Tutorchangepwd(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color(primarycolor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Widget cancelButton = TextButton(
                  child: const Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                );
                Widget continueButton = TextButton(
                  child: const Text("Yes"),
                  onPressed: () {
                    UserPreferences().removeUser();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Default()),
                      (Route<dynamic> route) => false,
                    );
                  },
                );

                AlertDialog alert = AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text("Are you sure to logout?"),
                  actions: [
                    cancelButton,
                    continueButton,
                  ],
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color(deepseablue)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
