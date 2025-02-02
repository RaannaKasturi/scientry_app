import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

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

  Widget buildNode(Node node, BuildContext context) {
    if (node.children.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text(
          node.title,
          style: TextStyle(
              fontSize: 16, color: Theme.of(context).colorScheme.onTertiary),
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
              padding: const EdgeInsets.all(2.0),
              child: Text(node.title,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSecondary)),
            ),
          ),
          MindMap(
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
  Widget build(BuildContext context) {
    final rootNode = parseMindmapData(widget.mindmapData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindmap'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {}),
        child: Icon(Icons.save),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10)
                            .copyWith(right: 0),
                        margin: const EdgeInsets.only(left: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            rootNode.title,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    MindMap(
                      padding: const EdgeInsets.only(left: 50),
                      dotRadius: 4,
                      children: rootNode.children
                          .map((child) => buildNode(child, context))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
