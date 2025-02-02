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

class MindmapView extends StatelessWidget {
  const MindmapView({super.key, required this.mindmapData});

  final String mindmapData;

  Node parseMindmapData(String data) {
    final lines = data.split('\n').map((line) => line.trimRight()).toList();
    if (lines.isEmpty) return Node(title: '', depth: 0);

    // Parse root node
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

      // Find appropriate parent
      while (stack.length > 1 && stack.last.depth >= depth) {
        stack.removeLast();
      }

      stack.last.children.add(newNode);
      stack.add(newNode);
    }

    return root;
  }

  Widget buildNode(Node node) {
    if (node.children.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text(node.title),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                .copyWith(right: 0),
            child: Text(node.title),
          ),
          MindMap(
            dotRadius: 4,
            children: node.children.map(buildNode).toList(),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootNode = parseMindmapData(mindmapData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindmap'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10)
                          .copyWith(right: 0),
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(rootNode.title),
                ),
                MindMap(
                  padding: const EdgeInsets.only(left: 50),
                  dotRadius: 4,
                  children: rootNode.children.map(buildNode).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
