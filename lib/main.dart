import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cash/screen/login_screen.dart';
import 'package:cash/screen/home_screen.dart';
import 'package:cash/utils/jwt_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(nativeAppKey: 'c651375070bb8a02f40ab9b246630fa7');

  await initializeDateFormatting('ko_KR', null);

  await NaverMapSdk.instance.initialize(
    clientId: "kdbzid2etj",
  );

  String? token = await JwtStorage.getToken();

  runApp(MyApp(initialScreen: token != null ? HomePage() : const LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashwalk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: initialScreen,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
    );
  }
}
