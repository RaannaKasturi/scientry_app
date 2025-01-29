import 'dart:convert';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';

class Post {
  final String title;
  final String image;
  final String category;
  final String link;

  Post({
    required this.title,
    required this.image,
    required this.category,
    required this.link,
  });
}

class PostCard extends StatelessWidget {
  final String title;
  final String image;
  final String category;
  final String link;

  const PostCard({
    super.key,
    required this.title,
    required this.image,
    required this.category,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: InkWell(
        onTap: () => EasyLauncher.url(url: link),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: image.startsWith("https")
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text("Error loading image");
                      },
                    )
                  : Image.memory(
                      base64Decode(image.split(",")[1]),
                      fit: BoxFit.cover,
                      width: 50,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                            "Error loading image: $error :: $stackTrace");
                      },
                    ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              background: Paint()
                                ..color =
                                    Theme.of(context).colorScheme.primary),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            child: Text(category),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final List<Post> posts;

  const PostList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts
          .map((post) => PostCard(
                title: post.title,
                image: post.image,
                category: post.category,
                link: post.link,
              ))
          .toList(),
    );
  }
}
