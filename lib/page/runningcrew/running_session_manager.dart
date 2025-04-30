import 'package:flutter/material.dart';

/// ‼️ 러닝 세션은 한 번에 하나만 존재한다는 전제의 싱글턴
class RunningSessionManager {
  RunningSessionManager._();                        // private ctor
  static final RunningSessionManager I              // ← 여기! (.I 로 접근)
  = RunningSessionManager._();

  Route?                   _route;      // 현재 살아있는 러닝 Route
  Future<void> Function()? _onFinish;   // 러닝 종료 콜백
  WidgetBuilder?           _builder;    // 사라진 경우 다시 띄울 빌더

  bool get hasActive => _route != null;

  /// 러닝 시작 시 반드시 호출
  void register(Route route,
      Future<void> Function() onFinish,
      WidgetBuilder builder) {
    _route    = route;
    _onFinish = onFinish;
    _builder  = builder;
  }

  /// 러닝 강제 종료 (예: 네, 그만할래요)
  Future<void> stopRunning() async {
    if (_onFinish != null) await _onFinish!();
    _route    = null;
    _onFinish = null;
    _builder  = null;
  }

  /// “현재 진행중인 러닝으로 이동하기” 버튼
  void bringToFront(BuildContext context) {
    if (_route == null) return;

    final nav = Navigator.of(context);
    var found = false;

    // 1️⃣ 스택에 Route 가 남아 있는지 확인
    nav.popUntil((r) {
      if (r == _route) found = true;
      return found || r.isFirst;           // 맨 아래서 멈춤
    });

    // 2️⃣ 없으면 새로 push
    if (!found && _builder != null) {
      nav.push(MaterialPageRoute(builder: _builder!));
    }
  }
}
