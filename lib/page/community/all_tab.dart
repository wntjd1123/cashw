import 'package:flutter/material.dart';
import 'post_model.dart';
import 'post_repository.dart';
import 'post_card.dart';

// 예시: all_tab.dart

class AllTab extends StatelessWidget {
  final bool isPreview;
  const AllTab({super.key, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    final posts = PostRepository.allPosts;
    final previewPosts = isPreview ? posts.take(3).toList() : posts;

    return ListView.builder(
      physics: isPreview ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: isPreview,
      itemCount: previewPosts.length,
      itemBuilder: (context, index) {
        final post = previewPosts[index];
        return PostCard(post: post);
      },
    );
  }
}
