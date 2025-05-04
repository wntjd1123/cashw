import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'summary_page.dart';
import 'runningcrew.dart';
import 'running_session_manager.dart';

class FreeRunning extends StatefulWidget {
  final bool isUnlimited;
  final bool isDistanceMode;
  final double distanceGoal;
  final Duration timeGoal;
  const FreeRunning({
    super.key,
    required this.isUnlimited,
    required this.isDistanceMode,
    this.distanceGoal = 0.0,
    this.timeGoal = Duration.zero,
  });

  @override
  State<FreeRunning> createState() => _FreeRunningState();
}

class _FreeRunningState extends State<FreeRunning> {
  bool isMapMode = false;
  bool isPaused = false;
  bool isLocked = false;
  double distance = 0.0;
  Duration elapsedTime = Duration.zero;
  Timer? _timer;
  final Location _location = Location();
  late StreamSubscription<LocationData> _locationSubscription;
  List<NLatLng> _path = [];
  NaverMapController? _naverMapController;
  DateTime? _start;

  /* ----------------- ①: 최소화(현재 진행중으로 이동) ----------------- */
  void _minimize() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RunningCrewPage()),
    );
  }
  /* ------------------------------------------------------------------ */

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _startRunning();
    _startLocationUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RunningSessionManager.I.register(
        ModalRoute.of(context)!,
            () async => _finishRunning(),
            (_) => widget,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription.cancel();
    super.dispose();
  }

  void _startRunning() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused) {
        setState(() {
          elapsedTime += const Duration(seconds: 1);
          _checkGoalReached();
        });
      }
    });
  }

  void _pauseRunning() => setState(() => isPaused = !isPaused);

  void _startLocationUpdates() async {
    if (!await _location.serviceEnabled()) await _location.requestService();
    var p = await _location.hasPermission();
    if (p == PermissionStatus.denied) p = await _location.requestPermission();
    if (p != PermissionStatus.granted) return;
    _locationSubscription = _location.onLocationChanged.listen((d) {
      if (d.latitude == null || d.longitude == null) return;
      final cur = NLatLng(d.latitude!, d.longitude!);
      setState(() {
        if (_path.isNotEmpty) distance += _calc(_path.last, cur);
        _path.add(cur);
        _naverMapController?.updateCamera(
            NCameraUpdate.withParams(target: cur, zoom: 16));
        if (_naverMapController != null && _path.length >= 2) {
          _naverMapController!.clearOverlays();
          _naverMapController!.addOverlay(
            NPolylineOverlay(id: 'r', coords: _path, color: Colors.red, width: 4),
          );
        }
      });
    });
  }

  double _calc(NLatLng a, NLatLng b) {
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

  void _checkGoalReached() {
    if (!widget.isUnlimited) {
      if (widget.isDistanceMode) {
        if (widget.distanceGoal - distance <= 0) _finishRunning();
      } else {
        if (widget.timeGoal - elapsedTime <= Duration.zero) _finishRunning();
      }
    }
  }

  Future<void> _finishRunning() async {
    /* ---------------- ④: mounted 검사 최상단 ---------------- */
    if (!mounted) return;
    _timer?.cancel();
    _locationSubscription.cancel();
    /* ------------------------------------------------------- */

    final end = DateTime.now();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryPage(
          distance: distance,
          duration: elapsedTime,
          calories: distance * 60,
          pace: _pace(),
          path: _path,
          startTime: _start ?? end.subtract(elapsedTime),
          endTime: end,
          isUnlimited: widget.isUnlimited,
          isDistanceMode: widget.isDistanceMode,
        ),
      ),
    );
  }

  double _pace() => (elapsedTime.inSeconds == 0 || distance == 0)
      ? 0
      : (elapsedTime.inSeconds / 60) / distance;

  String _fmtDur(Duration d) =>
      '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), duration: const Duration(seconds: 1)),
  );

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

  /* ---------------- ②: build 첫 줄 변경 ------------------- */
  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      _minimize();
      return false; // Route pop 방지
    },
    child: isMapMode ? _map() : _main(),
  );
  /* ------------------------------------------------------- */

  Widget _main() {
    final mainValue = widget.isUnlimited
        ? (widget.isDistanceMode ? distance : elapsedTime)
        : (widget.isDistanceMode
        ? (widget.distanceGoal - distance).clamp(0, widget.distanceGoal)
        : (widget.timeGoal - elapsedTime));
    return Scaffold(
      appBar: AppBar(
        /* -------- ③: AppBar leading 추가 -------- */
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _minimize,
        ),
        /* --------------------------------------- */
        title: const Text('자유 러닝', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: isLocked,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.isDistanceMode
                  ? '${(mainValue as double).toStringAsFixed(2)} km'
                  : _fmtDur(mainValue as Duration),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      widget.isDistanceMode
                          ? _fmtDur(elapsedTime)
                          : '${distance.toStringAsFixed(2)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.isDistanceMode ? '소요 시간' : '이동 거리')
                  ],
                ),
                Column(
                  children: [
                    Text('${(distance * 60).toStringAsFixed(0)} kcal',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('소비 칼로리')
                  ],
                ),
                Column(
                  children: [
                    Text(_pace().toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('평균 페이스')
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pauseRunning,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.deepOrange),
                alignment: Alignment.center,
                child: Icon(isPaused ? Icons.play_arrow : Icons.pause,
                    size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => isMapMode = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child:
              const Text('지도 보기', style: TextStyle(color: Colors.white)),
            ),
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
              size: 32, color: Colors.white),
        ),
      ),
    );
  }

  Widget _map() {
    final mainValue = widget.isUnlimited
        ? (widget.isDistanceMode ? distance : elapsedTime)
        : (widget.isDistanceMode
        ? (widget.distanceGoal - distance).clamp(0, widget.distanceGoal)
        : (widget.timeGoal - elapsedTime));
    return Scaffold(
      body: AbsorbPointer(
        absorbing: isLocked,
        child: Stack(
          children: [
            NaverMap(
              onMapReady: (c) => _naverMapController = c,
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Text(
                        widget.isDistanceMode
                            ? '${(mainValue as double).toStringAsFixed(2)} km'
                            : _fmtDur(mainValue as Duration),
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(_fmtDur(elapsedTime),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Text('소요 시간')
                            ],
                          ),
                          Column(
                            children: [
                              Text('${(distance * 60).toStringAsFixed(0)} kcal',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Text('칼로리')
                            ],
                          ),
                          Column(
                            children: [
                              Text(_pace().toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Text('평균 페이스')
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _pauseRunning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.deepOrange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isPaused ? '재개' : '일시 정지',
                          style: const TextStyle(color: Colors.deepOrange)),
                    ),
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
                        child: const Text('운동 종료',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: IconButton(
                onPressed: () => setState(() => isMapMode = false),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
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
              size: 32, color: Colors.white),
        ),
      ),
    );
  }
}
