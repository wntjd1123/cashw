import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordTab extends StatefulWidget {
  const RecordTab({super.key});

  @override
  State<RecordTab> createState() => _RecordTabState();
}

class _RecordTabState extends State<RecordTab> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('yyyy년 MM월', 'ko').format(selectedDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("KRJNF6BN님", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("이번 주는 총 0일 산책했어요.", style: TextStyle(fontSize: 14)),
                    Text("* 산책 일수는 매주 월요일 자정에 초기화 됩니다.", style: TextStyle(fontSize: 12, color: Colors.grey))
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in ["월", "화", "수", "목", "금", "토", "일"])
                  _buildDayCircle(day, day == "일"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 6, height: 6, color: Color(0xFFF2F2F2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Row(
                    children: [
                      Text(
                        currentMonth,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('총 산책 횟수 : 0회', style: TextStyle(fontSize: 13)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendar(selectedDate),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ko'),
      helpText: '날짜 선택',
      fieldHintText: 'yyyy-MM-dd',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildDayCircle(String label, bool isDashed) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey,
              style: isDashed ? BorderStyle.solid : BorderStyle.solid,
              width: isDashed ? 1.2 : 1.0,
            ),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }


  Widget _buildCalendar(DateTime referenceDate) {
    final startOfMonth = DateTime(referenceDate.year, referenceDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(referenceDate.year, referenceDate.month);
    final startWeekday = startOfMonth.weekday % 7; // 일요일 시작

    final totalItems = startWeekday + daysInMonth;
    final rows = (totalItems / 7).ceil();
    final totalGridItems = rows * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: totalGridItems,
      itemBuilder: (context, index) {
        final dayNum = index - startWeekday + 1;
        final isValid = dayNum > 0 && dayNum <= daysInMonth;

        return Center(
          child: isValid
              ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dayNum == DateTime.now().day && referenceDate.month == DateTime.now().month
                  ? const Color(0xFFFEE500)
                  : null,
            ),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '$dayNum',
              style: TextStyle(
                color: dayNum == DateTime.now().day && referenceDate.month == DateTime.now().month
                    ? Colors.black
                    : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
