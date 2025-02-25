import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scientry/ad_helper.dart';
import 'package:scientry/static/banner_ad.dart';
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
  BannerAd? _allScreenFooter;

  void initializeBannerAd() {
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

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([widget.fetchedCategories, widget.fetchedPosts]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.only(top: 30, bottom: 30),
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
                SizedBox(width: 30),
                CircularProgressIndicator(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No data available.');
        } else {
          final categories = snapshot.data![0] as List<Categories>;
          final posts = snapshot.data![1] as List<Post>;
          final filteredCategories = categories.where((category) {
            return posts.any((post) => post.category == category.term);
          }).toList();
          if (filteredCategories.isEmpty) {
            return const Text('No categories available.');
          }
          List<Widget> children = [];
          for (int i = 0; i < filteredCategories.length; i++) {
            if (i == 0 && _allScreenFooter != null) {
              children.add(BannerAdmob());
            }
            children.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: filteredCategories[i].term,
                  link: filteredCategories[i].link,
                  context: context,
                ),
                CategoryPosts(
                  category: filteredCategories[i].term,
                  data: Future.value(posts),
                  numPosts: 3,
                ),
              ],
            ));
            if ((i + 1) % 5 == 0 && _allScreenFooter != null) {
              children.add(BannerAdmob());
            }
          }
          return SingleChildScrollView(
            child: Column(
              children: children,
            ),
          );
        }
      },
    );
  }
}
