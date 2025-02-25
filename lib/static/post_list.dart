import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:latext/latext.dart';
import 'package:scientry/ad_helper.dart';
import 'package:scientry/screens/single_post.dart';
import 'package:scientry/static/banner_ad.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SinglePost(postURL: link),
            ),
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

class PostList extends StatefulWidget {
  final List<Post> posts;
  final int postsToShow;

  const PostList({super.key, required this.posts, required this.postsToShow});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  BannerAd? _allScreenFooter;

  void initializeBannerAd() {
    BannerAd(
      adUnitId: AdHelper.allScreenFooterAdUnit,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _allScreenFooter = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Failed to load ad: $error");
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void initState() {
    super.initState();
    initializeBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    int totalPosts = widget.posts.length;
    List<Widget> children = [];
    for (int i = 0; i < totalPosts; i++) {
      if ((i + 1) % 10 == 0 && _allScreenFooter != null) {
        children.add(BannerAdmob());
      }
      children.add(PostCard(
        title: widget.posts[i].title,
        image: widget.posts[i].image,
        category: widget.posts[i].category,
        link: widget.posts[i].link,
      ));
    }
    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }
}
