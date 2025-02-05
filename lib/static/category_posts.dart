import 'package:flutter/material.dart';
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
          return Column(
            children: [
              PostList(
                  postsToShow: 3,
                  posts: snapshot.data!
                      .where((posts) => posts.category == category)
                      .take(numPosts)
                      .toList()),
              SizedBox(
                height: 25,
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
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
      },
    );
  }
}
