import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';
import 'package:scientry/static/category_posts.dart';
import 'package:scientry/static/post_list.dart';
import 'package:scientry/static/section_title.dart';

class Categories {
  final String term;
  final String link;

  Categories({required this.term, required this.link});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      term: json['term'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() => {
        'term': term,
        'link': link,
      };
}

class CategoriesPostsList extends StatefulWidget {
  const CategoriesPostsList({
    super.key,
    required this.fetchedCategories,
    required this.fetchedPosts,
  });

  final Future<List<Categories>> fetchedCategories;
  final Future<List<Post>> fetchedPosts;

  @override
  State<CategoriesPostsList> createState() => _CategoriesPostsListState();
}

class _CategoriesPostsListState extends State<CategoriesPostsList> {
  NativeAd? _backupNativeAd;

  initializeNativeAd() {
    NativeAd(
      adUnitId: AdHelper.backupNativeAdUnit,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _backupNativeAd = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("backupNativeAd: $error");
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
    initializeNativeAd();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Categories>>(
      future: widget.fetchedCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Loading Posts...",
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      "Please Wait!",
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 30,
                ),
                CircularProgressIndicator(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No categories available.');
        } else {
          List<Widget> children = [
            _backupNativeAd != null
                ? Container(
                    height: 100,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    child: AdWidget(
                      ad: _backupNativeAd!,
                    ),
                  )
                : SizedBox.shrink(),
          ];
          snapshot.data!.map((cat) {
            children.add(
              Column(
                children: [
                  SectionTitle(
                    title: cat.term,
                    link: cat.link,
                    context: context,
                  ),
                  CategoryPosts(
                    category: cat.term,
                    data: widget.fetchedPosts,
                    numPosts: 3,
                  ),
                ],
              ),
            );
          }).toList();
          return Column(
            children: children,
          );
        }
      },
    );
  }
}
