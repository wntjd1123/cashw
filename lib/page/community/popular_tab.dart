import 'package:flutter/material.dart';
import 'post_model.dart';
import 'post_repository.dart';
import 'post_card.dart';
class PopularTab extends StatelessWidget {
  final bool isPreview;
  const PopularTab({super.key, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    final posts = PostRepository.popularPosts;
    final preview = isPreview ? posts.take(3).toList() : posts;

    return ListView.builder(
      physics: isPreview ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: isPreview,
      itemCount: preview.length,
      itemBuilder: (context, index) {
        final post = preview[index];
        return PostCard(post: post);
      },
    );
  }
}
