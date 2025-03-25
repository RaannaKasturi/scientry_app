import 'package:flutter/material.dart';
import 'package:scientry/adverts/native_ad.dart';
import 'package:scientry/static/post_list.dart';

class CategoryPosts extends StatelessWidget {
  const CategoryPosts({
    super.key,
    required this.data,
    required this.category,
    required this.numPosts,
  });

  final Future<List<Post>> data;
  final String category;
  final int numPosts;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> children = [];
          List<Post> filteredPosts = snapshot.data!
              .where((post) => post.category == category)
              .take(numPosts)
              .toList();

          if (filteredPosts.isNotEmpty) {
            for (int i = 0; i < filteredPosts.length; i += 3) {
              children.add(
                PostList(
                  postsToShow: 3,
                  posts: filteredPosts.skip(i).take(3).toList(),
                ),
              );
              children.add(const SizedBox(height: 25));
            }
          } else {
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  "No Recent Papers Found\nClick \"View All\" to see all papers",
                ),
              ),
            );
          }
          if (children.length % 5 == 0) {
            children.add(const ScientryNativeAd());
            children.add(const SizedBox(height: 25));
          }
          return Column(
            children: children,
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
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
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    "Please Wait!",
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              SizedBox(width: 30),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }
}
