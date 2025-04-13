import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class WalkTab extends StatefulWidget {
  const WalkTab({super.key});

  @override
  State<WalkTab> createState() => _WalkTabState();
}

class _WalkTabState extends State<WalkTab> {
  late NaverMapController _controller;
  final Location _location = Location();
  final String clientId = 'GR1PGUUTePOB03AI3MXS';
  final String clientSecret = 'ExsIFOtSGr';

  LocationData? _currentLocation;
  Map<String, dynamic>? _selectedPark; // 선택된 공원 데이터 저장
  List<Map<String, dynamic>> _nearbyParks = [];

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

  double _degToRad(double degree) => degree * pi / 180;

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반지름 km
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
                sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _searchNearbyParks(double myLat, double myLng) async {
    final String query = '공원';
    final String apiUrl = 'https://openapi.naver.com/v1/search/local.json?query=$query&display=10&sort=comment';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final parks = data['items'] ?? [];

      List<Map<String, dynamic>> nearbyParks = [];

      for (var park in parks) {
        double? lat = double.tryParse(park['mapy']) != null ? double.parse(park['mapy']) / 1e7 : null;
        double? lng = double.tryParse(park['mapx']) != null ? double.parse(park['mapx']) / 1e7 : null;

        if (lat != null && lng != null) {
          double distance = _calculateDistance(myLat, myLng, lat, lng);
          if (distance <= 5.0) { //
            park['lat'] = lat;
            park['lng'] = lng;
            park['distance'] = distance;
            nearbyParks.add(Map<String, dynamic>.from(park));
          }
        }
      }

      // 거리순으로 정렬
      nearbyParks.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      setState(() {
        _nearbyParks = nearbyParks;
        if (_nearbyParks.isNotEmpty) {
          _selectedPark = _nearbyParks.first;
        }
      });

      // 지도에 마커 추가
      for (var park in nearbyParks) {
        final marker = NMarker(
          id: park['title'],
          position: NLatLng(park['lat'], park['lng']),
          icon: NOverlayImage.fromAssetImage('assets/images/tree.png'), // 🌳 나무 아이콘
          caption: NOverlayCaption(text: park['title']),
        );

        marker.setOnTapListener((NMarker marker) {
          setState(() {
            _selectedPark = park; // 여기서 park는 외부에서 이미 확보된 park 데이터
          });
        });


        _controller.addOverlay(marker);
      }
    } else {
      print('공원 검색 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

              _currentLocation = await _determinePosition();
              if (_currentLocation != null) {
                await _controller.updateCamera(
                  NCameraUpdate.fromCameraPosition(
                    NCameraPosition(
                      target: NLatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                      zoom: 16,
                    ),
                  ),
                );

                _searchNearbyParks(_currentLocation!.latitude!, _currentLocation!.longitude!);
              }
            },
          ),

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
                    child: _buildBottomSheetContent(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetContent() {
    if (_selectedPark == null || _currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    double distanceMeters = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      _selectedPark!['lat'],
      _selectedPark!['lng'],
    ) * 1000; // km → m

    int steps = (distanceMeters / 0.7).round();
    double calories = steps * 0.033;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 손잡이
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

        // 제목
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

        // 공원 이름 박스
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
            children: [
              const Icon(Icons.place, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                _selectedPark!['title'].replaceAll(RegExp(r'<[^>]*>'), ''),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 주변 장소 수
        Row(
          children: [
            const Icon(Icons.location_on, size: 20, color: Colors.blue),
            const SizedBox(width: 6),
            const Text('적립 받을 수 있는 내 주변 장소 : '),
            Text(
              '${_nearbyParks.length}개',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 현재 위치에서 거리 정보
        Row(
          children: [
            const Icon(Icons.directions_walk, size: 20),
            const SizedBox(width: 6),
            const Text('현재위치에서 '),
            Text('${steps}걸음', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text(' · '),
            Text('${distanceMeters.toStringAsFixed(0)}m', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text(' · '),
            Text('${calories.toStringAsFixed(1)}kcal 소모', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
