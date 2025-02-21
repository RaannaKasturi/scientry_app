import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';

class TestAds extends StatefulWidget {
  const TestAds({super.key});

  @override
  State<TestAds> createState() => _TestAdsState();
}

class _TestAdsState extends State<TestAds> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: AdHelper.footerAdUnitID,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Failed to load ad: $error");
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          _bannerAd == null ? const SizedBox() : AdWidget(ad: _bannerAd!),
      body: const Center(
        child: Text('Test Ads'),
      ),
    );
  }
}
