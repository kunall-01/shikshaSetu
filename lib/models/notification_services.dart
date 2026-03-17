import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class notificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Permission granted
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // Provisional permission
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  Future<void> initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    final bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleMessage(context, message);
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    if (initialized == null || !initialized) {
      debugPrint('Error: Local Notifications plugin failed to initialize');
    }
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print(message.data.toString());
          print(message.data["parentid"]);
          print(message.data["stdid"]);
        }
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
      }

      showNotifications(message);
    });
  }

  Future<void> showNotifications(RemoteMessage message) async {
    try {
      final int notificationId = Random.secure().nextInt(100000);

      AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importance Notifications',
        importance: Importance.max,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: 'Your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      DarwinNotificationDetails darwinNotificationDetails =
          const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      Future.delayed(Duration.zero, () {
        try {
          _flutterLocalNotificationsPlugin.show(
            notificationId, // Use a unique ID
            message.notification?.title ?? 'No Title',
            message.notification?.body ?? 'No Body',
            notificationDetails,
          );
        } catch (e) {
          debugPrint('Error displaying notification: $e');
        }
      });
    } catch (e) {
      debugPrint('Error in showNotifications: $e');
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token ?? ''; // Return empty string if token is null
  }

  Future<void> isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  Future<void> setupIntractMessage(context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }
//When app in running in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      //Navigator.push(
      //   context, MaterialPageRoute(builder: (context) => Chating()));
    }
  }
}
