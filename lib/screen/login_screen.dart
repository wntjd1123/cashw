import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cash/utils/jwt_storage.dart'; // ✅ JWT 저장용 클래스
import 'package:cash/screen/home_screen.dart'; // ✅ 홈 화면 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _jwtToken;
  String? _userInfo;

  /// 🔐 구글 로그인 핸들러
  Future<void> _handleGoogleLogin() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      serverClientId: '899929648402-bbil6484g4onafr7a44nf53a4189fl3p.apps.googleusercontent.com',
    );

    try {
      final account = await _googleSignIn.signIn();
      final auth = await account?.authentication;
      final idToken = auth?.idToken;

      print('✅ Google 로그인 성공!');
      print('ID Token: $idToken');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        String jwt = response.body;
        setState(() {
          _jwtToken = jwt;
        });
        print('✅ JWT 저장 완료: $_jwtToken');

        await JwtStorage.saveToken(jwt);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('❌ 서버 응답 실패: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Google 로그인 실패: $error');
    }
  }

  /// 🔐 카카오 로그인 핸들러
  Future<void> _handleKakaoLogin() async {
    try {
      bool kakaoInstalled = await isKakaoTalkInstalled();

      OAuthToken token = kakaoInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();

      print('✅ 카카오 로그인 성공!');
      print('AccessToken: ${token.accessToken}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/auth/kakao'),
        headers: {'Content-Type': 'application/json'},
        body: '"${token.accessToken}"',
      );

      if (response.statusCode == 200) {
        String jwt = response.body;
        setState(() {
          _jwtToken = jwt;
        });
        print('✅ JWT 저장 완료: $_jwtToken');

        await JwtStorage.saveToken(jwt);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('❌ 서버 응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
    }
  }

  /// 👤 사용자 정보 요청
  Future<void> _getMyInfo() async {
    if (_jwtToken == null) {
      print('❌ JWT 토큰이 없습니다. 먼저 로그인하세요.');
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/users/me'),
      headers: {
        'Authorization': 'Bearer $_jwtToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _userInfo = response.body;
      });
      print('👤 사용자 정보: ${response.body}');
    } else {
      print('❌ 사용자 정보 요청 실패: ${response.statusCode}');
    }
  }

  /// 🚀 건너뛰기 버튼 핸들러
  void _skipLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleKakaoLogin,
              child: const Text('카카오 로그인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleGoogleLogin,
              child: const Text('구글 로그인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getMyInfo,
              child: const Text('내 정보 불러오기'),
            ),
            const SizedBox(height: 20),
            // 👇 건너뛰기 버튼 추가
            TextButton(
              onPressed: _skipLogin,
              child: const Text(
                '건너뛰기',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            if (_userInfo != null) ...[
              const Text(
                '👤 내 정보',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(_userInfo ?? ''),
            ],
          ],
        ),
      ),
    );
  }
}
