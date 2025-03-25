import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:scientry/firebase_options.dart';
import 'package:scientry/screens/splashscreen.dart';
import 'package:scientry/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  unawaited(MobileAds.instance.initialize());
  runApp(
    Provider<SharedPreferences>.value(
      value: sharedPreferences,
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(context),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientry',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: SplashScreen(),
    );
  }
}
