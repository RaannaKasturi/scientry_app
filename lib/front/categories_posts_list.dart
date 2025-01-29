import 'package:flutter/material.dart';
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

class CategoriesPostsList extends StatelessWidget {
  const CategoriesPostsList({
    super.key,
    required this.fetchedCategories,
    required this.fetchedPosts,
  });

  final Future<List<Categories>> fetchedCategories;
  final Future<List<Post>> fetchedPosts;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Categories>>(
      future: fetchedCategories,
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
          return Column(
            children: snapshot.data!
                .map((cat) => Column(
                      children: [
                        SectionTitle(
                          title: cat.term,
                          link: cat.link,
                          context: context,
                        ),
                        CategoryPosts(
                          category: cat.term,
                          data: fetchedPosts,
                          numPosts: 3,
                        ),
                      ],
                    ))
                .toList(),
          );
        }
      },
    );
  }
}
