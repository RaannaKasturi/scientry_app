import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  final _instance = FirebaseAnalytics.instance;

  Future<void> logAnalyticsEvent(String name) async {
    await _instance
        .logEvent(
          name: name,
          callOptions: AnalyticsCallOptions(
            global: true,
          ),
        )
        .then((value) => debugPrint('Analytics: Event $name logged'));
  }
}
