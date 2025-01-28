import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:scientry_app/static/carousel.dart';
import 'package:scientry_app/static/drawer.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:scientry_app/static/post_list.dart';

void main() {
  runApp(const MyApp());
}

class PostCard extends StatelessWidget {
  final String title;
  final String image;
  final String category;
  final String link;

  const PostCard({
    super.key,
    required this.title,
    required this.image,
    required this.category,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(category),
        onTap: () {
          // Navigate to link
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
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
  Future<List<Post>> getData() async {
    var data = await http.get(Uri.parse(
        "https://proxy.wafflehacker.io/?destination=https://thescientry.blogspot.com/feeds/posts/default?alt=json"));
    var feed = json.decode(data.body)["feed"]['entry'];
    List<Post> posts = [];
    for (var post in feed) {
      posts.add(Post(
        title: post['title']['\$t'],
        image: extractImage(post['content']['\$t']) ?? '',
        category: post['category'][0]['term'],
        link: post['link']
            .firstWhere((link) => link['rel'] == 'alternate')['href'],
      ));
    }
    return posts;
  }

  String? extractImage(String content) {
    var imgRegex = '<img[^>]+id="paper_image"[^>]+src="([^"]+)';
    var match = RegExp(imgRegex).firstMatch(content);
    return match?.group(1);
  }

  late Future<List<Post>> data;

  @override
  void initState() {
    super.initState();
    data = getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
              FutureBuilder<List<Post>>(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return PostList(
                      posts: snapshot.data!,
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
