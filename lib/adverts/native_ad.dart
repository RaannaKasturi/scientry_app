import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';

class ScientryNativeAd extends StatefulWidget {
  const ScientryNativeAd({super.key});

  @override
  ScientryNativeAdState createState() => ScientryNativeAdState();
}

class ScientryNativeAdState extends State<ScientryNativeAd> {
  NativeAd? _scientryNativeAd;

  Future<void> loadNativeAd() async {
    NativeAd(
      adUnitId: AdHelper.scientryNativeAdUnitID,
      request: const AdRequest(),
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _scientryNativeAd = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("singlePostAds: $error");
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
    ).load();
  }

  @override
  void initState() {
    super.initState();
    loadNativeAd();
  }

  @override
  void dispose() {
    _scientryNativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scientryNativeAd == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
        height: 110,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: AdWidget(
          ad: _scientryNativeAd!,
        ),
      );
    }
  }
}
