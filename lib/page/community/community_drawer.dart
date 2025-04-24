import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mypage.dart';

class CommunityDrawer extends StatefulWidget {
  final VoidCallback onWritePost;
  final List<String> favoriteBoards;
  final Function(String) onToggleFavorite;

  const CommunityDrawer({
    super.key,
    required this.onWritePost,
    required this.favoriteBoards,
    required this.onToggleFavorite,
  });

  @override
  State<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends State<CommunityDrawer> {
  bool isFavoritesOpen = true;

  final List<String> allBoards = [
    'BEST 인기글 (실시간)',
    'BEST 인기글 (명예의 전당)',
    '캐시톡 친구 추가 모집',
    '모두의챌린지 멤버 모집',
    '캐시딜 상품 추천',
    '게시판 오픈 신청',
    '공지사항',
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),


            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KR6KBAQT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('추천인 코드 ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const Text('KR6KBAQT', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(const ClipboardData(text: 'KR6KBAQT'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('추천인 코드가 복사되었습니다.')),
                              );
                            },
                            child: const Icon(Icons.copy, size: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPage()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              children: const [
                _InfoBox(label: '쪽지', count: 0),
                _InfoBox(label: '알림', count: 0),
                _InfoBox(label: '스크랩', count: 0),
                _InfoBox(label: '작성글 보기', count: 0),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onWritePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEB00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('게시글 작성', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('즐겨찾기', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(
                    isFavoritesOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavoritesOpen = !isFavoritesOpen;
                    });
                  },
                ),
              ],
            ),
            if (isFavoritesOpen)
              widget.favoriteBoards.isEmpty
                  ? Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '게시판 제목의\n아이콘을 선택하면\n즐겨찾기에 추가됩니다.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
                  : Column(
                children: widget.favoriteBoards.map((board) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(board),
                    trailing: const Icon(Icons.star, color: Colors.amber),
                    onTap: () => widget.onToggleFavorite(board),
                  );
                }).toList(),
              ),

            const Divider(height: 24),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('전체글'),
              onTap: () => widget.onToggleFavorite('전체'),
            ),

            const Divider(height: 16),

            const Text('캐시워크 커뮤니티', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...allBoards.map((board) {
              final isFavorited = widget.favoriteBoards.contains(board);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Text(board),
                    const SizedBox(width: 6),
                    const CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.red,
                      child: Text('N', style: TextStyle(fontSize: 8, color: Colors.white)),
                    ),
                  ],
                ),
                trailing: Icon(
                  isFavorited ? Icons.star : Icons.star_border,
                  color: isFavorited ? Colors.amber : Colors.grey,
                ),
                onTap: () => widget.onToggleFavorite(board),
              );
            }).toList(),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEB00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('게시판 전체보기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final int count;

  const _InfoBox({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
