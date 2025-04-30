import 'package:flutter/material.dart';
import 'run_segment.dart';
import 'Walkingrunningpage.dart';

class DietRunningDetailPage extends StatefulWidget {
  const DietRunningDetailPage({super.key});
  @override
  State<DietRunningDetailPage> createState() => _DietRunningDetailPageState();
}

class _DietRunningDetailPageState extends State<DietRunningDetailPage> {
  bool stretchOn = true, coolOn = true;

  List<RunSegment> _buildSegments() => [
    if (stretchOn) RunSegment('스트레칭', 6 * 60),
    RunSegment('달리기', 30 * 60, mandatory: true),
    if (coolOn) RunSegment('쿨다운', 2 * 60),
  ];

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('다이어트 러닝', style: TextStyle(color: Colors.black)),
      centerTitle: true,
      backgroundColor: Colors.white,
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

        /* 카드(한 개) */
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.fitness_center, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('다이어트 러닝',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Text('38분',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                  '러닝하면서 다이어트와 관련된 유익한 정보도 들어볼까요? '
                      '러닝크루에서 들려주는 러닝 팁과 다이어트 정보를 통해 나의 다이어트를 성공시켜보세요!'),
              const Divider(height: 32),

              const Text('프로그램 구성',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _row('스트레칭 6분', stretchOn, (v) => setState(() => stretchOn = v)),
              _row('달리기 30분', true, null, mandatory: true),
              _row('쿨다운 2분', coolOn, (v) => setState(() => coolOn = v)),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    ),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                c,
                MaterialPageRoute(
                    builder: (_) => WalkingRunningPage(
                      modeTitle: '다이어트 러닝',
                      segments: _buildSegments(),
                    )));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: const Text('운동 시작',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    ),
  );

  Widget _row(String label, bool val, Function(bool)? onChanged,
      {bool mandatory = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          mandatory
              ? _pill('필수')
              : Switch(
            value: val,
            activeColor: Colors.deepOrange,
            onChanged: onChanged,
          ),
        ],
      );

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(.12),
        borderRadius: BorderRadius.circular(4)),
    child: Text(t,
        style: const TextStyle(fontSize: 12, color: Colors.deepOrange)),
  );
}
