import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/front/categories_posts_list.dart';
import 'package:scientry/front/latest_posts.dart';
import 'package:scientry/static/carousel.dart';
import 'package:scientry/static/drawer.dart';
import 'package:scientry/static/loading_posts.dart';
import 'package:scientry/static/no_internet.dart';
import 'package:scientry/static/post_list.dart';
import 'package:scientry/static/section_title.dart';
import 'package:xml2json/xml2json.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void fetchAndProcessData(Map message) async {
  final SendPort sendPort = message['sendPort'];
  const String url =
      "https://proxy.wafflehacker.io/?destination=https://thescientry.blogspot.com/feeds/posts/default?max-results=100";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("HTTP error: ${response.statusCode}");
    }
    final Xml2Json xml2json = Xml2Json();
    xml2json.parse(response.body);
    final String gdata = xml2json.toGData();
    final Map<String, dynamic> jsondata = json.decode(gdata);
    List<Map<String, dynamic>> postsList = [];
    List<Map<String, dynamic>> carouselPostsList = [];
    List<Map<String, dynamic>> categoriesList = [];
    final RegExp imgRegex = RegExp(
      r'<img[^>]+id="paper_image"[^>]+src="([^"]+)',
      caseSensitive: false,
    );
    var feed = jsondata["feed"]['entry'];
    int i = 0, j = 1;
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
      if (i > 5 && i % 3 == 0 && j <= 7) {
        carouselPostsList.add({
          'id': j,
          'title': post['title']['\$t'],
          'image': imageData,
          'category': post['category'][0]['term'],
          'link': (post['link'] as List)
              .firstWhere((link) => link['rel'] == 'alternate')['href'],
        });
        j++;
      }
      i++;
    }
    for (var category in jsondata["feed"]['category']) {
      if (category['term'] != "ZZZZZZZZZ") {
        categoriesList.add({
          'term': category['term'],
          'link':
              "https://thescientry.blogspot.com/search/label/${category['term']}",
        });
      }
    }

    sendPort.send({
      'posts': postsList,
      'carouselPosts': carouselPostsList,
      'categories': categoriesList,
    });
  } catch (e) {
    sendPort.send({'error': e.toString()});
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences prefs;
  List<Post> cachedPosts = [];
  List<Categories> cachedCategories = [];
  List<CarouselPost> cachedCarouselPosts = [];
  bool latestDataFound = false;

  @override
  void initState() {
    super.initState();
    splashScreen();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _loadCachedData();
    fetchNewData();
  }

  void splashScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
  }

  void _loadCachedData() {
    if (prefs.containsKey('cachedPosts')) {
      List<String> postsJson = prefs.getStringList('cachedPosts') ?? [];
      cachedPosts =
          postsJson.map((json) => Post.fromJson(jsonDecode(json))).toList();
    }
    if (prefs.containsKey('cachedCategories')) {
      List<String> categoriesJson =
          prefs.getStringList('cachedCategories') ?? [];
      cachedCategories = categoriesJson
          .map((json) => Categories.fromJson(jsonDecode(json)))
          .toList();
    }
    if (prefs.containsKey('cachedCarouselPosts')) {
      List<String> carouselPostsJson =
          prefs.getStringList('cachedCarouselPosts') ?? [];
      cachedCarouselPosts = carouselPostsJson
          .map((json) => CarouselPost.fromJson(jsonDecode(json)))
          .toList();
    }
    setState(() {});
  }

  Future<(List<Post>, List<Categories>, List<CarouselPost>)> getData(
      bool forceFetchData) async {
    if (!forceFetchData &&
        cachedPosts.isNotEmpty &&
        cachedCategories.isNotEmpty &&
        cachedCarouselPosts.isNotEmpty) {
      return (cachedPosts, cachedCategories, cachedCarouselPosts);
    }

    List<Post> posts = [];
    List<Categories> categories = [];
    List<CarouselPost> carouselPosts = [];

    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(fetchAndProcessData, {
        'sendPort': receivePort.sendPort,
      });

      final result = await receivePort.first;

      if (result is Map && result.containsKey('error')) {
        throw Exception(result['error']);
      }

      final Map<String, List<Map<String, dynamic>>> data =
          result as Map<String, List<Map<String, dynamic>>>;

      posts =
          data['posts']!.map((postJson) => Post.fromJson(postJson)).toList();
      carouselPosts = data['carouselPosts']!
          .map((postJson) => CarouselPost.fromJson(postJson))
          .toList();
      categories = data['categories']!
          .map((catJson) => Categories.fromJson(catJson))
          .toList();

      prefs.setStringList('cachedPosts',
          posts.map((post) => jsonEncode(post.toJson())).toList());
      prefs.setStringList('cachedCategories',
          categories.map((category) => jsonEncode(category.toJson())).toList());
      prefs.setStringList('cachedCarouselPosts',
          carouselPosts.map((post) => jsonEncode(post.toJson())).toList());
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("An error occurred while fetching data: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    return (posts, categories, carouselPosts);
  }

  void fetchNewData() async {
    var data = await getData(true);
    var newPosts = data.$1;
    if (newPosts.isNotEmpty &&
        (cachedPosts.isEmpty || newPosts[0].title != cachedPosts[0].title)) {
      setState(() {
        latestDataFound = true;
      });
      showLatestPostsDialog(data);
    }
  }

  void showLatestPostsDialog(
      (List<Post>, List<Categories>, List<CarouselPost>) data) {
    if (latestDataFound) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Latest Posts"),
          content: const Text("Latest posts have been fetched. Refresh Feed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cachedPosts = data.$1;
                  cachedCategories = data.$2;
                  cachedCarouselPosts = data.$3;
                });
                Navigator.pop(context);
              },
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: const [
            Icon(LucideIcons.brainCircuit),
            SizedBox(width: 3.5),
            Text("Scientry",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const DefaultDrawer(),
      body: FutureBuilder<bool>(
        future: SimpleConnectionChecker.isConnectedToInternet(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!) {
            return const NoInternet();
          }
          return FutureBuilder<
              (List<Post>, List<Categories>, List<CarouselPost>)>(
            future: getData(false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  cachedPosts.isEmpty) {
                return const LoadingPosts();
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading data"));
              }

              var posts = snapshot.data?.$1 ?? [];
              var categories = snapshot.data?.$2 ?? [];
              var carouselPosts = snapshot.data?.$3 ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Carousel(
                      carouselPosts: carouselPosts
                          .take(7)
                          .map((post) => CarouselPost(
                                id: post.id,
                                title: post.title,
                                image: post.image,
                                category: post.category,
                                link: post.link,
                              ))
                          .toList(),
                    ),
                    SectionTitle(
                        title: "Latest Posts",
                        link: "https://thescientry.blogspot.com/",
                        context: context),
                    LatestPosts(data: Future.value(posts)),
                    CategoriesPostsList(
                        fetchedCategories: Future.value(categories),
                        fetchedPosts: Future.value(posts)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
