import 'dart:io';

class AdHelper {
  static String get scientryBannerAdUnitID {
    if (Platform.isAndroid) {
      return "ca-app-pub-8253303708714765/7672911816";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8253303708714765/9592422163";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get scientryNativeAdUnitID {
    if (Platform.isAndroid) {
      return "ca-app-pub-8253303708714765/1550861179";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8253303708714765/7411598494";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get scientryInterstitialAdUnitID {
    if (Platform.isAndroid) {
      return "ca-app-pub-8253303708714765/4980876275";
    } else if (Platform.isIOS) {
      return "ca-app-pub-8253303708714765/1253384252";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
