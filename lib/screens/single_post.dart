import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:latext/latext.dart';
import 'package:scientry/static/no_internet.dart';
import 'package:scientry/static/processing_page.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class SinglePost extends StatefulWidget {
  final String postURL;
  const SinglePost({super.key, required this.postURL});

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class PostData {
  final String title;
  final String image;
  final String category;
  final String summary;
  final String mindmap;
  final String citation;

  PostData(
      {required this.title,
      required this.image,
      required this.category,
      required this.summary,
      required this.mindmap,
      required this.citation});

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      title: json['title'],
      image: json['image'],
      category: json['category'],
      summary: json['summary'],
      mindmap: json['mindmap'],
      citation: json['citation'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'image': image,
        'category': category,
        'summary': summary,
        'mindmap': mindmap,
        'citation': citation,
      };
}

class _SinglePostState extends State<SinglePost> {
  Future<PostData>? postDetails;

  String? extractImage(String content) {
    var imgRegex = '<img[^>]+id="paper_image"[^>]+src="([^"]+)';
    var match = RegExp(imgRegex).firstMatch(content);
    return match?.group(1);
  }

  fetchPostData(BuildContext context) {
    http.get(Uri.parse(widget.postURL)).then((response) {
      var doc = parser.parse(response.body);
      var title = doc.querySelector("h1")!.text;
      var summary =
          doc.querySelector('div#paper_summary')!.innerHtml.toString().trim();
      var mindmap =
          doc.querySelector('div#paper_mindmap')!.innerHtml.toString().trim();
      var image = doc.querySelector('img#paper_image')!.innerHtml.toString();
      debugPrint(image.toString());
      var citation = doc.querySelector('div#paper_citation')!.text.trim();

      setState(() {
        postDetails = Future.value(
          PostData(
            title: title,
            image: "https://i.ibb.co/xXbZNP6/e2d7a40ad097.jpg",
            category: "Physics",
            summary: summary,
            mindmap: mindmap,
            citation: citation,
          ),
        );
      });
    }).catchError((error) {
      showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to fetch post data"),
            actions: [
              TextButton(
                onPressed: (() {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }),
                child: Text("OK"),
              ),
            ],
          );
        }),
      );
    });
  }

  checkInternet() async {
    bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();
    return isConnected;
  }

  @override
  void initState() {
    super.initState();
    fetchPostData(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkInternet(),
      builder: (context, internetSnapshot) {
        if (internetSnapshot.connectionState == ConnectionState.waiting) {
          return ProcessingPage(processingText: "Checking Internet...");
        }
        if (internetSnapshot.hasError || internetSnapshot.data == false) {
          return NoInternet();
        }
        return FutureBuilder(
          future: postDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ProcessingPage(
                  processingText: "Loading Post. Please Wait...");
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      leading: IconButton(
                        onPressed: (() {
                          Navigator.pop(context);
                        }),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        snapshot.data!.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      expandedHeight: 250,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          "https://i.ibb.co/xXbZNP6/e2d7a40ad097.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      pinned: true,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              LaTexT(
                                laTeXCode: Text(
                                  snapshot.data!.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Divider(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: HtmlWidget(
                                  snapshot.data!.summary,
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(30),
                                child: Divider(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: HtmlWidget(
                                  '''<h2>Citation</h2>''',
                                  textStyle: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: LaTexT(
                                    laTeXCode: Text(snapshot.data!.citation)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                              )
                            ],
                          )),
                    )
                  ],
                ),
              );
            } else {
              return ProcessingPage(
                  processingText: "Loading Post. Please Wait...");
            }
          },
        );
      },
    );
  }
}
