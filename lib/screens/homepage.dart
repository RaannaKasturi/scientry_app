import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/adverts/native_ad.dart';
import 'package:scientry/api/firebase_push_api.dart';
import 'package:scientry/front/categories_posts_list.dart';
import 'package:scientry/front/latest_posts.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/screens/search_page.dart';
import 'package:scientry/static/carousel.dart';
import 'package:scientry/static/drawer.dart';
import 'package:scientry/info_pages/loading_posts.dart';
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
  List<Post> _posts = [];
  List<Categories> _categories = [];
  List<CarouselPost> _carouselPosts = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _snackbarShown = false;

  @override
  void initState() {
    super.initState();
    FirebasePushApi().init();
    _initPrefs();
    Timer.periodic(
      const Duration(seconds: 10),
      (timer) async {
        bool connected = await SimpleConnectionChecker.isConnectedToInternet();
        if (connected && _snackbarShown) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() => _snackbarShown = false);
        } else if (!connected && !_snackbarShown) {
          setState(() => _snackbarShown = true);
          _showConnectionSnackbar();
        }
      },
    );
  }

  void _showConnectionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          "No internet available. New papers may not be fetched.",
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
        duration: const Duration(hours: 1),
      ),
    );
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _loadCachedData();

    // Check if any cached data exists
    bool hasCachedData = _posts.isNotEmpty;

    // Immediately show cached data if available
    if (hasCachedData && mounted) {
      setState(() => _isLoading = false);
    }

    bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();

    if (isConnected) {
      try {
        await _fetchNewData();
        if (mounted) setState(() {});
      } catch (e) {
        // Only show error if no cached data
        if (!hasCachedData && mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating content: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // No internet connection
      if (!hasCachedData && mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }

    // Final check to ensure loading state is cleared
    if (mounted && _isLoading) {
      setState(() => _isLoading = false);
    }
  }

  void _loadCachedData() {
    try {
      if (prefs.containsKey('cachedPosts')) {
        _posts = (prefs.getStringList('cachedPosts') ?? [])
            .map((json) => Post.fromJson(jsonDecode(json)))
            .toList();
      }
      if (prefs.containsKey('cachedCategories')) {
        _categories = (prefs.getStringList('cachedCategories') ?? [])
            .map((json) => Categories.fromJson(jsonDecode(json)))
            .toList();
      }
      if (prefs.containsKey('cachedCarouselPosts')) {
        _carouselPosts = (prefs.getStringList('cachedCarouselPosts') ?? [])
            .map((json) => CarouselPost.fromJson(jsonDecode(json)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _fetchNewData() async {
    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(
          fetchAndProcessData, {'sendPort': receivePort.sendPort});

      final result = await receivePort.first;
      if (result is Map && result.containsKey('error')) {
        throw Exception(result['error']);
      }

      final data = result as Map<String, List<Map<String, dynamic>>>;
      final newPosts = data['posts']!.map((p) => Post.fromJson(p)).toList();
      final newCategories =
          data['categories']!.map((c) => Categories.fromJson(c)).toList();
      final newCarousel = data['carouselPosts']!
          .map((cp) => CarouselPost.fromJson(cp))
          .toList();

      _updateCacheAndState(newPosts, newCategories, newCarousel);
    } catch (e) {
      if (_posts.isEmpty) setState(() => _hasError = true);
      rethrow;
    }
  }

  void _updateCacheAndState(List<Post> posts, List<Categories> categories,
      List<CarouselPost> carousel) {
    prefs.setStringList(
        'cachedPosts', posts.map((p) => jsonEncode(p.toJson())).toList());
    prefs.setStringList('cachedCategories',
        categories.map((c) => jsonEncode(c.toJson())).toList());
    prefs.setStringList('cachedCarouselPosts',
        carousel.map((cp) => jsonEncode(cp.toJson())).toList());

    if (mounted) {
      setState(() {
        _posts = posts;
        _categories = categories;
        _carouselPosts = carousel;
      });
    }
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
                PageTransition(
                  child: const SearchPage(),
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const DefaultDrawer(),
      bottomNavigationBar: const ScientryBannerAd(),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) return const LoadingPosts();
    if (_hasError && _posts.isEmpty) {
      return const ErrorPage(
        errorPageText: "Error fetching papers, please try again later.",
      );
    }
    return RawScrollbar(
      thumbColor: Theme.of(context).colorScheme.primary,
      thickness: 5,
      radius: const Radius.circular(10),
      trackVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(7.5),
          child: Column(
            children: [
              if (_carouselPosts.isNotEmpty)
                Carousel(carouselPosts: _carouselPosts.take(7).toList()),
              const ScientryNativeAd(),
              if (_posts.isNotEmpty) ...[
                SectionTitle(
                    title: "Latest Posts",
                    link: "https://thescientry.blogspot.com/",
                    context: context),
                LatestPosts(data: Future.value(_posts)),
              ],
              if (_categories.isNotEmpty)
                CategoriesPostsList(
                  fetchedCategories: Future.value(_categories),
                  fetchedPosts: Future.value(_posts),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
