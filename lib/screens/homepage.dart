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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<(List<Post>, List<Categories>)> getData() async {
    var response = await http.get(Uri.parse(
        "https://proxy.wafflehacker.io/?destination=https://thescientry.blogspot.com/feeds/posts/default?max-results=100"));

    Xml2Json xml2json = Xml2Json();
    xml2json.parse(response.body);
    var jsonData = xml2json.toGData();
    var jsondata = json.decode(jsonData);

    List<Post> posts = [];
    List<Categories> categories = [];
    List<CarouselPost> carouselPosts = [];

    var feed = jsondata["feed"]['entry'];
    int i = 0, j = 1;
    for (var post in feed) {
      i++;
      var imageData = extractImage(post['content']['\$t']) ?? '';
      posts.add(Post(
        title: post['title']['\$t'],
        image: imageData,
        category: post['category'][0]['term'],
        link: post['link']
            .firstWhere((link) => link['rel'] == 'alternate')['href'],
      ));
      if (i > 5 && i % 3 == 0 && j <= 7) {
        carouselPosts.add(CarouselPost(
          id: j,
          title: post['title']['\$t'],
          image: imageData,
          category: post['category'][0]['term'],
          link: post['link']
              .firstWhere((link) => link['rel'] == 'alternate')['href'],
        ));
        j++;
      }
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
    return (posts, categories);
  }

  Future<bool> checkConnection() async {
    return await SimpleConnectionChecker.isConnectedToInternet();
  }

  String? extractImage(String content) {
    var imgRegex = '<img[^>]+id="paper_image"[^>]+src="([^"]+)';
    var match = RegExp(imgRegex).firstMatch(content);
    return match?.group(1);
  }

  final bool isLoggedIn = false;

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
        future: checkConnection(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!) {
            return NoInternet();
          }
          return FutureBuilder<(List<Post>, List<Categories>)>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
