import 'package:flutter/material.dart';
import 'daily_walking_detail_page.dart';

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  Map<String, bool> expandedStates = {}; // 각 카드 확장 상태 관리

  final List<Map<String, dynamic>> runningList = [
    {
      'title': '매일 걷기 습관',
      'description': '하루하루 꾸준히 걷기로 건강한 습관을 형성해요',
      'tags': ['#걷기', '#건강습관'],
      'imagePath': 'assets/images/tree.png',
      'category': '단계 러닝',
    },
    // 다른 러닝 항목 추가 가능
  ];

  @override
  void initState() {
    super.initState();
    for (var item in runningList) {
      expandedStates[item['title']] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 배너
        Container(
          margin: const EdgeInsets.all(16),
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black87,
            image: const DecorationImage(
              image: AssetImage('assets/images/tree.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: const Text(
              '새로워진 러닝크루와 함께\n러닝도 하고 캐시도 받아볼까요?',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 러닝 리스트
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: runningList.map((item) => _buildRunningCard(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRunningCard(Map<String, dynamic> item) {
    final bool isExpanded = expandedStates[item['title']] ?? false;
    final bool isDailyWalking = item['title'] == '매일 걷기 습관';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 카드 본문 (탭 시 상세페이지 이동)
              Expanded(
                child: ListTile(
                  onTap: () {
                    if (isDailyWalking) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DailyWalkingDetailPage(), // 기본모드 없음
                        ),
                      );
                    }
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item['imagePath'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(item['description']),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: (item['tags'] as List<String>)
                            .map((tag) => Text(tag, style: const TextStyle(fontSize: 12, color: Colors.deepOrange)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // 화살표 버튼
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    expandedStates[item['title']] = !isExpanded;
                  });
                },
              ),
            ],
          ),
          if (isExpanded && isDailyWalking) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWalkingButton('느리게 걷기', '30분', 0),
                  _buildWalkingButton('빠르게 걷기', '30분', 1),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 버튼 위젯 (느리게, 빠르게 걷기)
  Widget _buildWalkingButton(String title, String time, int mode) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyWalkingDetailPage(initialMode: mode), // 모드 넘김
          ),
        );
      },
      child: Container(
        width: 120,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, color: Colors.deepOrange),
            const SizedBox(height: 4),
            Text('$title\n$time', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
