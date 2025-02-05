import 'package:flutter/material.dart';
import 'package:scientry/static/post_list.dart';

class LatestPosts extends StatelessWidget {
  const LatestPosts({
    super.key,
    required this.data,
  });

  final Future<List<Post>> data;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: data,
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
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 15,
                ),
                child: PostList(
                  postsToShow: 5,
                  posts: snapshot.data!,
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          );
        }
      },
    );
  }
}
