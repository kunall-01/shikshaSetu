import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/default.dart';
import 'package:shikshasetutution/models/user.dart';
import 'package:shikshasetutution/portals/parent/chatting/p_category_selection_screen.dart';
import 'package:shikshasetutution/portals/parent/main/parenthome.dart';
import 'package:shikshasetutution/portals/parent/others/parentchangepwd.dart';
import 'package:shikshasetutution/portals/parent/others/parentprofile.dart';

class ParentDasboard extends StatefulWidget {
  const ParentDasboard({super.key});

  @override
  State<ParentDasboard> createState() => _ParentDasboardState();
}

class _ParentDasboardState extends State<ParentDasboard> {
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
    pageList.add(const Parenthome());
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
          backgroundColor: color(parentthemecolor),
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
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.menu,
                  size: 30,
                  color: color(white),
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
                builder: (context) => const PCategorySelectionScreen(),
              ),
            );
          }, // Chat icon
          tooltip: 'Chat', // Optional: Tooltip to describe the button
          backgroundColor: color(parentthemecolor),
          child: const Icon(
              Icons.chat), // Optional: Customize the background color
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    navigationQueue.removeWhere((element) => element == index);
    navigationQueue.addLast(index);
    if (index == 0) {
      navigationQueue.clear();
    }
    setState(() {
      _currentIndex = index;
    });
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
              color: color(parentthemecolor),
            ),
            child: Row(
              children: [
                // Profile Photo
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      color(skin), // Background color for the text fallback
                  child: Text(
                    user!.name![0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white, // Text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                            style: const TextStyle(
                              color: Color.fromARGB(255, 185, 214, 243),
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
                        builder: (context) => const Parentprofile(),
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
                        builder: (context) => const Parentchangepwd(),
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
                backgroundColor: color(parentthemecolor),
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
