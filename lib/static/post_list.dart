import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latext/latext.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/screens/single_post.dart';

class Post {
  final String title;
  final String image;
  final String category;
  final String link;

  Post(
      {required this.title,
      required this.image,
      required this.category,
      required this.link});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'],
      image: json['image'],
      category: json['category'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'image': image,
        'category': category,
        'link': link,
      };
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[500]!,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.pushTransition(
            curve: Curves.easeInOut,
            type: PageTransitionType.rightToLeft,
            child: SinglePost(postURL: link),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[300],
                  ),
                  child: image.startsWith("https")
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Text("Error loading image"));
                          },
                        )
                      : Image.memory(
                          base64Decode(image.split(",")[1]),
                          fit: BoxFit.cover,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Text("Error: $error"));
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    children: [
                      LaTexT(
                        laTeXCode: Text(
                          title.replaceAll(r"\(", r"$").replaceAll(r"\)", r"$"),
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 3,
                        ),
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
  final int postsToShow;

  const PostList({super.key, required this.posts, required this.postsToShow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts
          .take(postsToShow)
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
