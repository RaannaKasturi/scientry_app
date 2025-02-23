import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scientry/ad_helper.dart';
import 'package:scientry/front/categories_posts_list.dart';
import 'package:scientry/front/latest_posts.dart';
import 'package:scientry/screens/search_page.dart';
import 'package:scientry/static/carousel.dart';
import 'package:scientry/static/drawer.dart';
import 'package:scientry/info_pages/loading_posts.dart';
import 'package:scientry/info_pages/no_internet.dart';
import 'package:scientry/static/post_list.dart';
import 'package:scientry/static/section_title.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void fetchAndProcessData(Map message) async {
  final SendPort sendPort = message['sendPort'];
  const String url =
      "https://thescientry.blogspot.com/feeds/posts/default?alt=json-in-script&callback=myFunc&max-results=100";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("HTTP error: ${response.statusCode}");
    }
    var data = response.body.split("myFunc(")[1];
    var jsondata = json.decode(data.substring(0, data.length - 2));
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
  bool _snackbarShown = false;
  BannerAd? _bannerAd;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _initPrefs();

    _connectionCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool connected = await SimpleConnectionChecker.isConnectedToInternet();
      if (connected && _snackbarShown) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        setState(() {
          _snackbarShown = false;
        });
      } else if (!connected && !_snackbarShown) {
        setState(() {
          _snackbarShown = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: const Text(
              "No internet available. New papers may not be fetched.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: const Duration(hours: 1),
            dismissDirection: DismissDirection.none,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _initPrefs() async {
    BannerAd(
      adUnitId: AdHelper.footerAdUnitID,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Failed to load ad: $error");
          ad.dispose();
        },
      ),
    ).load();
    prefs = await SharedPreferences.getInstance();
    _loadCachedData();
    fetchNewData();
  }

  Future<void> runInBackground() async {
    if (await Permission.ignoreBatteryOptimizations.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              "Permission Required",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Text(
              "Please allow Scientry to run in the background to receive notifications and stay up-to-date.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else if (!(await Permission.ignoreBatteryOptimizations.isGranted)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              "Permission Required",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Text(
              "Please allow Scientry to run in the background to receive notifications and stay up-to-date.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Permission.ignoreBatteryOptimizations.request();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      if (!(await Permission.ignoreBatteryOptimizations.isGranted)) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(
          "Searching for New Research Articles...",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );

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
            content: const Text(
                "An error occurred while fetching data: Check your internet connection and try again"),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            "No New Research Articles found...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }
  }

  void showLatestPostsDialog(
      (List<Post>, List<Categories>, List<CarouselPost>) data) async {
    if (latestDataFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            "New Research Articles found. Updateding Feed...",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      setState(
        () {
          cachedPosts = data.$1;
          cachedCategories = data.$2;
          cachedCarouselPosts = data.$3;
        },
      );
    }
  }

  Widget buildPostsUI(List<Post> posts, List<Categories> categories,
      List<CarouselPost> carouselPosts) {
    return RawScrollbar(
      thumbColor: Theme.of(context).colorScheme.primary,
      thickness: 5,
      radius: const Radius.circular(10),
      trackVisibility: true,
      child: SingleChildScrollView(
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
              fetchedPosts: Future.value(posts),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: const [
            Icon(LucideIcons.brainCircuit),
            SizedBox(width: 3.5),
            Text(
              "Scientry",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const DefaultDrawer(),
      bottomNavigationBar: _bannerAd != null
          ? Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              height: _bannerAd!.size.height.toDouble() + 10,
              child: AdWidget(
                ad: _bannerAd!,
              ),
            )
          : null,
      body: FutureBuilder<bool>(
        future: SimpleConnectionChecker.isConnectedToInternet(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingPosts();
          }
          if (snapshot.hasError ||
              (snapshot.hasData && snapshot.data == false)) {
            if (cachedPosts.isNotEmpty &&
                cachedCategories.isNotEmpty &&
                cachedCarouselPosts.isNotEmpty) {
              return FutureBuilder<
                  (List<Post>, List<Categories>, List<CarouselPost>)>(
                future: Future.value(
                    (cachedPosts, cachedCategories, cachedCarouselPosts)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingPosts();
                  } else if (snapshot.hasError) {
                    return const NoInternet();
                  }
                  var posts = snapshot.data?.$1 ?? [];
                  var categories = snapshot.data?.$2 ?? [];
                  var carouselPosts = snapshot.data?.$3 ?? [];
                  return buildPostsUI(posts, categories, carouselPosts);
                },
              );
            } else {
              return const NoInternet();
            }
          }
          return FutureBuilder<
              (List<Post>, List<Categories>, List<CarouselPost>)>(
            future: getData(false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  cachedPosts.isEmpty) {
                return const LoadingPosts();
              } else if (snapshot.hasError) {
                return const LoadingPosts();
              }
              var posts = snapshot.data?.$1 ?? [];
              var categories = snapshot.data?.$2 ?? [];
              var carouselPosts = snapshot.data?.$3 ?? [];
              return buildPostsUI(posts, categories, carouselPosts);
            },
          );
        },
      ),
    );
  }
}
