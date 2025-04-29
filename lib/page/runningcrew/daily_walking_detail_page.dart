import 'package:flutter/material.dart';
import 'walkingrunningpage.dart'; // WalkingRunningPage import

class DailyWalkingDetailPage extends StatefulWidget {
  final int? initialMode; // 0: 느리게 걷기, 1: 빠르게 걷기

  const DailyWalkingDetailPage({super.key, this.initialMode});

  @override
  State<DailyWalkingDetailPage> createState() => _DailyWalkingDetailPageState();
}

class _DailyWalkingDetailPageState extends State<DailyWalkingDetailPage> {
  int selectedMode = -1;

  @override
  void initState() {
    super.initState();
    if (widget.initialMode != null) {
      selectedMode = widget.initialMode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매일 걷기 습관', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                'assets/images/tree.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: const [
                      Chip(label: Text('#걷기', style: TextStyle(color: Colors.white)), backgroundColor: Colors.deepOrange),
                      Chip(label: Text('#건강습관', style: TextStyle(color: Colors.white)), backgroundColor: Colors.deepOrange),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('매일 걷기 습관', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('하루하루 꾸준히 걷기로 건강한 습관을 형성해요'),
                  const SizedBox(height: 24),
                  const Text('러닝 단계 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildModeCard(0, '느리게 걷기', '천천히 체력을 늘려봐요!', '오랜만에 운동을 시작하거나 체력이 약한 분께 추천!\n스트레칭 4분 + 걷기 30분 구성'),
                  const SizedBox(height: 12),
                  _buildModeCard(1, '빠르게 걷기', '걷기로 다이어트 효과를!', '다이어트 효과를 높이고 싶은 분께 추천!\n스트레칭 4분 + 걷기 30분 구성'),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: selectedMode != -1 ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalkingRunningPage(
                    modeTitle: selectedMode == 0 ? '느리게 걷기' : '빠르게 걷기',
                    stretchingSeconds: 240,
                    runningSeconds: 1800, voiceGuideOn: false,  // 예시로 30분 설정
                  ),
                ),
              );
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedMode != -1 ? Colors.deepOrange : Colors.grey[300],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('운동 시작', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(int mode, String title, String subtitle, String detail) {
    final bool isSelected = selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = selectedMode == mode ? -1 : mode;
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.white,
          border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_walk, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(subtitle, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Text('34분', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Text(detail, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('스트레칭 4분', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Switch(value: true, onChanged: (_) {}),
                ],
              ),
              const Text('걷기 30분 (필수)', style: TextStyle(fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}
