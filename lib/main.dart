import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shikshasetutution/components/common.dart';
import 'package:shikshasetutution/default.dart';
import 'package:shikshasetutution/models/notification_services.dart';
import 'package:shikshasetutution/models/user.dart';
import 'package:shikshasetutution/portals/account/login.dart';
import 'package:shikshasetutution/portals/admin/DashboardPage.dart';
import 'package:shikshasetutution/portals/admin/providers/ParentchildProvider.dart';
import 'package:shikshasetutution/portals/admin/providers/SubjectsProvider.dart';
import 'package:shikshasetutution/portals/admin/providers/TutorProvider.dart';
import 'package:shikshasetutution/portals/admin/providers/adminProvider.dart';
import 'package:shikshasetutution/portals/parent/dashboardparent.dart';
import 'package:shikshasetutution/portals/tutors/dashboardtutor.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String appName = 'Unknown';
  String packageName = 'Unknown';
  String version = 'Unknown';
  String buildNumber = 'Unknown';
  // ignore: non_constant_identifier_names
  notificationServices NotificationServices = notificationServices();
  @override
  void initState() {
    //NotificationServices.isTokenRefresh();
    NotificationServices.requestNotificationPermissions();
    NotificationServices.firebaseInit(context);
    NotificationServices.setupIntractMessage(context);
    NotificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('Device Tokken');
        print(value);
      }
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<User> getUserData() => UserPreferences().getUser();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: UserProvider()),
        ChangeNotifierProvider(create: (_) => TutorProvider()),
        ChangeNotifierProvider(create: (_) => Parentchildprovider()),
        ChangeNotifierProvider(create: (_) => Subjectsprovider()),
        ChangeNotifierProvider(create: (_) => Adminprovider()),
      ],
      child: MaterialApp(
        title: 'Shiksha Setu Home Tution',
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const Login(
                logintype: '',
              ),
          '/default': (context) => const Default(),
        },
        home: FutureBuilder(
            future: getUserData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Scaffold(
                    body: SafeArea(
                        child: Scaffold(
                      body: SafeArea(
                        child: Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    )),
                  );
                default:
                  if (snapshot.hasError) {
                    return Scaffold(
                      body: SafeArea(
                        child: Center(
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      ),
                    );
                  } else if (snapshot.data?.token != null) {
                    Provider.of<UserProvider>(context, listen: false)
                        .setUser(snapshot.data);
                    if (snapshot.data?.type == "Admin") {
                      return const AdminDashboardPage();
                    } else if (snapshot.data?.type == "Tutor") {
                      return const TutorDashboard();
                    } else if (snapshot.data?.type == "Parent") {
                      return const ParentDasboard();
                    } else {
                      return const Default();
                    }
                  } else if (snapshot.data?.token == null) {
                    return const Default();
                  } else {
                    return const Default();
                  }
              }
            }),
        theme: ThemeData(
          primaryColor: color(lightblue),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(color(darkpink)),
          ).copyWith(
            secondary: createMaterialColor(color(deepseablue)),
          ),
          scaffoldBackgroundColor: Colors.grey[100],
        ),
      ),
    );
  }
}
