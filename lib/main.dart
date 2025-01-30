import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry/front/categories_posts_list.dart';
import 'package:scientry/front/latest_posts.dart';
import 'package:scientry/static/carousel.dart';
import 'package:scientry/static/drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:scientry/static/loading_posts.dart';
import 'package:scientry/static/no_internet.dart';
import 'package:scientry/static/post_list.dart';
import 'package:scientry/static/section_title.dart';
import 'package:xml2json/xml2json.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  late StreamSubscription<bool> _connectionListener;
  late Future<(List<Post>, List<Categories>)> data;
  late List<CarouselPost> carouselPosts = [];
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    data = Future.value((<Post>[], <Categories>[]));
    carouselPosts = <CarouselPost>[];
    checkConnection();
    _connectionListener =
        SimpleConnectionChecker().onConnectionChange.listen((connected) {
      if (connected) {
        fetchData();
      }
      setState(() {
        isOnline = connected;
      });
    });
  }

  /// Fetch data when the internet is available
  void fetchData() {
    setState(() {
      data = getData();
    });
  }

  /// Check if the user is initially online
  Future<void> checkConnection() async {
    bool connected = await SimpleConnectionChecker.isConnectedToInternet();
    if (connected) {
      fetchData();
    }
    setState(() {
      isOnline = connected;
    });
  }

  Future<(List<Post>, List<Categories>)> getData() async {
    var response = await http.get(Uri.parse(
        "https://proxy.wafflehacker.io/?destination=https://thescientry.blogspot.com/feeds/posts/default?max-results=100"));

    Xml2Json xml2json = Xml2Json();
    xml2json.parse(response.body);
    var jsonData = xml2json.toGData();
    var jsondata = json.decode(jsonData);

    List<Post> posts = [];
    List<Categories> categories = [];

    var feed = jsondata["feed"]['entry'];
    int i = 0;
    int j = 1;
    for (var post in feed) {
      i++;
      var imageData = extractImage(post['content']['\$t']) ?? '';
      posts.add(
        Post(
          title: post['title']['\$t'],
          image: imageData,
          category: post['category'][0]['term'],
          link: post['link']
              .firstWhere((link) => link['rel'] == 'alternate')['href'],
        ),
      );
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
      } else {
        continue;
      }
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

  @override
  void dispose() {
    _connectionListener.cancel();
    super.dispose();
  }

  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentIndex = 0;

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
            SizedBox(width: 3.5),
            Text(
              widget.title,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
      body: FutureBuilder<(List<Post>, List<Categories>)>(
        future: data,
        builder: (context, snapshot) {
          if (!isOnline) {
            return NoInternet();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPosts();
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.$1.isEmpty) {
            return Center(child: Text("No posts available"));
          } else {
            var posts = snapshot.data!.$1;
            var categories = snapshot.data!.$2;
            return SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Carousel(carouselPosts: carouselPosts),
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
          }
        },
      ),
    );
  }
}
