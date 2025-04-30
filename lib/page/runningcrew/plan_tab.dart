import 'package:flutter/material.dart';

import 'daily_walking_detail_page.dart';
import 'running_skill_detail_page.dart';

import 'diet_running_detail_page.dart';
import 'fitness_running_detail_page.dart';
import 'stress_relief_running_detail_page.dart';
import 'morning_running_detail_page.dart';
import 'afternoon_running_detail_page.dart';
import 'night_running_detail_page.dart';

import 'running_session_manager.dart';

/* ───── 데이터 정의 ───── */

enum PlanFilter { all, stage, goal, time }

class RunningPlan {
  final String title, desc;
  final List<String> tags;
  final PlanFilter filter;
  const RunningPlan(this.title, this.desc, this.tags, this.filter);
}

const _img = 'assets/images/tree.png';

const List<RunningPlan> _plans = [
  RunningPlan('매일 걷기 습관', '하루하루 꾸준히 걷기로 건강한 습관을 형성해요',
      ['#걷기', '#건강습관'], PlanFilter.stage),
  RunningPlan('러닝 실력 향상', '하루하루 달리며 건강한 하루를!',
      ['#러닝'], PlanFilter.stage),
  RunningPlan('다이어트 러닝', '러닝하며 다이어트 골을 달성해봐요',
      ['#다이어트'], PlanFilter.goal),
  RunningPlan('체력증진 러닝', '러닝하면서 체력을 쑥쑥!',
      ['#근력'], PlanFilter.goal),
  RunningPlan(
      '스트레스 해소 러닝', '러닝으로 힐링 타임', ['#힐링'], PlanFilter.goal),
  RunningPlan('아침 러닝', '공복 유산소로 하루 시작!', ['#아침'], PlanFilter.time),
  RunningPlan('오후 러닝', '오후의 나른함을 해소!',
      ['#점심'], PlanFilter.time),
  RunningPlan('야간 러닝', '상쾌한 하루 마무리', ['#밤'], PlanFilter.time),
];

/* ───── 위젯 ───── */

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});
  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  PlanFilter _sel = PlanFilter.all;
  final Map<String, bool> _exp = {
    for (final p in _plans) p.title: false,
  };

  @override
  Widget build(BuildContext context) {
    final banner = RunningSessionManager.I.hasActive
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () =>
            RunningSessionManager.I.bringToFront(context),
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

    final list =
    _sel == PlanFilter.all ? _plans : _plans.where((p) => p.filter == _sel);

    return Column(
      children: [
        banner,
        const SizedBox(height: 8),
        _filterBar(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: list.map(_buildCard).toList(),
          ),
        ),
      ],
    );
  }

  Widget _filterBar() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      _chip('전체 러닝', PlanFilter.all),
      _chip('단계 러닝', PlanFilter.stage),
      _chip('목적 러닝', PlanFilter.goal),
      _chip('시간 러닝', PlanFilter.time),
    ]),
  );

  Widget _chip(String label, PlanFilter f) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _sel == f,
      selectedColor: Colors.black,
      labelStyle:
      TextStyle(color: _sel == f ? Colors.white : Colors.black),
      onSelected: (_) => setState(() => _sel = f),
    ),
  );

  Widget _buildCard(RunningPlan p) {
    final open = _exp[p.title] ?? false;
    final walking = p.title == '매일 걷기 습관';
    final skill = p.title == '러닝 실력 향상';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ListTile(
                  onTap: () => _tap(context, p.title),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                    Image.asset(_img, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(p.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(p.desc),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: p.tags
                            .map((t) => Text(t,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.deepOrange)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              if (walking || skill)
                IconButton(
                  icon: Icon(
                      open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onPressed: () => setState(() => _exp[p.title] = !open),
                ),
            ],
          ),
          if (open && walking) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _walkBtn('느리게 걷기', 0),
                  _walkBtn('빠르게 걷기', 1),
                ],
              ),
            ),
          ],
          if (open && skill) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _skillBtn('3분', 0),
                  _skillBtn('5분', 1),
                  _skillBtn('15분', 2),
                  _skillBtn('30분', 3),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /* ───────── 카드 탭 ───────── */
  Future<void> _goto(BuildContext ctx, Widget page) async {
    if (RunningSessionManager.I.hasActive) {
      final stop = await showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          content:
          const Text('현재 진행중인 러닝기록이 있습니다.\n러닝을 그만할까요?'),
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
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }

  void _tap(BuildContext ctx, String t) {
    switch (t) {
      case '매일 걷기 습관':
        _goto(ctx, const DailyWalkingDetailPage());
        break;
      case '러닝 실력 향상':
        _goto(ctx, const RunningSkillDetailPage());
        break;
      case '다이어트 러닝':
        _goto(ctx, const DietRunningDetailPage());
        break;
      case '체력증진 러닝':
        _goto(ctx, const FitnessRunningDetailPage());
        break;
      case '스트레스 해소 러닝':
        _goto(ctx, const StressReliefRunningDetailPage());
        break;
      case '아침 러닝':
        _goto(ctx, const MorningRunningDetailPage());
        break;
      case '오후 러닝':
        _goto(ctx, const AfternoonRunningDetailPage());
        break;
      case '야간 러닝':
        _goto(ctx, const NightRunningDetailPage());
        break;
    }
  }

  /* 확장 버튼 */
  Widget _walkBtn(String t, int m) => GestureDetector(
    onTap: () => _goto(context, DailyWalkingDetailPage(initialMode: m)),
    child: Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_walk, color: Colors.deepOrange),
          const SizedBox(height: 4),
          Text(t, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _skillBtn(String l, int i) => GestureDetector(
    onTap: () => _goto(context, RunningSkillDetailPage(initialMode: i)),
    child: Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_motorsports, color: Colors.deepOrange),
          const SizedBox(height: 4),
          Text(l, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}
