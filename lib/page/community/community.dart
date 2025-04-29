import 'package:flutter/material.dart';
import 'package:cash/page/community/all_tab.dart';
import 'package:cash/page/community/popular_tab.dart';
import 'package:cash/page/community/notice_tab.dart';
import 'package:cash/page/community/favorite_tab.dart';
import 'package:cash/page/community/writepost.dart';
import 'package:cash/page/community/community_drawer.dart';
import 'package:cash/page/community/post_repository.dart';
import 'package:cash/page/community/post_model.dart';
import 'package:cash/page/community/post_detail_widget.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int currentIndex = 1;
  final List<String> tabs = ['즐겨찾기', '전체', '인기글', '공지'];
  final Set<String> favoriteTabs = {};
  final String dropdownValue = '';
  Post? selectedPost;

  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: dropdownValue.isEmpty ? null : dropdownValue,
            hint: const Text('게시판 선택'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (_) {},
            items: [
              DropdownMenuItem(value: '', child: Text('게시판 선택')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabWidget(String tab) {
    switch (tab) {
      case '즐겨찾기':
        return FavoriteTab(
          favoriteTabs: favoriteTabs.toList(),
          onSeeMore: (tabKey) {
            final tabIndexMap = {'전체': 1, '인기글': 2, '공지': 3};
            final targetIndex = tabIndexMap[tabKey];
            if (targetIndex != null) {
              setState(() {
                currentIndex = targetIndex;
              });
            }
          },
          onPostTap: (post) {
            setState(() {
              selectedPost = post;
            });
          },
        );
      case '전체':
        return AllTab(
          onPostTap: (post) {
            setState(() {
              selectedPost = post;
            });
          },
        );
      case '인기글':
        return PopularTab(
          onPostTap: (post) {
            setState(() {
              selectedPost = post;
            });
          },
        );
      case '공지':
        return NoticeTab(
          onPostTap: (post) {
            setState(() {
              selectedPost = post;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildTabTitleWithStar(String tabTitle) {
    String label = tabTitle == '전체'
        ? '전체글'
        : tabTitle == '인기글'
        ? 'BEST 인기글 (실시간)'
        : tabTitle == '공지'
        ? '공지사항'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                if (favoriteTabs.contains(tabTitle)) {
                  favoriteTabs.remove(tabTitle);
                } else {
                  favoriteTabs.add(tabTitle);
                }
              });
            },
            child: Icon(
              favoriteTabs.contains(tabTitle) ? Icons.star : Icons.star_border,
              size: 18,
              color: favoriteTabs.contains(tabTitle) ? Colors.amber : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String selectedTab = tabs[currentIndex];
    final bool showContentUI = selectedTab != '즐겨찾기';

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CommunityDrawer(
        onWritePost: () async {
          Navigator.pop(context);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePostPage()),
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              PostRepository.allPosts.insert(
                0,
                Post(
                  title: result['title'],
                  nickname: '익명',
                  commentCount: 0,
                  views: 0,
                  likes: 0,
                  time: '방금 전',
                  content: result['content'],
                ),
              );
            });
          }
        },
        favoriteBoards: favoriteTabs.toList(),
        onToggleFavorite: (boardName) {
          setState(() {
            if (favoriteTabs.contains(boardName)) {
              favoriteTabs.remove(boardName);
            } else {
              favoriteTabs.add(boardName);
            }
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('커뮤니티', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Text('👟', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('community', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, size: 20, color: Colors.grey),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tabs.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String label = entry.value;
                        final bool isSelected = index == currentIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              currentIndex = index;
                              selectedPost = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.amber[800] : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isSelected)
                                  Container(
                                    height: 2,
                                    width: 20,
                                    color: Colors.amber,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          if (showContentUI) buildDropdown(),
          if (selectedPost != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: PostDetailWidget(post: selectedPost!),
            ),
          if (showContentUI) buildTabTitleWithStar(selectedTab),
          buildTabWidget(selectedTab),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFEB00),
        child: const Icon(Icons.edit, color: Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePostPage()),
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              PostRepository.allPosts.insert(
                0,
                Post(
                  title: result['title'],
                  nickname: '익명',
                  commentCount: 0,
                  views: 0,
                  likes: 0,
                  time: '방금 전',
                  content: result['content'],
                ),
              );
            });
          }
        },
      ),
    );
  }
}
