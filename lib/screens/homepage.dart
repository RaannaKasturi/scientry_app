import 'package:scientry/static/carousel.dart';
import 'package:http/http.dart' as http;
import 'package:scientry/static/drawer.dart';
import 'package:scientry/static/loading_posts.dart';
import 'package:scientry/static/no_internet.dart';
import 'package:scientry/static/post_list.dart';
import 'package:scientry/static/section_title.dart';
import 'package:xml2json/xml2json.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/front/categories_posts_list.dart';
import 'package:scientry/front/latest_posts.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences prefs;
  List<Post> cachedPosts = [];
  List<Categories> cachedCategories = [];
  bool latestDataFound = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _loadCachedData();
    fetchNewData();
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
    setState(() {});
  }

  Future<(List<Post>, List<Categories>)> getData(bool forceFetchData) async {
    if (!forceFetchData &&
        cachedPosts.isNotEmpty &&
        cachedCategories.isNotEmpty) {
      return (cachedPosts, cachedCategories);
    }

    List<Post> posts = [];
    List<Categories> categories = [];
    dynamic jsondata;

    try {
      var response = await http.get(Uri.parse(
          "https://proxy.wafflehacker.io/?destination=https://thescientry.blogspot.com/feeds/posts/default?max-results=100"));
      Xml2Json xml2json = Xml2Json();
      xml2json.parse(response.body);
      var jsonData = xml2json.toGData();
      jsondata = json.decode(jsonData);

      var feed = jsondata["feed"]['entry'];
      for (var post in feed) {
        var imageData = extractImage(post['content']['\$t']) ?? '';
        posts.add(Post(
          title: post['title']['\$t'],
          image: imageData,
          category: post['category'][0]['term'],
          link: post['link']
              .firstWhere((link) => link['rel'] == 'alternate')['href'],
        ));
      }

      for (var category in jsondata["feed"]['category']) {
        if (category['term'] != "ZZZZZZZZZ") {
          categories.add(Categories(
            term: category['term'],
            link:
                "https://thescientry.blogspot.com/search/label/${category['term']}",
          ));
        }
      }

      // Cache the data
      prefs.setStringList('cachedPosts',
          posts.map((post) => jsonEncode(post.toJson())).toList());
      prefs.setStringList('cachedCategories',
          categories.map((category) => jsonEncode(category.toJson())).toList());
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("An error occurred while fetching data"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }

    return (posts, categories);
  }

  String? extractImage(String content) {
    var imgRegex = '<img[^>]+id="paper_image"[^>]+src="([^"]+)';
    var match = RegExp(imgRegex).firstMatch(content);
    return match?.group(1);
  }

  fetchNewData() async {
    var data = await getData(true);
    setState(() {
      latestDataFound = true;
      cachedPosts = data.$1;
      cachedCategories = data.$2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Icon(LucideIcons.brainCircuit),
            SizedBox(width: 3.5),
            Text("Scientry",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      drawer: DefaultDrawer(),
      body: FutureBuilder<bool>(
        future: SimpleConnectionChecker.isConnectedToInternet(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!) {
            return NoInternet();
          }
          return FutureBuilder<(List<Post>, List<Categories>)>(
            future: getData(false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  cachedPosts.isEmpty) {
                return LoadingPosts();
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading data"));
              } else if (!snapshot.hasData || snapshot.data!.$1.isEmpty) {
                return Center(child: Text("No posts available"));
              }

              var posts = snapshot.data!.$1;
              var categories = snapshot.data!.$2;

              return SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Carousel(
                        carouselPosts: posts
                            .take(7)
                            .map((post) => CarouselPost(
                                  id: posts.indexOf(post) + 1,
                                  title: post.title,
                                  image: post.image,
                                  category: post.category,
                                  link: post.link,
                                ))
                            .toList()),
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
