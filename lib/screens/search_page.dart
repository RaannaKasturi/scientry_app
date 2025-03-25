import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/info_pages/loading_posts.dart';
import 'package:scientry/info_pages/no_data_found.dart';
import 'package:scientry/info_pages/no_internet.dart';
import 'package:scientry/static/post_list.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static Future<void> fetchData(Map message) async {
    final SendPort sendPort = message['sendPort'];
    final String searchKeyword = message['searchKeyword'];
    try {
      List<Map<String, dynamic>> postsList = [];
      var url =
          "https://thescientry.blogspot.com/feeds/posts/default?alt=json-in-script&callback=myFunc&q=$searchKeyword";
      var response = await http.get(Uri.parse(url));
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
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalKey<FormBuilderState> _searchKeywordFormKey =
      GlobalKey<FormBuilderState>();

  Future<List<Post>> getData(String searchKeyword) async {
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(SearchPage.fetchData,
        {'sendPort': receivePort.sendPort, 'searchKeyword': searchKeyword});
    final message = await receivePort.first as Map;
    isolate.kill(priority: Isolate.immediate);
    if (message.containsKey('error')) {
      throw Exception(message['error']);
    }
    AnalyticsService().logAnalyticsEvent('searchpage_data_fetched');
    final List<Map<String, dynamic>> postsMapList =
        (message['posts'] as List).cast<Map<String, dynamic>>();
    List<Post> postsList =
        postsMapList.map((data) => Post.fromJson(data)).toList();
    return postsList;
  }

  Future<List<Post>>? _searchFuture;

  Future<void> _onSearchPressed() async {
    if (_searchKeywordFormKey.currentState?.saveAndValidate() ?? false) {
      var searchKeyword = _searchKeywordFormKey.currentState!.value['search'];
      setState(() {
        _searchFuture = getData(searchKeyword);
      });
    } else {
      debugPrint("Enter a valid search term");
    }
  }

  Future<bool> checkInternet() async {
    return await SimpleConnectionChecker.isConnectedToInternet();
  }

  @override
  void initState() {
    _searchFuture = getData("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('searchpage_viewed');

    return FutureBuilder(
      future: checkInternet(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const NoInternet();
        }
        if (snapshot.hasError) {
          return NoInternet();
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: ScientryBannerAd(),
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: FormBuilder(
              key: _searchKeywordFormKey,
              child: Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: "search",
                      enableInteractiveSelection: true,
                      enableSuggestions: true,
                      autocorrect: true,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      onSubmitted: (_) {
                        _onSearchPressed();
                      },
                      decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Enter your search term",
                        suffixIcon: IconButton(
                          onPressed: (() {
                            setState(() {
                              _searchFuture = getData("");
                            });
                          }),
                          icon: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onSearchPressed,
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
          body: RawScrollbar(
            thumbColor: Theme.of(context).colorScheme.primary,
            thickness: 5,
            radius: Radius.circular(10),
            trackVisibility: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: FutureBuilder<List<Post>>(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: const Center(
                          child: LoadingPosts(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: ErrorPage(
                            errorPageText: "An error occurred while searching"),
                      );
                    } else if (snapshot.hasData) {
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(
                          child: NoDataFound(
                              noDataFoundText: "No papers found for search"),
                        );
                      } else {
                        return PostList(
                          postsToShow: 100,
                          posts: snapshot.data!,
                        );
                      }
                    } else {
                      return const Center(
                        child: ErrorPage(
                            errorPageText: "An error occurred while searching"),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
