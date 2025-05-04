import 'package:flutter/material.dart';

/// 러닝 세션은 한 번에 하나만 존재한다는 전제의 싱글턴
class RunningSessionManager {
  RunningSessionManager._();
  static final RunningSessionManager I = RunningSessionManager._();

  Route?                   _route;     // 현재 살아있는 러닝 Route
  Future<void> Function()? _onFinish;  // 러닝 종료 콜백
  WidgetBuilder?           _builder;   // 다시 띄울 때 쓸 builder

  bool get hasActive => _route != null;

  /// 러닝 시작 시 반드시 호출
  void register(Route route,
      Future<void> Function() onFinish,
      WidgetBuilder builder) {
    _route    = route;
    _onFinish = onFinish;
    _builder  = builder;
  }

  /// 러닝 강제 종료
  Future<void> stopRunning() async {
    if (_onFinish != null) await _onFinish!();
    _route    = null;
    _onFinish = null;
    _builder  = null;
  }

  /// “현재 진행중인 러닝으로 이동하기” 배너용
  void bringToFront(BuildContext context) {
    if (_route == null) return;

    final nav = Navigator.of(context);
    var found = false;
    nav.popUntil((r) {
      if (r == _route) found = true;
      return found || r.isFirst;
    });

    if (!found && _builder != null) {
      nav.push(MaterialPageRoute(builder: _builder!));
    }
  }

  /*──────────────── 새로 추가된 헬퍼 ────────────────*/

  /// 다른 세션이 있으면 종료하고, 없으면 바로 builder로 전환한다.
  static Future<void> switchTo(BuildContext ctx, WidgetBuilder builder) async {
    if (RunningSessionManager.I.hasActive) {
      final ok = await showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          content: const Text('현재 진행중인 러닝기록이 있습니다.\n러닝을 그만할까요?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('아니오')),
            TextButton(onPressed: () => Navigator.pop(_, true),  child: const Text('네')),
          ],
        ),
      ) ?? false;
      if (!ok) return;
      await RunningSessionManager.I.stopRunning();
    }
    Navigator.push(ctx, MaterialPageRoute(builder: builder));
  }
}
