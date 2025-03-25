import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:latext/latext.dart';
import 'package:mind_map/mind_map.dart';
import 'package:scientry/adverts/banner_ad.dart';
import 'package:scientry/analytics_service.dart';

class Node {
  final String title;
  final List<Node> children;
  final int depth;

  Node({
    required this.title,
    required this.depth,
    List<Node>? children,
  }) : children = children ?? [];
}

class MindmapView extends StatefulWidget {
  const MindmapView({super.key, required this.mindmapData});

  final String mindmapData;

  @override
  State<MindmapView> createState() => _MindmapViewState();
}

class _MindmapViewState extends State<MindmapView> {
  Node parseMindmapData(String data) {
    data = unescapeHTMLContent(data);
    final lines = data.split('\n').map((line) => line.trimRight()).toList();
    if (lines.isEmpty) return Node(title: '', depth: 0);

    final root = Node(
      title: lines[0].replaceFirst('# ', '').trim(),
      depth: 0,
    );
    final stack = [root];

    for (final line in lines.skip(1)) {
      if (line.isEmpty) continue;

      int depth;
      String title;

      if (line.startsWith('## ')) {
        depth = 1;
        title = line.replaceFirst('## ', '').trim();
      } else if (line.startsWith('- ')) {
        final dashIndex = line.indexOf('- ');
        final spaces = dashIndex;
        final indentLevel = spaces ~/ 2;
        depth = 2 + indentLevel;
        title = line.substring(dashIndex + 2).trim();
      } else {
        continue;
      }

      final newNode = Node(title: title, depth: depth);

      while (stack.length > 1 && stack.last.depth >= depth) {
        stack.removeLast();
      }

      stack.last.children.add(newNode);
      stack.add(newNode);
    }

    return root;
  }

  String unescapeHTMLContent(String htmlContent) {
    var unescape = HtmlUnescape();
    return unescape.convert(htmlContent).trim();
  }

  Widget buildNode(Node node, BuildContext context) {
    if (node.children.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: LaTexT(
            laTeXCode: Text(
              " ${node.title}\t",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
          ),
        ),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                .copyWith(right: 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: LaTexT(
                laTeXCode: Text(
                  " ${node.title}\t",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
          ),
          MindMap(
            lineColor: Theme.of(context).colorScheme.onSurface,
            dotRadius: 4,
            children: node.children
                .map((child) => buildNode(child, context))
                .toList(),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService().logAnalyticsEvent('mindmappage_viewed');
    final rootNode = parseMindmapData(widget.mindmapData);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Mindmap'),
      ),
      bottomNavigationBar: ScientryBannerAd(),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(0),
        minScale: 0.5,
        maxScale: 3.0,
        constrained: false,
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                          .copyWith(right: 0),
                  margin: const EdgeInsets.only(left: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: LaTexT(
                      laTeXCode: Text(
                        "  ${rootNode.title}\t",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              MindMap(
                padding: const EdgeInsets.only(left: 50),
                dotRadius: 4,
                lineColor: Theme.of(context).colorScheme.onSurface,
                children: rootNode.children
                    .map((child) => buildNode(child, context))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
