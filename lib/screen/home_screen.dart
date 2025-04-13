import 'package:cash/screen/tabs/cash_talk/cash_talk_tab.dart';
import 'package:flutter/material.dart';
import 'package:cash/screen/tabs/home_tab.dart';
import 'package:cash/screen/tabs/benefit_tab.dart';
import 'package:cash/screen/tabs/coupon_tab.dart';
import 'package:cash/screen/tabs/settings_tab.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    HomeTab(),        // 홈
    Container(),      // 캐시톡은 비워둠 (탭 이동이 아니니까)
    BenefitTab(),     // 혜택
    CouponTab(),      // 교환권
    SettingsTab(),    // 설정
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // 캐시톡 버튼 클릭 시
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CashTalkTab()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.yellow[700],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '캐시톡'),
          BottomNavigationBarItem(icon: Icon(Icons.cached), label: '혜택'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: '교환권'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
