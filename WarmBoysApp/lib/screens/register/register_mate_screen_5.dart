import 'package:flutter/material.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 4(메이트)
class RegisterMateScreen5 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterMateScreen5({required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterMateScreen5State createState() => _RegisterMateScreen5State();
}

class _RegisterMateScreen5State extends State<RegisterMateScreen5> {
  List<DayCard> _dayCards = [];
  List<String> _daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];
  Set<String> _usedDays = Set();
  Map<String, dynamic> _dayTime = {};

  bool get _hasCompletedCard {
    return _dayCards.any((card) => card.isCompleted);
  }

  @override
  void initState() {
    super.initState();
    _loadDayTimeData();
  }

  Future<void> _loadDayTimeData() async {
    Map<String, dynamic>? dayTimeMap =
        await SharedPreferencesHelper.getJson('_dayTime');
    if (dayTimeMap != null) {
      setState(() {
        _dayTime = dayTimeMap;
        _dayCards = dayTimeMap.keys.map((day) {
          Map<String, String> times = Map<String, String>.from(dayTimeMap[day]);
          _usedDays.add(day);
          return DayCard(
            daysOfWeek: _daysOfWeek,
            usedDays: _usedDays,
            onComplete: _completeDayCard,
            onDelete: _deleteDayCard,
            selectedDay: day,
            startTime: DateTime.parse(
                times['startTime'] ?? DateTime.now().toIso8601String()),
            endTime: DateTime.parse(
                times['endTime'] ?? DateTime.now().toIso8601String()),
            isCompleted: true,
          );
        }).toList();
      });
    }
  }

  Future<void> _saveDayTimeData() async {
    Map<String, Map<String, String>> dayTimeMap = {};
    for (DayCard card in _dayCards) {
      if (card.isCompleted) {
        dayTimeMap[card.selectedDay!] = {
          'startTime': card.startTime!.toIso8601String(),
          'endTime': card.endTime!.toIso8601String(),
        };
      }
    }
    await SharedPreferencesHelper.saveJson('_dayTime', dayTimeMap);
    setState(() {
      _dayTime = dayTimeMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('언제 활동할 수 있나요?',
            style: TextStyle(
                fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onPreviousPage,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAvailableTimeSection(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dayCards.length + 1,
                itemBuilder: (context, index) {
                  if (index == _dayCards.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_usedDays.length < _daysOfWeek.length) {
                            setState(() {
                              _dayCards.add(DayCard(
                                daysOfWeek: _daysOfWeek,
                                usedDays: _usedDays,
                                onComplete: _completeDayCard,
                                onDelete: _deleteDayCard,
                              ));
                            });
                          }
                        },
                        child: Text('+', style: TextStyle(fontSize: 24)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(60, 40),
                        ),
                      ),
                    );
                  }
                  return _dayCards[index];
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: _hasCompletedCard
              ? () async {
                  await _saveDayTimeData();
                  widget.onNextPage();
                }
              : null,
          child: Text('다음으로',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w500)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Color.fromARGB(255, 224, 73, 81),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void _completeDayCard(DayCard card) {
    setState(() {
      if (card.selectedDay != null) {
        _usedDays.add(card.selectedDay!);
      }
      _saveDayTimeData();
    });
  }

  void _deleteDayCard(DayCard card) {
    setState(() {
      _dayCards.remove(card);
      if (card.selectedDay != null) {
        _usedDays.remove(card.selectedDay!);
      }
      _saveDayTimeData();
    });
  }

  Widget _buildAvailableTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '활동 가능 시간',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _daysOfWeek.map((day) {
              final dayInfo = _dayTime[day];
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
      ],
    );
  }
}

class DayCard extends StatefulWidget {
  final List<String> daysOfWeek;
  final Set<String> usedDays;
  final Function(DayCard) onComplete;
  final Function(DayCard) onDelete;

  String? selectedDay;
  DateTime? startTime;
  DateTime? endTime;
  bool isCompleted = false;

  DayCard({
    required this.daysOfWeek,
    required this.usedDays,
    required this.onComplete,
    required this.onDelete,
    this.selectedDay,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
  });

  @override
  _DayCardState createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  List<String> _startTimes = [
    '오전 9시',
    '오전 10시',
    '오전 11시',
    '정오',
    '오후 1시',
    '오후 2시',
    '오후 3시',
    '오후 4시',
    '오후 5시',
    '오후 6시',
    '오후 7시',
    '오후 8시',
  ];

  List<String> _getEndTimes(String startTime) {
    int startIndex = _startTimes.indexOf(startTime) + 1;
    return _startTimes.sublist(startIndex);
  }

  bool get _canComplete {
    return widget.selectedDay != null &&
        widget.startTime != null &&
        widget.endTime != null;
  }

  String _timeToString(DateTime time) {
    int hour = time.hour;
    if (hour == 12) return '정오';
    String period = hour < 12 ? '오전' : '오후';
    if (hour > 12) hour -= 12;
    return '$period $hour시';
  }

  DateTime _stringToTime(String time) {
    if (time == '정오') return DateTime(0, 1, 1, 12);
    List<String> parts = time.split(' ');
    int hour = int.parse(parts[1].replaceAll('시', ''));
    if (parts[0] == '오후' && hour < 12) hour += 12;
    return DateTime(0, 1, 1, hour);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.isCompleted) ...[
                  Text(widget.selectedDay ?? '요일'),
                  Text(_timeToString(widget.startTime!)),
                  Text('~'),
                  Text(_timeToString(widget.endTime!)),
                ] else ...[
                  DropdownButton<String>(
                    hint: Text('요일'),
                    value: widget.selectedDay,
                    onChanged: (String? newValue) {
                      if (!widget.isCompleted &&
                          newValue != null &&
                          !widget.usedDays.contains(newValue)) {
                        setState(() {
                          widget.selectedDay = newValue;
                        });
                      }
                    },
                    items: widget.daysOfWeek
                        .where((day) => !widget.usedDays.contains(day))
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    hint: Text('시작 시간'),
                    value: widget.startTime != null
                        ? _timeToString(widget.startTime!)
                        : null,
                    onChanged: (String? newValue) {
                      if (!widget.isCompleted && newValue != null) {
                        setState(() {
                          widget.startTime = _stringToTime(newValue);
                          widget.endTime = null;
                        });
                      }
                    },
                    items: _startTimes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    hint: Text('종료 시간'),
                    value: widget.endTime != null
                        ? _timeToString(widget.endTime!)
                        : null,
                    onChanged: (String? newValue) {
                      if (!widget.isCompleted &&
                          widget.startTime != null &&
                          newValue != null) {
                        setState(() {
                          widget.endTime = _stringToTime(newValue);
                        });
                      }
                    },
                    items: widget.startTime == null
                        ? []
                        : _getEndTimes(_timeToString(widget.startTime!))
                            .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                  ),
                ],
                SizedBox(width: 8),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _canComplete
                          ? () {
                              setState(() {
                                widget.isCompleted = true;
                                widget.onComplete(widget);
                              });
                            }
                          : null,
                      child: Text('O', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(40, 40),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => widget.onDelete(widget),
                      child: Text('X', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(40, 40),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
