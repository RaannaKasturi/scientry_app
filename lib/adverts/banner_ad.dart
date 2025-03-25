import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';

class ScientryBannerAd extends StatefulWidget {
  const ScientryBannerAd({super.key});

  @override
  ScientryBannerAdState createState() => ScientryBannerAdState();
}

class ScientryBannerAdState extends State<ScientryBannerAd> {
  BannerAd? _scientryBannerAd;

  Future<void> loadBannerAd() async {
    BannerAd(
      adUnitId: AdHelper.scientryBannerAdUnitID,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _scientryBannerAd = ad as BannerAd;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Failed to load ad: $error");
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void initState() {
    super.initState();
    loadBannerAd();
  }

  @override
  void dispose() {
    _scientryBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scientryBannerAd == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        height: _scientryBannerAd!.size.height.toDouble() + 10,
        child: AdWidget(ad: _scientryBannerAd!),
      );
    }
  }
}
