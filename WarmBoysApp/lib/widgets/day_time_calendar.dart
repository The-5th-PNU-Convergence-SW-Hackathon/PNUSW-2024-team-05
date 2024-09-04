import 'package:flutter/material.dart';

class DayTimeCalendar extends StatelessWidget {
  final Map<String, dynamic> dayTime;

  DayTimeCalendar({required this.dayTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _daysOfWeek.map((day) {
              final dayInfo = dayTime[day];
              final startTime =
                  dayInfo != null ? DateTime.parse(dayInfo['startTime']) : null;
              final endTime =
                  dayInfo != null ? DateTime.parse(dayInfo['endTime']) : null;
              final isMorning = startTime != null &&
                  endTime != null &&
                  startTime.hour < 12 &&
                  endTime.hour < 12;
              final isAfternoon = startTime != null &&
                  endTime != null &&
                  startTime.hour >= 12 &&
                  endTime.hour >= 12;
              final isFullDay = startTime != null &&
                  endTime != null &&
                  startTime.hour < 12 &&
                  endTime.hour >= 12;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: dayInfo != null
                          ? Color.fromARGB(255, 224, 73, 81)
                          : Colors.grey,
                      child: Text(
                        day,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 5),
                    Icon(
                      Icons.wb_sunny,
                      size: 30,
                      color: isMorning || isFullDay
                          ? Color.fromARGB(255, 224, 73, 81)
                          : Colors.grey,
                    ),
                    SizedBox(height: 5),
                    Icon(
                      Icons.nights_stay,
                      size: 30,
                      color: isAfternoon || isFullDay
                          ? Color.fromARGB(255, 224, 73, 81)
                          : Colors.grey,
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
        Column(
          children: _daysOfWeek.map((day) {
            final dayInfo = dayTime[day];
            if (dayInfo != null) {
              final startTime = DateTime.parse(dayInfo['startTime']);
              final endTime = DateTime.parse(dayInfo['endTime']);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day:  ${_formatTime(startTime)} ~ ${_formatTime(endTime)}',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              );
            } else {
              return SizedBox(); // dayInfo가 없으면 빈 위젯 반환
            }
          }).toList(),
        ),
      ],
    );
  }

  List<String> get _daysOfWeek => ['일', '월', '화', '수', '목', '금', '토'];
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
