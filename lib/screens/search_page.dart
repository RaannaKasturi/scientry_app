import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:scientry/static/loading_posts.dart';
import 'package:scientry/static/post_list.dart';

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
      debugPrint("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FormBuilder(
                key: _searchKeywordFormKey,
                child: Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: "search",
                        enableInteractiveSelection: true,
                        enableSuggestions: true,
                        autocorrect: true,
                        onSubmitted: (_) {
                          _onSearchPressed();
                        },
                        decoration: InputDecoration(
                          labelText: "Search",
                          hintText: "Enter your search term",
                          suffixIcon: IconButton(
                            onPressed: (() {
                              _searchKeywordFormKey.currentState?.reset();
                              setState(() {
                                _searchFuture = null;
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
              const SizedBox(height: 16),
              if (_searchFuture != null)
                FutureBuilder<List<Post>>(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LoadingPosts());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('No Papers Found'),
                      );
                    } else if (snapshot.hasData) {
                      return PostList(
                        postsToShow: 100,
                        posts: snapshot.data!,
                      );
                    } else {
                      return const Center(
                        child: Text('No data available'),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
