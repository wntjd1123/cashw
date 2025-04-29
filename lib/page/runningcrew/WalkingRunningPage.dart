import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math';

class WalkingRunningPage extends StatefulWidget {
  final String modeTitle;  // 운동 모드 제목
  final double distanceGoal;
  final Duration timeGoal;
  final int stretchingSeconds; // 스트레칭 시간
  final int runningSeconds;   // 걷기 시간
  final bool voiceGuideOn;  // 음성 가이드 매개변수 (옵셔널로 변경)

  const WalkingRunningPage({
    super.key,
    required this.modeTitle,
    this.distanceGoal = 0.0,
    this.timeGoal = Duration.zero,
    required this.stretchingSeconds,
    required this.runningSeconds,
    this.voiceGuideOn = false,  // 기본값을 false로 설정
  });

  @override
  State<WalkingRunningPage> createState() => _WalkingRunningPageState();
}


class _WalkingRunningPageState extends State<WalkingRunningPage> {
  bool isMapMode = false;
  bool isPaused = false;

  double distance = 0.0; // km
  Duration elapsedTime = Duration.zero;
  Timer? _timer;

  late Location _location;
  late StreamSubscription<LocationData> _locationSubscription;
  List<NLatLng> _path = [];

  NaverMapController? _naverMapController;

  @override
  void initState() {
    super.initState();
    _startRunning();
    _startLocationUpdates();
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

  void _pauseRunning() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final currentLatLng = NLatLng(locationData.latitude!, locationData.longitude!);

        setState(() {
          if (_path.isNotEmpty) {
            distance += _calculateDistance(
              _path.last.latitude,
              _path.last.longitude,
              currentLatLng.latitude,
              currentLatLng.longitude,
            );
          }
          _path.add(currentLatLng);

          _naverMapController?.updateCamera(
            NCameraUpdate.withParams(
              target: currentLatLng,
              zoom: 16,
            ),
          );

          if (_naverMapController != null && _path.length >= 2) {
            _naverMapController!.clearOverlays();
            _naverMapController!.addOverlay(NPolylineOverlay(
              id: 'running_path',
              coords: _path,
              color: Colors.red,
              width: 4,
            ));
          }
        });
      }
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371e3; // meters
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c / 1000; // meters -> km
  }

  void _checkGoalReached() {
    if (distance >= widget.distanceGoal || elapsedTime >= widget.timeGoal) {
      _finishRunning();
    }
  }

  double _calculateCalories() {
    return distance * 60; // 대략적인 칼로리 계산
  }

  double _calculatePace() {
    if (elapsedTime.inSeconds == 0 || distance == 0) return 0.0;
    return (elapsedTime.inSeconds / 60) / distance;
  }

  void _finishRunning() {
    _timer?.cancel();
    _locationSubscription.cancel();

    final now = DateTime.now();
    final start = now.subtract(elapsedTime);


  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void _switchToMapMode() {
    setState(() {
      isMapMode = true;
    });
  }

  void _exitMapMode() {
    setState(() {
      isMapMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isMapMode ? _buildMapRunningScreen() : _buildNormalRunningScreen();
  }

  Widget _buildNormalRunningScreen() {
    final mainValue = widget.distanceGoal > 0.0
        ? distance
        : elapsedTime;

    final subValue = _formatDuration(elapsedTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modeTitle, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.distanceGoal > 0.0
                ? '${(mainValue as double).toStringAsFixed(2)} km'
                : _formatDuration(mainValue as Duration),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    widget.distanceGoal > 0.0 ? _formatDuration(elapsedTime) : '${distance.toStringAsFixed(2)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('소요 시간'),
                ],
              ),
              Column(
                children: [
                  Text('${_calculateCalories().toStringAsFixed(0)} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('소비 칼로리'),
                ],
              ),
              Column(
                children: [
                  Text('${_calculatePace().toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('평균 페이스'),
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
                shape: BoxShape.circle,
                color: Colors.deepOrange,
              ),
              alignment: Alignment.center,
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _switchToMapMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('지도 보기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMapRunningScreen() {
    final mainValue = widget.distanceGoal > 0.0
        ? distance
        : elapsedTime;

    final subValue = _formatDuration(elapsedTime);

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) {
              _naverMapController = controller;
            },
            options: const NaverMapViewOptions(
              locationButtonEnable: true,
              mapType: NMapType.basic,
              activeLayerGroups: [NLayerGroup.building],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.1,
            maxChildSize: 0.35,
            builder: (context, scrollController) {
              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                widget.distanceGoal > 0.0 ? '거리 목표 러닝' : '시간 목표 러닝',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.distanceGoal > 0.0
                                  ? '${(mainValue as double).toStringAsFixed(2)} km'
                                  : _formatDuration(mainValue as Duration),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      widget.distanceGoal > 0.0
                                          ? _formatDuration(elapsedTime)
                                          : '${distance.toStringAsFixed(2)} km',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Text('소요 시간'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('${_calculateCalories().toStringAsFixed(0)} kcal',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Text('소비 칼로리'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('${_calculatePace().toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const Text('평균 페이스'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

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
                    onPressed: _pauseRunning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.deepOrange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isPaused ? '재개' : '일시 정지',
                      style: const TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _finishRunning,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('운동 종료', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: IconButton(
              onPressed: _exitMapMode,
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
