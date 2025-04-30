import 'package:flutter/material.dart';

import 'goal_setting_page.dart';
import 'free_running.dart';

import 'running_session_manager.dart';

class RunningTab extends StatefulWidget {
  const RunningTab({super.key});
  @override
  State<RunningTab> createState() => _RunningTabState();
}

class _RunningTabState extends State<RunningTab> {
  bool isUnlimited = true;
  bool isDistance = true;
  double distanceGoal = 0.0;
  Duration timeGoal = Duration.zero;

  @override
  Widget build(BuildContext context) {
    final banner = RunningSessionManager.I.hasActive
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () => RunningSessionManager.I.bringToFront(context),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(30)),
          alignment: Alignment.center,
          child: const Text('현재 진행중인 러닝으로 이동하기 ›',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    )
        : const SizedBox.shrink();

    return Column(
      children: [
        banner,
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _topBtn('무제한 러닝', true),
            const SizedBox(width: 8),
            _topBtn('목표 러닝', false),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _modeBtn('거리', true),
            const SizedBox(width: 12),
            _modeBtn('시간', false),
          ],
        ),
        const SizedBox(height: 32),
        isUnlimited ? _unlimited() : _goal(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (RunningSessionManager.I.hasActive) {
                  final stop = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: const Text(
                          '현재 진행중인 러닝기록이 있습니다.\n러닝을 그만할까요?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(_, false),
                            child: const Text('아니오')),
                        TextButton(
                            onPressed: () => Navigator.pop(_, true),
                            child: const Text('네')),
                      ],
                    ),
                  ) ??
                      false;
                  if (!stop) return;
                  await RunningSessionManager.I.stopRunning();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreeRunning(
                      isUnlimited: isUnlimited,
                      isDistanceMode: isDistance,
                      distanceGoal: distanceGoal,
                      timeGoal: timeGoal,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('운동 시작',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  /* ───── 위젯 빌더 ───── */
  Widget _unlimited() => Column(
    children: [
      Text(isDistance ? '무제한 거리 러닝' : '무제한 시간 러닝',
          style:
          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('별도의 목표 없이 자유롭게 달려볼까요?\n내가 달린만큼 러닝기록이 저장돼요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey)),
      const SizedBox(height: 40),
      Icon(isDistance ? Icons.directions_run : Icons.timer,
          size: 120, color: Colors.deepOrange),
    ],
  );

  Widget _goal() => Column(
    children: [
      GestureDetector(
        onTap: () async {
          final r = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GoalSettingPage(
                      isDistanceMode: isDistance,
                      initialDistance: distanceGoal,
                      initialDuration: timeGoal)));
          if (r != null) {
            setState(() {
              if (isDistance) {
                distanceGoal = r as double;
              } else {
                timeGoal = r as Duration;
              }
            });
          }
        },
        child: Column(
          children: [
            Text(
                isDistance
                    ? distanceGoal.toStringAsFixed(1)
                    : _fmt(timeGoal),
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Divider(
                color: Colors.deepOrange,
                thickness: 3,
                indent: 80,
                endIndent: 80),
            Text(isDistance ? 'km' : '시:분:초',
                style: const TextStyle(
                    fontSize: 14, color: Colors.black54)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const Text('숫자 영역을 터치해서 러닝 목표를\n자유롭게 설정해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );

  /* ───── 헬퍼 ───── */
  String _fmt(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _topBtn(String t, bool u) {
    final sel = isUnlimited == u;
    return GestureDetector(
      onTap: () => setState(() => isUnlimited = u),
      child: Container(
        constraints: const BoxConstraints(minWidth: 90, minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(t,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _modeBtn(String t, bool d) {
    final sel = isDistance == d;
    return GestureDetector(
      onTap: () => setState(() => isDistance = d),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: sel
              ? Border.all(color: Colors.deepOrange, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Text(t,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.deepOrange : Colors.black54)),
      ),
    );
  }
}
