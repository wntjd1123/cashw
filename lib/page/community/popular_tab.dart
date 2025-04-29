import 'package:flutter/material.dart';
import 'post_model.dart';
import 'post_repository.dart';
import 'post_card.dart';

class PopularTab extends StatelessWidget {
  final bool isPreview;
  final Function(Post)? onPostTap;

  const PopularTab({super.key, this.isPreview = false, this.onPostTap});

  @override
  Widget build(BuildContext context) {
    final posts = PostRepository.popularPosts;
    final previewPosts = isPreview ? posts.take(3).toList() : posts;

    return Column(
      children: previewPosts.map((post) {
        return GestureDetector(
          onTap: () {
            if (onPostTap != null) onPostTap!(post);
          },
          child: PostCard(post: post),
        );
      }).toList(),
    );
  }
}
