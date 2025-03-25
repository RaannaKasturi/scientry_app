import 'package:flutter/material.dart';
import 'package:scientry/adverts/native_ad.dart';
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
  @override
  void initState() {
    super.initState();
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
          List<Widget> children = [];
          int totalCategories = snapshot.data!.length;
          for (int i = 0; i < totalCategories; i++) {
            if (i % 5 == 0) {
              children.add(
                SizedBox(
                  height: 10,
                ),
              );
              children.add(
                ScientryNativeAd(),
              );
              children.add(
                SizedBox(
                  height: 10,
                ),
              );
            }
            children.add(
              Column(
                children: [
                  SectionTitle(
                    title: snapshot.data![i].term,
                    link: snapshot.data![i].link,
                    context: context,
                  ),
                  CategoryPosts(
                    category: snapshot.data![i].term,
                    data: widget.fetchedPosts,
                    numPosts: 3,
                  ),
                ],
              ),
            );
          }
          return Column(
            children: children,
          );
        }
      },
    );
  }
}
