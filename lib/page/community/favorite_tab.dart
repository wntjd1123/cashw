import 'package:flutter/material.dart';
import 'all_tab.dart';
import 'popular_tab.dart';
import 'notice_tab.dart';
import 'post_model.dart';

class FavoriteTab extends StatelessWidget {
  final List<String> favoriteTabs;
  final Function(String)? onSeeMore;
  final Function(Post)? onPostTap; // 필드 추가

  const FavoriteTab({
    super.key,
    required this.favoriteTabs,
    this.onSeeMore,
    this.onPostTap,
  });

  String resolveLabel(String tab) {
    switch (tab) {
      case '전체':
        return '전체글';
      case '인기글':
        return 'BEST 인기글 (실시간)';
      case '공지':
        return '공지사항';
      default:
        return tab;
    }
  }

  Widget buildPreviewContent(String tab) {
    switch (tab) {
      case '전체':
        return AllTab(isPreview: true, onPostTap: onPostTap);
      case '인기글':
        return PopularTab(isPreview: true, onPostTap: onPostTap);
      case '공지':
        return NoticeTab(isPreview: true, onPostTap: onPostTap);
      default:
        return const Center(child: Text('지원되지 않는 게시판입니다.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (favoriteTabs.isEmpty) {
      return const Center(child: Text('즐겨찾기한 게시판이 없습니다.'));
    }

    return ListView.builder(
      itemCount: favoriteTabs.length,
      itemBuilder: (context, index) {
        final tabKey = favoriteTabs[index];
        final sectionLabel = resolveLabel(tabKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionLabel,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (onSeeMore != null) onSeeMore!(tabKey);
                    },
                    child: Row(
                      children: const [
                        Text('더보기', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            buildPreviewContent(tabKey),
            const Divider(height: 24),
          ],
        );
      },
    );
  }
}
