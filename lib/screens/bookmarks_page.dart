import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
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
                  child: PostList(
                    posts: getPosts(),
                    postsToShow: 100000,
                  ),
                ),
              ),
            ),
    );
  }
}
