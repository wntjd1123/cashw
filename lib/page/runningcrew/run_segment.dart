
class RunSegment {
  /// 화면에 표시될 라벨 (예: 스트레칭 / 달리기 / 걷기 / 쿨다운)
  final String label;

  /// 구간 길이(초) — 분 * 60 으로 계산해 넘깁니다.
  final int seconds;

  /// 사용자가 OFF 할 수 없는 필수 구간 여부
  final bool mandatory;

  /// 실제로 실행할지 여부 (토글로 끈 경우 false)
  bool enabled;

  RunSegment(
      this.label,
      this.seconds, {
        this.mandatory = false,
        this.enabled = true,
      });
}
