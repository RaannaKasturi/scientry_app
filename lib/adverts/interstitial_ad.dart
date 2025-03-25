import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';

class ScientryInterstitialAd {
  static void showAd({
    required BuildContext context,
  }) {
    InterstitialAd.load(
      adUnitId: AdHelper.scientryInterstitialAdUnitID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load an ad: $error'),
            ),
          );
        },
      ),
    );
  }
}
