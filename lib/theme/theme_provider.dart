import 'package:flutter/material.dart';
import 'package:scientry/theme/theme.dart';
import 'package:scientry/util.dart';

class ThemeProvider with ChangeNotifier {
  late TextTheme textTheme;
  late MaterialTheme theme;

  ThemeProvider(BuildContext context) {
    textTheme = createTextTheme(context, "Syne", "Syne");
    theme = MaterialTheme(textTheme);
  }

  ThemeData _themeData = ThemeData.light();
  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == ThemeData.light()) {
      _themeData = ThemeData.dark();
    } else {
      _themeData = ThemeData.light();
    }
    notifyListeners();
  }
}
