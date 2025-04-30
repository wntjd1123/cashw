import 'package:flutter/material.dart';
import 'run_segment.dart';          // 세그먼트 모델
import 'Walkingrunningpage.dart';  // 실행 페이지

class DailyWalkingDetailPage extends StatefulWidget {
  /// 0 = 느리게 걷기 카드, 1 = 빠르게 걷기 카드가 미리 선택되게 하고 싶을 때 사용
  final int? initialMode;
  const DailyWalkingDetailPage({super.key, this.initialMode});

  @override
  State<DailyWalkingDetailPage> createState() => _DailyWalkingDetailPageState();
}

class _DailyWalkingDetailPageState extends State<DailyWalkingDetailPage> {
  int selectedMode = -1;   // -1 = 아무것도 선택 안 됨
  bool stretchingOn = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialMode != null) selectedMode = widget.initialMode!;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('매일 걷기 습관', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/images/tree.png',
              height: 200, fit: BoxFit.cover),
        ),
        const SizedBox(height: 16),
        const Text('러닝 단계 설정',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _modeCard(
          0,
          '느리게 걷기',
          '천천히 체력을 늘려봐요!',
          '오랜만에 운동을 시작하거나 체력이 약한 분께 추천!\n'
              '스트레칭 4분 + 걷기 30분 구성',
        ),
        const SizedBox(height: 12),
        _modeCard(
          1,
          '빠르게 걷기',
          '걷기로 다이어트 효과를!',
          '다이어트 효과를 높이고 싶은 분께 추천!\n'
              '스트레칭 4분 + 걷기 30분 구성',
        ),
        const SizedBox(height: 100),
      ],
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: selectedMode == -1 ? null : _startRunning,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            selectedMode == -1 ? Colors.grey[300] : Colors.deepOrange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('운동 시작',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    ),
  );

  /* ───────── 모드 카드 ───────── */
  Widget _modeCard(
      int mode, String title, String sub, String detailText) {
    final sel = selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => selectedMode = sel ? -1 : mode),
      child: Container(
        decoration: BoxDecoration(
          color: sel ? Colors.deepOrange.withOpacity(.05) : Colors.white,
          border: Border.all(
              color: sel ? Colors.deepOrange : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(sub, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const Text('34분',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (sel) ...[
              const SizedBox(height: 12),
              Text(detailText),
              const Divider(height: 24),
              _optRow('스트레칭 4분', stretchingOn, (v) {
                setState(() => stretchingOn = v);
              }),
              _optRow('걷기 30분', true, null, mandatory: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _optRow(String label, bool val, Function(bool)? onChanged,
      {bool mandatory = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          mandatory
              ? Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('필수',
                style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
          )
              : Switch(
            value: val,
            activeColor: Colors.deepOrange,
            onChanged: onChanged,
          ),
        ],
      );

  /* ───────── 운동 시작 ───────── */
  void _startRunning() {
    // 세그먼트 구성
    final segments = <RunSegment>[
      if (stretchingOn)
        RunSegment('스트레칭', 4 * 60, mandatory: false),
      RunSegment('걷기', 30 * 60, mandatory: true),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalkingRunningPage(
          modeTitle: selectedMode == 0 ? '느리게 걷기' : '빠르게 걷기',
          segments: segments,
        ),
      ),
    );
  }
}
