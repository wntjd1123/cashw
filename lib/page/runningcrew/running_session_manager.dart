import 'package:flutter/material.dart';


class RunningSessionManager {
  RunningSessionManager._();
  static final RunningSessionManager I = RunningSessionManager._();

  Route?                   _route;
  Future<void> Function()? _onFinish;
  WidgetBuilder?           _builder;

  bool get hasActive => _route != null;


  void register(Route route,
      Future<void> Function() onFinish,
      WidgetBuilder builder) {
    _route    = route;
    _onFinish = onFinish;
    _builder  = builder;
  }


  Future<void> stopRunning() async {
    if (_onFinish != null) await _onFinish!();
    _route    = null;
    _onFinish = null;
    _builder  = null;
  }


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
  void clear() {
    _route    = null;
    _onFinish = null;
    _builder  = null;
  }
}
