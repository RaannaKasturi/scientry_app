import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';
import 'package:scientry/info_pages/no_data_found.dart';
import 'package:scientry/static/post_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  SharedPreferences? prefs;
  BannerAd? _allScreenFooter;
  NativeAd? _afterCarouselTitleAd;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  initializeBannerAd() {
    BannerAd(
      adUnitId: AdHelper.allScreenFooterAdUnit,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _allScreenFooter = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Failed to load ad: $error");
          ad.dispose();
        },
      ),
    ).load();
  }

  initializeNativeAd() {
    NativeAd(
      adUnitId: AdHelper.afterCarouselTitleAdUnit,
      request: const AdRequest(),
      factoryId: 'adFactoryExample',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _afterCarouselTitleAd = ad as NativeAd;
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

  Future<void> _loadPrefs() async {
    initializeBannerAd();
    initializeNativeAd();
    prefs = await SharedPreferences.getInstance();
  }

  List<Post> getPosts() {
    if (prefs == null) return [];
    List<String> postStrings = prefs!.getStringList('bookmarkedPosts') ?? [];
    return postStrings.map((str) {
      final jsonData = jsonDecode(str);
      return Post(
        title: jsonData['title'] as String,
        link: jsonData['link'] as String,
        image: jsonData['image'] as String,
        category: jsonData['category'] as String,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Bookmarks'),
      ),
      bottomNavigationBar: _allScreenFooter != null
          ? Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              height: _allScreenFooter!.size.height.toDouble() + 10,
              child: AdWidget(
                ad: _allScreenFooter!,
              ),
            )
          : null,
      body: prefs == null || getPosts().isEmpty
          ? const Center(
              child: NoDataFound(
                noDataFoundText: "No Bookmarked Posts Found",
              ),
            )
          : RawScrollbar(
              thumbColor: Theme.of(context).colorScheme.primary,
              thickness: 5,
              radius: Radius.circular(10),
              trackVisibility: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      _afterCarouselTitleAd != null
                          ? Container(
                              height: 100,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              child: AdWidget(
                                ad: _afterCarouselTitleAd!,
                              ),
                            )
                          : SizedBox.shrink(),
                      PostList(
                        posts: getPosts(),
                        postsToShow: 100000,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
