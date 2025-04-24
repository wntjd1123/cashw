import 'package:flutter/material.dart';
import 'all_tab.dart';
import 'popular_tab.dart';
import 'notice_tab.dart';

class FavoriteTab extends StatelessWidget {
  final List<String> favoriteTabs;
  final Function(String)? onSeeMore;

  const FavoriteTab({
    super.key,
    required this.favoriteTabs,
    this.onSeeMore,
  });

  // 📌 탭 이름 → 라벨 변환
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

  // 📌 탭 이름 → 요약용 게시글 리스트 위젯 (미리보기용)
  Widget buildPreviewContent(String tab) {
    switch (tab) {
      case '전체':
        return const AllTab(isPreview: true);
      case '인기글':
        return const PopularTab(isPreview: true);
      case '공지':
        return const NoticeTab(isPreview: true);
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
            // 🟨 섹션 제목 + 더보기
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
            buildPreviewContent(tabKey), // 게시글 미리보기 리스트
            const Divider(height: 24),
          ],
        );
      },
    );
  }
}
