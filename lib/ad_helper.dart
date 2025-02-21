import 'dart:io';

class AdHelper {
  static String get footerAdUnitID {
    if (Platform.isAndroid) {
      return "ca-app-pub-8253303708714765/7672911816";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8253303708714765/9592422163";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
