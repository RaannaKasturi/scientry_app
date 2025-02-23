import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _notificationPlugin = FlutterLocalNotificationsPlugin();
  final bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // INITIALIZE NOTIFICATION SERVICE
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Initialize android service
    const initSettingsAndroid =
        AndroidInitializationSettings('@drawable/brandlogo');

    // Initialize iOS service
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialize the notification service
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );
    await _notificationPlugin.initialize(initSettings);
  }

  // NOTIFICATION DETAILS
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        '0',
        'Scientry',
        channelDescription: 'Science Simplified, Knowledge Amplified',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // SHOW NOTIFICATION
  Future<void> showNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    return await _notificationPlugin.show(
      id ?? 0,
      title,
      body,
      notificationDetails(),
    );
  }
}
