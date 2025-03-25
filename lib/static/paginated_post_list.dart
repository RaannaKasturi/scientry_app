import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/adverts/native_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/info_pages/loading_posts.dart';
import 'package:scientry/static/post_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaginatedPostList extends StatefulWidget {
  final String categoryLink;
  const PaginatedPostList({super.key, required this.categoryLink});

  static Future<void> fetchData(Map message) async {
    final SendPort sendPort = message['sendPort'];
    final String category = message['category'];
    final int pageNumber = message['pageNumber'];
    late final String apiURL;

    int startIndex = ((pageNumber - 1) * 50) + 1;

    if (category == 'Latest Posts') {
      apiURL =
          "https://thescientry.blogspot.com/feeds/posts/default?alt=json-in-script&callback=myFunc&max-results=50&start-index=$startIndex";
    } else {
      apiURL =
          "https://thescientry.blogspot.com/feeds/posts/default/-/$category/?alt=json-in-script&callback=myFunc&max-results=50&start-index=$startIndex";
    }
    try {
      List<Map<String, dynamic>> postsList = [];
      var response = await http.get(Uri.parse(apiURL));
      var data = response.body.split("myFunc(")[1];
      var jsondata = json.decode(data.substring(0, data.length - 2));
      var feed = jsondata["feed"]['entry'];
      if (feed == null) {
        sendPort.send({'posts': postsList});
        return;
      }
      final RegExp imgRegex = RegExp(
        r'<img[^>]+id="paper_image"[^>]+src="([^"]+)',
        caseSensitive: false,
      );
      for (var post in feed) {
        String imageData = '';
        final String content = post['content']['\$t'] ?? '';
        final match = imgRegex.firstMatch(content);
        if (match != null) {
          imageData = match.group(1) ?? '';
        }
        postsList.add({
          'title': post['title']['\$t'],
          'image': imageData,
          'category': post['category'][0]['term'],
          'link': (post['link'] as List)
              .firstWhere((link) => link['rel'] == 'alternate')['href'],
        });
      }
      sendPort.send({'posts': postsList});
    } catch (e) {
      sendPort.send({'error': e.toString()});
    }
  }

  @override
  State<PaginatedPostList> createState() => _PaginatedPostListState();
}

class _PaginatedPostListState extends State<PaginatedPostList> {
  late String category;
  int pageNumber = 1;

  Future<List<Post>> getData(String category, int pageNumber) async {
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(PaginatedPostList.fetchData, {
      'sendPort': receivePort.sendPort,
      'category': category,
      'pageNumber': pageNumber,
    });
    final message = await receivePort.first as Map;
    isolate.kill(priority: Isolate.immediate);
    if (message.containsKey('error')) {
      throw Exception(message['error']);
    }
    final List<Map<String, dynamic>> postsMapList =
        (message['posts'] as List).cast<Map<String, dynamic>>();
    List<Post> postsList =
        postsMapList.map((data) => Post.fromJson(data)).toList();
    return postsList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    category = widget.categoryLink.toString().split("/").last.isEmpty
        ? 'Latest Posts'
        : widget.categoryLink.toString().split("/").last;
    AnalyticsService().logAnalyticsEvent('paginated_post_list_opened');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(LucideIcons.arrowLeft),
        ),
        title: Text(
          category,
          style: TextStyle(
            fontSize: 25,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      bottomNavigationBar: ScientryBannerAd(),
      body: FutureBuilder<List<Post>>(
        future: getData(category, pageNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LoadingPosts());
          } else if (snapshot.hasError) {
            return Center(
              child: ErrorPage(
                errorPageText: snapshot.error.toString(),
              ),
            );
          } else if (snapshot.hasData) {
            final List<Post> postsList = snapshot.data!;
            if (postsList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      "assets/lottie/no_data.json",
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No More Data Availale!",
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: pageNumber > 1
                          ? () {
                              setState(
                                () {
                                  pageNumber--;
                                },
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        iconColor: Theme.of(context).colorScheme.onPrimary,
                        iconAlignment: IconAlignment.start,
                      ),
                      icon: Icon(LucideIcons.arrowLeft),
                      label: const Text('Previous'),
                    ),
                  ],
                ),
              );
            }
            return RawScrollbar(
              thumbColor: Theme.of(context).colorScheme.primary,
              thickness: 5,
              radius: Radius.circular(10),
              trackVisibility: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostList(
                        posts: postsList,
                        postsToShow: 55,
                      ),
                      const SizedBox(height: 20),
                      ScientryNativeAd(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: pageNumber > 1
                                ? () {
                                    setState(
                                      () {
                                        pageNumber--;
                                      },
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              iconColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              iconAlignment: IconAlignment.start,
                            ),
                            icon: Icon(LucideIcons.arrowLeft),
                            label: const Text('Previous'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(
                                () {
                                  pageNumber++;
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              iconColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              iconAlignment: IconAlignment.end,
                            ),
                            icon: Icon(LucideIcons.arrowRight),
                            label: const Text('Next'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(child: LoadingPosts());
        },
      ),
    );
  }
}
