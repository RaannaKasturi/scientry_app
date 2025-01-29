import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/front/categories_posts_list.dart';
import 'package:scientry/front/latest_posts.dart';
import 'package:scientry/static/carousel.dart';
import 'package:scientry/static/drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:scientry/static/post_list.dart';
import 'package:scientry/static/section_title.dart';
import 'package:xml2json/xml2json.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientry',
      theme: ThemeData(
        fontFamily: GoogleFonts.getFont("Syne").fontFamily,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(28, 35, 99, 100)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Scientry'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<(List<Post>, List<Categories>)> getData() async {
    var data = await http.get(Uri.parse(
        "https://proxy.wafflehacker.io/?destination=https://thescientry.blogspot.com/feeds/posts/default?max-results=100"));
    Xml2Json xml2json = Xml2Json();
    xml2json.parse(data.body);
    var jsonData = xml2json.toGData();
    var jsondata = json.decode(jsonData);
    var feed = jsondata["feed"]['entry'];
    List<Post> posts = [];
    List<Categories> categories = [];
    for (var post in feed) {
      posts.add(Post(
        title: post['title']['\$t'],
        image: extractImage(post['content']['\$t']) ?? '',
        category: post['category'][0]['term'],
        link: post['link']
            .firstWhere((link) => link['rel'] == 'alternate')['href'],
      ));
    }
    for (var category in jsondata["feed"]['category']) {
      if (category['term'] != "ZZZZZZZZZ") {
        categories.add(
          Categories(
            term: category['term'],
            link: Uri.parse(
                    "https://thescientry.blogspot.com/search/label/${category['term']}")
                .toString(),
          ),
        );
      }
    }
    return (posts, categories);
  }

  String? extractImage(String content) {
    var imgRegex = '<img[^>]+id="paper_image"[^>]+src="([^"]+)';
    var match = RegExp(imgRegex).firstMatch(content);
    return match?.group(1);
  }

  late Future<(List<Post>, List<Categories>)> data;

  @override
  void initState() {
    super.initState();
    data = getData();
    fetchedPosts = data.then((value) => value.$1);
    fetchedCategories = data.then((value) => value.$2);
  }

  late final Future<List<Post>> fetchedPosts;
  late final Future<List<Categories>> fetchedCategories;

  final int numPosts = 3;
  final String category = 'Astrophysics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(LucideIcons.brainCircuit),
            SizedBox(
              width: 3.5,
            ),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(child: drawer(context)),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Carousel(),
              SectionTitle(
                  title: "Latest Posts",
                  link: "https://thescientry.blogspot.com/",
                  context: context),
              LatestPosts(data: fetchedPosts),
              CategoriesPostsList(
                  fetchedCategories: fetchedCategories,
                  fetchedPosts: fetchedPosts)
            ],
          ),
        ),
      ),
    );
  }
}
