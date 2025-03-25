import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scientry/static/paginated_post_list.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.link,
    required this.context,
  });

  final String title;
  final String link;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textStyle: TextStyle(
                fontSize: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              context.pushTransition(
                curve: Curves.easeInOut,
                type: PageTransitionType.rightToLeft,
                child: PaginatedPostList(categoryLink: link),
              );
            },
            child: Text('View More'),
          ),
        ],
      ),
    );
  }
}
