import 'dart:convert';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:latext/latext.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/adverts/native_ad.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/screens/mindmap_view.dart';
import 'package:scientry/info_pages/no_internet.dart';
import 'package:scientry/info_pages/processing_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class SinglePost extends StatefulWidget {
  final String postURL;
  const SinglePost({super.key, required this.postURL});

  static String extractDOI(String citation) {
    var doi = citation.split("http")[1].split(" ")[0];
    return "http$doi".trim();
  }

  @override
  State<SinglePost> createState() => _SinglePostState();
}

class _SinglePostState extends State<SinglePost> {
  late SharedPreferences prefs;
  bool _isBookmarked = false;

  String extractCategory(pageContent) {
    var categoryLinks = pageContent.querySelectorAll("a.label-link");
    var categories = categoryLinks
        .map((e) => e.text.trim())
        .where((category) => category != 'ZZZZZZZZZ')
        .toList();
    return categories.isNotEmpty ? categories.first : 'Unknown';
  }

  Future<PostData> fetchPostData() async {
    final response = await http.get(Uri.parse(widget.postURL));
    final doc = parser.parse(response.body);
    return PostData(
      title: doc.querySelector('img#paper_image')!.attributes['alt']!,
      image: doc.querySelector('img#paper_image')!.attributes['src']!,
      category: extractCategory(doc),
      summary: doc.querySelector('div#paper_summary')!.innerHtml.trim(),
      mindmap: doc
              .querySelector('div#paper_mindmap script[type="text/template"]')
              ?.innerHtml
              .trim() ??
          '',
      citation: doc.querySelector('div#paper_citation')!.text.trim(),
      doilink: SinglePost.extractDOI(
          doc.querySelector('div#paper_citation')!.text.trim()),
    );
  }

  Future<bool> checkInternet() async {
    return await SimpleConnectionChecker.isConnectedToInternet();
  }

  String unescapeHTMLContent(String htmlContent) {
    var unescape = HtmlUnescape();
    return unescape.convert(htmlContent).trim();
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((instance) {
      prefs = instance;
      List<String> bookmarkedPosts =
          prefs.getStringList('bookmarkedPosts') ?? [];
      bool bookmarked = bookmarkedPosts.any((element) {
        var bookmark = jsonDecode(element);
        return bookmark['link'] == widget.postURL;
      });
      setState(() {
        _isBookmarked = bookmarked;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkInternet(),
      builder: (context, internetSnapshot) {
        if (internetSnapshot.connectionState == ConnectionState.waiting) {
          return ProcessingPage(processingText: "Checking Internet...");
        }
        if (internetSnapshot.hasError || !internetSnapshot.data!) {
          return NoInternet();
        }
        return FutureBuilder<PostData>(
          future: fetchPostData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ProcessingPage(
                  processingText: "Loading Post. Please Wait...");
            }
            if (snapshot.hasError) {
              return ErrorPage(
                  errorPageText: "An Error Occurred. Please Retry");
            }
            if (!snapshot.hasData) {
              return ProcessingPage(
                  processingText: "Loading Post. Please Wait...");
            }
            final post = snapshot.data!;
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              bottomNavigationBar: const ScientryBannerAd(),
              body: RawScrollbar(
                thumbColor: Theme.of(context).colorScheme.primary,
                thickness: 5,
                radius: Radius.circular(10),
                trackVisibility: true,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: true,
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.surface),
                        ),
                        icon: Icon(Icons.arrow_back,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      expandedHeight: 250,
                      flexibleSpace: FlexibleSpaceBar(
                        background: post.image.startsWith('http')
                            ? Image.network(post.image,
                                fit: BoxFit.cover, width: double.infinity)
                            : Image.memory(
                                base64Decode(post.image.split(",")[1]),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text("Error loading image: $error"),
                              ),
                        title: InkWell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              post.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      pinned: true,
                      actions: [
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.surface),
                          ),
                          onPressed: () => EasyLauncher.url(
                              url: post.doilink, mode: Mode.platformDefault),
                          icon: Icon(Icons.link,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.surface),
                            ),
                            onPressed: () async {
                              await Share.share(
                                "Check out this paper: ${post.doilink} at Scientry: Science Simplified, Knowledge Amplified.\n\nJust upload the Research Paper PDF and read the Summary and Mindmap of Research Paper or Checkout our Collection of Pre-processed Research Papers for Free!\n\nDownload App: https://scientry.vercel.app/download\nVisit Web: https://scientry.vercel.app",
                                subject: post.title,
                                sharePositionOrigin: Rect.fromCenter(
                                  width:
                                      0.9 * MediaQuery.of(context).size.width,
                                  height:
                                      0.7 * MediaQuery.of(context).size.height,
                                  center: const Offset(100, 100),
                                ),
                              );
                            },
                            icon: Icon(Icons.share,
                                color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: LaTexT(
                                    laTeXCode: Text(
                                      post.title,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    BookmarkButton(
                                      post: post,
                                      postURL: widget.postURL,
                                      prefs: prefs,
                                      initialBookmarked: _isBookmarked,
                                    ),
                                    const SizedBox(height: 10),
                                    TTSFunctionality(
                                      htmlContent: post.summary,
                                      title: post.title,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                                color: Theme.of(context).colorScheme.onSurface,
                                thickness: 1,
                                height: 40),
                            HtmlWidget(post.summary,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                )),
                            Divider(
                                color: Theme.of(context).colorScheme.onSurface,
                                thickness: 1,
                                height: 40),
                            HtmlWidget('<h2>Citation</h2>',
                                textStyle: const TextStyle(fontSize: 18)),
                            LaTexT(
                                laTeXCode: Text(
                                    unescapeHTMLContent(post.citation),
                                    style: const TextStyle(fontSize: 17))),
                            const SizedBox(height: 50),
                            ScientryNativeAd(),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  const Text(
                                    "Disclaimer",
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                    ),
                                    maxLines: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 50,
                                    ),
                                    child: Divider(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    "Content is developed using Artificial Intelligence. May not be accurate. Please read the paper to verify.",
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                    maxLines: 5,
                                  ),
                                  const SizedBox(height: 75),
                                  Text(
                                    "Happy Researching!",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  context.pushTransition(
                    curve: Curves.easeInOut,
                    type: PageTransitionType.rightToLeft,
                    child: MindmapView(
                      mindmapData: '# ${post.title}\n${post.mindmap}',
                    ),
                  );
                },
                child: Icon(
                  LucideIcons.listTree,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TTSFunctionality extends StatefulWidget {
  final String htmlContent;
  final String title;
  const TTSFunctionality(
      {super.key, required this.htmlContent, required this.title});

  @override
  State<TTSFunctionality> createState() => _TTSFunctionalityState();
}

class _TTSFunctionalityState extends State<TTSFunctionality>
    with WidgetsBindingObserver {
  FlutterTts flutterTts = FlutterTts();
  late bool isTTSAvailable = false;
  late bool isTTSPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeTTS();
  }

  initializeTTS() async {
    try {
      List installedLanguages = await flutterTts.getLanguages;
      List compatibleLanguages = ['en-US', 'en-IN', 'en-GB', 'en-AU', 'en-CA'];
      String language = installedLanguages.firstWhere(
          (element) => compatibleLanguages.contains(element),
          orElse: () => 'en-US');
      await flutterTts.setLanguage(language);
      await flutterTts.setSpeechRate(0.375);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(0.9);
      setState(() {
        isTTSAvailable = true;
      });
    } catch (e) {
      debugPrint("Language: Error initializing TTS: $e");
      setState(() {
        isTTSAvailable = false;
      });
    }
  }

  _htmlToString(String htmlContent) {
    debugPrint(htmlContent);
    String content =
        html2md.convert(htmlContent).replaceAll(RegExp(r'---*'), '');
    String summary = content.split("Highlights")[0].trim();
    String highlights =
        "\n\nHighlights \n ${content.split("Highlights")[1].trim().split("Key Insights")[0].trim().replaceAll("*", "").trim()}";
    String keyInsights =
        "\n\nKey Insights \n ${content.split("Key Insights")[1].trim().replaceAll("*", "").trim()}";
    return [summary, highlights, keyInsights];
  }

  _handleTTSPlay(title, content) {
    String sanitizedtitle = title;
    List<String> sanitizedContent = _htmlToString(content);
    String summary = sanitizedContent[0];
    String highlights = sanitizedContent[1];
    String keyInsights = sanitizedContent[2];
    if (isTTSAvailable) {
      String preparedContent =
          "$sanitizedtitle\n\n$summary\n$highlights\n$keyInsights";
      setState(() {
        isTTSPlaying = true;
      });
      flutterTts.speak(preparedContent);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Text to Speech is not available on this device."),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  _handleTTSStop() {
    if (isTTSAvailable) {
      if (isTTSPlaying) {
        setState(() {
          isTTSPlaying = false;
        });
        flutterTts.stop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Content is not playing."),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        // state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      flutterTts.stop();
      setState(() {
        isTTSPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isTTSPlaying
          ? _handleTTSStop
          : () => _handleTTSPlay(widget.title, widget.htmlContent),
      icon: Icon(
        !isTTSPlaying ? LucideIcons.play : LucideIcons.pause,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class BookmarkButton extends StatefulWidget {
  final PostData post;
  final String postURL;
  final SharedPreferences prefs;
  final bool initialBookmarked;

  const BookmarkButton({
    super.key,
    required this.post,
    required this.postURL,
    required this.prefs,
    required this.initialBookmarked,
  });

  @override
  BookmarkButtonState createState() => BookmarkButtonState();
}

class BookmarkButtonState extends State<BookmarkButton> {
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.initialBookmarked;
  }

  void _toggleBookmark() {
    List<String> bookmarkedPosts =
        widget.prefs.getStringList('bookmarkedPosts') ?? [];

    int indexFound = bookmarkedPosts.indexWhere((element) {
      var bookmark = jsonDecode(element);
      return bookmark['link'] == widget.postURL;
    });

    if (indexFound != -1) {
      bookmarkedPosts.removeAt(indexFound);
      setState(() {
        isBookmarked = false;
      });
    } else {
      var bookmarkData = {
        'title': widget.post.title,
        'link': widget.postURL,
        'image': widget.post.image,
        'category': widget.post.category,
      };
      bookmarkedPosts.add(jsonEncode(bookmarkData));
      debugPrint('Bookmarked Posts: $bookmarkedPosts');
      setState(() {
        isBookmarked = true;
      });
    }
    widget.prefs.setStringList('bookmarkedPosts', bookmarkedPosts);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleBookmark,
      icon: Icon(
        isBookmarked ? LucideIcons.bookmarkCheck : LucideIcons.bookmarkPlus,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class PostData {
  final String title, image, category, summary, mindmap, citation, doilink;

  PostData({
    required this.title,
    required this.image,
    required this.category,
    required this.summary,
    required this.mindmap,
    required this.citation,
    required this.doilink,
  });
}
