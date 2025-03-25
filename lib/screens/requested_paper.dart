import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:latext/latext.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/adverts/native_ad.dart';
import 'package:scientry/analytics_service.dart';
import 'package:scientry/api/fetch_data.dart';
import 'package:scientry/info_pages/error_page.dart';
import 'package:scientry/info_pages/no_data_found.dart';
import 'package:scientry/info_pages/processing_page.dart';
import 'package:scientry/screens/mindmap_view.dart';
import 'package:scientry/screens/single_post.dart';
import 'package:share_plus/share_plus.dart';

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

class RequestedPaper extends StatefulWidget {
  final dynamic inputDOI;
  final dynamic inputpdfURL;

  static Future<void> generateSummaryMindmap(message) async {
    final SendPort sendPort = message['sendPort'];
    final String inputDOI = message['inputDOI'];
    final String inputpdfURL = message['inputpdfURL'];
    late final PostData? sendingData;
    try {
      var doiString = inputDOI.toString();
      if (!doiString.contains(".org/")) {
        doiString = "https://doi.org/$doiString";
      }
      final parts = doiString.split(".org/");
      if (parts.length < 2) {
        debugPrint("RequestedLog: Unexpected DOI format.");
        sendingData = null;
      }
      final doiID = parts[1];
      final doi = doiString
          .replaceAll(r'/', '')
          .replaceAll(':', '')
          .replaceAll('.', '');
      final pdfURL = inputpdfURL.toString();
      debugPrint("RequestedLog: Processing DOI: $doi and PDF URL: $pdfURL");

      var data = await fetchData(pdfURL, doi);
      if (data == null) {
        debugPrint("RequestedLog: fetchData returned null.");
        sendingData = null;
        sendPort.send({'posts': sendingData});
        return;
      }

      var summary = data['summary'];
      var mindmap = data['mindmap'];

      var citation = "";
      var title = "";

      try {
        final citationResponse =
            await http.get(Uri.parse("https://api.citeas.org/product/$doiID"));
        debugPrint(
            "RequestedLog: Citation API status code: ${citationResponse.statusCode}");
        debugPrint(
            "RequestedLog: Citation API response body: ${citationResponse.body}");

        if (citationResponse.statusCode == 200) {
          try {
            final citationDataJson = jsonDecode(citationResponse.body);
            if (citationDataJson['citations'] != null &&
                citationDataJson['citations'].isNotEmpty) {
              citation = citationDataJson['citations'][0]['citation']
                  .toString()
                  .replaceAll("<i>", "")
                  .replaceAll("</i>", "");
            }
            title = citationDataJson['name'] ?? "";
          } catch (e) {
            debugPrint("RequestedLog: Error parsing citation JSON: $e");
          }
        }
      } catch (e) {
        debugPrint("RequestedLog: Error fetching citation: $e");
      }

      if (summary != null && mindmap != null) {
        summary = md.markdownToHtml(summary);
        sendingData = PostData(
          title: title,
          image: "assets/images/requested_post_image.jpg",
          category: "Requested",
          summary: summary,
          mindmap: mindmap,
          citation: citation,
          doilink: doiString,
        );
      } else {
        sendingData = null;
      }
    } catch (e, stackTrace) {
      debugPrint("Error in generateSummaryMindmap: $e");
      debugPrint("StackTrace: $stackTrace");
      sendingData = null;
    }

    sendPort.send({'posts': sendingData});
  }

  const RequestedPaper({
    super.key,
    required this.inputDOI,
    required this.inputpdfURL,
  });

  @override
  State<RequestedPaper> createState() => _RequestedPaperState();
}

class _RequestedPaperState extends State<RequestedPaper> {
  String unescapeHTMLContent(String htmlContent) {
    var unescape = HtmlUnescape();
    return unescape.convert(htmlContent).trim();
  }

  Future<PostData?> getData(inputDOI, inputpdfURL) async {
    ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(RequestedPaper.generateSummaryMindmap, {
      'sendPort': receivePort.sendPort,
      'inputDOI': inputDOI,
      'inputpdfURL': inputpdfURL
    });
    final message = await receivePort.first as Map;
    isolate.kill(priority: Isolate.immediate);
    if (message.isNotEmpty) {
      return message['posts'];
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('requested_paper_viewed');
    Future<PostData?> post = getData(widget.inputDOI, widget.inputpdfURL);
    return FutureBuilder<PostData?>(
      future: post,
      builder: (context, snapshot) {
        debugPrint(
            "RequestedLog: FutureBuilder snapshot: ${snapshot.connectionState}");
        if (snapshot.hasError) {
          debugPrint("RequestedLog: FutureBuilder error: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(
              child: ProcessingPage(
                processingText:
                    "Generating Summary & Mindmap for Requested Paper",
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child:
                ErrorPage(errorPageText: "An error occurred while searching"),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data == null) {
            debugPrint("RequestedLog: snapshot.data is null");
            return NoDataFound(
                noDataFoundText: "Error Generating Summary & Mindmap");
          } else {
            final post = snapshot.data;
            debugPrint("RequestedLog: Received post data: ${post.toString()}");
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              bottomNavigationBar: ScientryBannerAd(),
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
                        background: Image.asset(post!.image,
                            fit: BoxFit.cover, width: double.infinity),
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
                                "Check out this paper: ${post.doilink} at Scientry. Just upload the PDF and get the summary and mindmap for Free!\nDownload App: https://scientry.app\nVisit Web: https://scientry.vercel.app",
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
                                TTSFunctionality(
                                  htmlContent: post.summary,
                                  title: post.title,
                                ),
                              ],
                            ),
                            Divider(
                                color: Theme.of(context).colorScheme.onSurface,
                                thickness: 1,
                                height: 40),
                            HtmlWidget(post.summary,
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                )),
                            Divider(
                                color: Theme.of(context).colorScheme.onSurface,
                                thickness: 1,
                                height: 40),
                            HtmlWidget('<h2>Citation</h2>',
                                textStyle: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500)),
                            LaTexT(
                                laTeXCode: Text(
                                    unescapeHTMLContent(post.citation),
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500))),
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
          }
        } else {
          debugPrint("RequestedLog: No data available in snapshot.");
          return Scaffold(
            body: Center(
              child: NoDataFound(
                  noDataFoundText: "Error Generating Summary & Mindmap"),
            ),
          );
        }
      },
    );
  }
}
