import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await FirebasePushApi().handleMessage(message);
}

class FirebasePushApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidNotificationDetails = const AndroidNotificationDetails(
    'Notifications',
    'General Notifications and Updates from Scientry',
    channelDescription: 'General Notifications and Updates from Scientry',
    icon: '@drawable/brand',
    importance: Importance.max,
    playSound: true,
    channelShowBadge: true,
    enableVibration: true,
    enableLights: true,
    visibility: NotificationVisibility.public,
  );

  final _iOSNotificationDetails = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $fcmToken");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotification();
  }

  Future initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/brand');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _localNotifications.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (payload) async {
      final message = RemoteMessage.fromMap(jsonDecode(payload.toString()));
      handleMessage(message);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!;
    await platform.createNotificationChannel(
      AndroidNotificationChannel(
        'Notifications',
        'General Notifications and Updates from Scientry',
        description: 'General Notifications and Updates from Scientry',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );
  }

  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          payload: jsonEncode(message.toMap()),
          NotificationDetails(
            android: _androidNotificationDetails,
            iOS: _iOSNotificationDetails,
          ));
    });
  }
}
