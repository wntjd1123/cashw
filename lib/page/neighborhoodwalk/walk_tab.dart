import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';

class WalkTab extends StatefulWidget {
  const WalkTab({super.key});

  @override
  State<WalkTab> createState() => _WalkTabState();
}

class _WalkTabState extends State<WalkTab> {
  late NaverMapController _controller;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  void _requestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<LocationData?> _determinePosition() async {
    try {
      return await _location.getLocation();
    } catch (e) {
      print('위치 가져오기 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.5665, 126.9780),
                zoom: 16,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: (controller) async {
              _controller = controller;

              final locationData = await _determinePosition();
              if (locationData != null) {
                await _controller.updateCamera(
                  NCameraUpdate.fromCameraPosition(
                    NCameraPosition(
                      target: NLatLng(locationData.latitude!, locationData.longitude!),
                      zoom: 16,
                    ),
                  ),
                );
              }
            },
          ),

          // 아래에서 올라오는 바텀시트
          DraggableScrollableSheet(
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // 위에 손잡이
                    Center(
                    child: Container(
                    width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // 1. 제목 + 파란 강조
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(text: '산책해서 '),
                        TextSpan(
                          text: '10캐시 ',
                          style: TextStyle(
                            color: Colors.blue[600],
                          ),
                        ),
                        const TextSpan(text: '적립 받기'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. 네모난 박스 안에 위치
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.place, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          '안서3공원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. 주변 적립 장소 수
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.blue),
                      const SizedBox(width: 6),
                      const Text('적립 받을 수 있는 내 주변 장소 : '),
                      Text(
                        '개',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4. 현재 위치 정보
                  Row(
                      children: [
                      const Icon(Icons.directions_walk, size: 20),
                  const SizedBox(width: 6),
                  const Text('현재위치에서 '),
                  Text(
                    '걸음',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(' · '),
                  Text(
                    'm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(' · '),
                  Text(
                    'kcal 소모',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,),
                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
