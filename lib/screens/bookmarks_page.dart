import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/adverts/native_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/info_pages/loading_posts.dart';
import 'package:scientry/info_pages/no_data_found.dart';
import 'package:scientry/static/post_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  late Future<List<Post>> _bookmarkedPostsFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedPostsFuture = _loadBookmarks();
  }

  Future<List<Post>> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> postStrings = prefs.getStringList('bookmarkedPosts') ?? [];
      debugPrint('Bookmarked Posts: $postStrings');
      return postStrings.map((str) {
        final jsonData = jsonDecode(str);
        return Post(
          title: jsonData['title'] as String,
          link: jsonData['link'] as String,
          image: jsonData['image'] as String,
          category: jsonData['category'] as String,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      throw Exception("Failed to load bookmarks");
    }
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('bookmarkspage_visited');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Bookmarks'),
      ),
      bottomNavigationBar: ScientryBannerAd(),
      body: FutureBuilder<List<Post>>(
        future: _bookmarkedPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingPosts());
          } else if (snapshot.hasError) {
            return const Center(
              child: ErrorPage(errorPageText: "Error loading bookmarks"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: NoDataFound(noDataFoundText: "No Bookmarked Posts Found"),
            );
          } else {
            return RawScrollbar(
              thumbColor: Theme.of(context).colorScheme.primary,
              thickness: 5,
              radius: Radius.circular(10),
              trackVisibility: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      ScientryNativeAd(),
                      PostList(posts: snapshot.data!, postsToShow: 100000),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
