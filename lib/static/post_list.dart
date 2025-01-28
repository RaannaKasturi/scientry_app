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
    return Card(
      child: Row(
        children: [
          image.startsWith("https")
              ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("Error loading image");
                  },
                )
              : Image.memory(
                  base64Decode(image.split(",")[1]),
                  fit: BoxFit.cover,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Text("Error loading image: $error :: $stackTrace");
                  },
                ),
          Column(
            children: [
              Text(title),
              Text(category),
              ElevatedButton(
                onPressed: () {
                  EasyLauncher.url(url: link);
                },
                child: Text('Read More'),
              ),
            ],
          ),
        ],
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
