import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'run_segment.dart';
import 'summary_page.dart';
import 'running_session_manager.dart';
import 'runningcrew.dart';

class WalkingRunningPage extends StatefulWidget {
  final String modeTitle;
  final List<RunSegment> segments;
  final bool voiceGuideOn;
  const WalkingRunningPage(
      {super.key,
        required this.modeTitle,
        required this.segments,
        this.voiceGuideOn = false});
  @override
  State<WalkingRunningPage> createState() => _WalkingRunningPageState();
}

class _WalkingRunningPageState extends State<WalkingRunningPage> {
  late final List<RunSegment> segs;
  int idx = 0, remain = 0, done = 0;
  bool isPaused = false;
  bool isLocked = false;
  bool isMap = false;
  bool voiceGuide = false;
  double distance = 0;
  Duration elapsed = Duration.zero;
  Timer? _timer;
  final Location _loc = Location();
  late StreamSubscription<LocationData> _locSub;
  List<NLatLng> _path = [];
  NaverMapController? _ctl;
  DateTime? _start;

  @override
  void initState() {
    super.initState();
    segs = widget.segments.where((s) => s.enabled).toList();
    remain = segs.first.seconds;
    voiceGuide = widget.voiceGuideOn;
    _start = DateTime.now();
    _startTimer();
    _startGPS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RunningSessionManager.I.register(
        ModalRoute.of(context)!,                       // ① Route
            () async => _finishRunning(),                  // ② onFinish
            (_) => this.widget,                            // ③ builder
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locSub.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isPaused) return;
      setState(() {
        elapsed += const Duration(seconds: 1);
        remain--;
        done++;
        if (remain <= 0) _nextSeg();
      });
    });
  }

  void _nextSeg() {
    idx++;
    if (idx >= segs.length) {
      _finishRunning();
    } else {
      remain = segs[idx].seconds;
      done = 0;
    }
  }

  void _startGPS() async {
    if (!await _loc.serviceEnabled()) await _loc.requestService();
    var p = await _loc.hasPermission();
    if (p == PermissionStatus.denied) p = await _loc.requestPermission();
    if (p != PermissionStatus.granted) return;
    _locSub = _loc.onLocationChanged.listen((d) {
      if (d.latitude == null || d.longitude == null) return;
      final cur = NLatLng(d.latitude!, d.longitude!);
      setState(() {
        if (_path.isNotEmpty) distance += _hav(_path.last, cur);
        _path.add(cur);
        _ctl?.updateCamera(
            NCameraUpdate.withParams(target: cur, zoom: 16));
        if (_ctl != null && _path.length >= 2) {
          _ctl!.clearOverlays();
          _ctl!.addOverlay(
              NPolylineOverlay(id: 'route', coords: _path, color: Colors.red, width: 4));
        }
      });
    });
  }

  double _hav(NLatLng a, NLatLng b) {
    const R = 6371e3;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(a.latitude * pi / 180) *
            cos(b.latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return 2 * R * atan2(sqrt(h), sqrt(1 - h)) / 1000;
  }

  Future<void> _finishRunning() async {
    _timer?.cancel();
    _locSub.cancel();
    final end = DateTime.now();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => SummaryPage(
              distance: distance,
              duration: elapsed,
              calories: distance * 60,
              pace: _pace(),
              path: _path,
              startTime: _start ?? end.subtract(elapsed),
              endTime: end,
              isUnlimited: true,
              isDistanceMode: false,
            )));


  }

  void _show(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 1)));

  void _lockTap() {
    if (!isLocked) {
      setState(() => isLocked = true);
      _show('화면이 잠금되었습니다.');
    } else {
      _show('잠금이 해제될 때까지 꾹 눌러주세요');
    }
  }

  void _unlockLong() {
    if (isLocked) {
      setState(() => isLocked = false);
      _show('잠금이 해제되었습니다.');
    }
  }

  void _finishTap() => _show('종료하려면 1초간 꾹 눌러주세요');

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  double _pace() =>
      (elapsed.inSeconds == 0 || distance == 0) ? 0 : (elapsed.inSeconds / 60) / distance;

  Widget _stat(String v, String l) =>
      Column(children: [Text(v, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(l, style: const TextStyle(fontSize: 12))]);

  @override
  Widget build(BuildContext ctx) => WillPopScope(
    onWillPop: () async {
      if (Navigator.of(ctx).canPop()) return true;
      Navigator.pushReplacement(
          ctx, MaterialPageRoute(builder: (_) => const RunningCrewPage()));
      return false;
    },
    child: isMap ? _mapScreen() : _mainScreen(),
  );

  Widget _mainScreen() => Scaffold(
    appBar: AppBar(
      title: Text(widget.modeTitle, style: const TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: AbsorbPointer(
      absorbing: isLocked,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(_fmt(remain),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(segs[idx].label,
              style: const TextStyle(fontSize: 20, color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('${distance.toStringAsFixed(1)} km', '총 거리'),
                _stat('${(distance * 60).toStringAsFixed(0)} kcal', '칼로리'),
                _stat(_pace().toStringAsFixed(2), '평균 페이스'),
              ]),
          const SizedBox(height: 32),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Row(children: [
                      Text('${segs[idx].label} ${segs[idx].seconds ~/ 60}분',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Text('음성가이드'),
                      Switch(
                          value: voiceGuide,
                          activeColor: Colors.deepOrange,
                          onChanged: (v) => setState(() => voiceGuide = v))
                    ]),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: done / segs[idx].seconds,
                        minHeight: 4,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation(Colors.deepOrange)),
                    const SizedBox(height: 32),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(
                          icon: const Icon(Icons.skip_previous, size: 32),
                          onPressed: idx == 0
                              ? null
                              : () => setState(() {
                            idx--;
                            remain = segs[idx].seconds;
                            done = 0;
                          })),
                      const SizedBox(width: 8),
                      GestureDetector(
                          onTap: () => setState(() => isPaused = !isPaused),
                          child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.deepOrange),
                              alignment: Alignment.center,
                              child: Icon(isPaused ? Icons.play_arrow : Icons.pause,
                                  size: 40, color: Colors.white))),
                      const SizedBox(width: 8),
                      IconButton(
                          icon: const Icon(Icons.skip_next, size: 32),
                          onPressed: idx >= segs.length - 1
                              ? null
                              : () => setState(() {
                            idx++;
                            remain = segs[idx].seconds;
                            done = 0;
                          }))
                    ]),
                    const SizedBox(height: 24),
                    Text(
                        idx < segs.length - 1
                            ? '다음: ${segs[idx + 1].label} ${segs[idx + 1].seconds ~/ 60}분'
                            : '마지막 구간',
                        style: TextStyle(color: Colors.grey.shade600))
                  ]))),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ElevatedButton.icon(
                  onPressed: () => setState(() => isMap = true),
                  icon: const Icon(Icons.map, color: Colors.white),
                  label:
                  const Text('지도 보기', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)))))
        ],
      ),
    ),
    floatingActionButton: GestureDetector(
        onTap: _lockTap,
        onLongPress: _unlockLong,
        child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.deepOrange),
            alignment: Alignment.center,
            child: Icon(isLocked ? Icons.lock : Icons.lock_open,
                size: 32, color: Colors.white))),
  );

  Widget _mapScreen() => Scaffold(
    body: AbsorbPointer(
      absorbing: isLocked,
      child: Stack(children: [
        NaverMap(
          onMapReady: (c) => _ctl = c,
          options: const NaverMapViewOptions(
              locationButtonEnable: true,
              activeLayerGroups: [NLayerGroup.building]),
        ),
        DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.40,
            builder: (_, ctl) => Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20))),
                child: SingleChildScrollView(
                    controller: ctl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    child: Column(children: [
                      Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10))),
                      Text(_fmt(remain),
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            _stat('${distance.toStringAsFixed(1)} km', '총 거리'),
                            _stat('${(distance * 60).toStringAsFixed(0)} kcal',
                                '칼로리'),
                            _stat(_pace().toStringAsFixed(2), '평균 페이스')
                          ])
                    ])))),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () => setState(() => isPaused = !isPaused),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.deepOrange),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text(isPaused ? '재개' : '일시 정지',
                              style:
                              const TextStyle(color: Colors.deepOrange))),
                      GestureDetector(
                          onTap: _finishTap,
                          onLongPress: _finishRunning,
                          child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 38),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12)),
                              child:
                              const Text('운동 종료', style: TextStyle(color: Colors.black))))
                    ]))),
        SafeArea(
            child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => setState(() => isMap = false)))
      ]),
    ),
    floatingActionButton: GestureDetector(
        onTap: _lockTap,
        onLongPress: _unlockLong,
        child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.deepOrange),
            alignment: Alignment.center,
            child: Icon(isLocked ? Icons.lock : Icons.lock_open,
                size: 32, color: Colors.white))),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}
