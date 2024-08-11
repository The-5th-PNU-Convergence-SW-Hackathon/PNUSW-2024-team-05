import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/member_symptom_scrollview.dart';
import '../../widgets/member_details_scrollview.dart';
import '../../widgets/autowrap_text_box.dart';
import '../../utils/firebase_helper.dart';
import '../../widgets/profile_card.dart';

class PostScreen extends StatefulWidget {
  final String memberType;
  final String myUid;
  final String postId;
  final String seniorUid;
  final String seniorName;
  final String imgUrl;
  final String city;
  final String gu;
  final String dong;
  final String dependentType;
  final bool withPet;
  final bool withCam;
  final List<String> symptom;
  final String petInfo;
  final String symptomInfo;
  final String walkingType;
  final double rating;
  final int ratingCount;
  final String activityType;
  final DateTime startTime;
  final DateTime endTime;

  PostScreen({
    required this.memberType,
    required this.myUid,
    required this.postId,
    required this.seniorUid,
    required this.seniorName,
    required this.imgUrl,
    required this.city,
    required this.gu,
    required this.dong,
    required this.dependentType,
    required this.withPet,
    required this.withCam,
    required this.symptom,
    required this.petInfo,
    required this.symptomInfo,
    required this.walkingType,
    required this.rating,
    required this.ratingCount,
    required this.activityType,
    required this.startTime,
    required this.endTime,
  });

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? selectedActivityType;
  String? selectedStartTime;
  String? selectedEndTime;

  List<Map<String, dynamic>> myPosts = [];
  Map<DateTime, List<Map<String, dynamic>>> events = {};
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  final Map<String, DateTime> stringToDate = {
    '오전 9시': DateTime(1, 1, 1, 9),
    '오전 10시': DateTime(1, 1, 1, 10),
    '오전 11시': DateTime(1, 1, 1, 11),
    '정오': DateTime(1, 1, 1, 12),
    '오후 1시': DateTime(1, 1, 1, 13),
    '오후 2시': DateTime(1, 1, 1, 14),
    '오후 3시': DateTime(1, 1, 1, 15),
    '오후 4시': DateTime(1, 1, 1, 16),
    '오후 5시': DateTime(1, 1, 1, 17),
    '오후 6시': DateTime(1, 1, 1, 18),
    '오후 7시': DateTime(1, 1, 1, 19),
    '오후 8시': DateTime(1, 1, 1, 20),
    '오후 9시': DateTime(1, 1, 1, 21),
  };

  final Map<DateTime, String> dateToString = {
    DateTime(1, 1, 1, 9): '오전 9시',
    DateTime(1, 1, 1, 10): '오전 10시',
    DateTime(1, 1, 1, 11): '오전 11시',
    DateTime(1, 1, 1, 12): '정오',
    DateTime(1, 1, 1, 13): '오후 1시',
    DateTime(1, 1, 1, 14): '오후 2시',
    DateTime(1, 1, 1, 15): '오후 3시',
    DateTime(1, 1, 1, 16): '오후 4시',
    DateTime(1, 1, 1, 17): '오후 5시',
    DateTime(1, 1, 1, 18): '오후 6시',
    DateTime(1, 1, 1, 19): '오후 7시',
    DateTime(1, 1, 1, 20): '오후 8시',
    DateTime(1, 1, 1, 21): '오후 9시',
  };

  String checkStat = '';

  @override
  void initState() {
    super.initState();
    if (widget.memberType == '시니어' && widget.myUid == widget.seniorUid) {
      _fetchMyPosts();
    } else if (widget.memberType == '메이트') {
      _fetchCheckApply();
    }
  }

  Future<void> _fetchMyPosts() async {
    List<Map<String, dynamic>> fetchedPosts =
        await FirebaseHelper.queryMyPost(widget.myUid);
    setState(() {
      myPosts = fetchedPosts;
      _createEventList();
    });
  }

  Future<void> _fetchCheckApply() async {
    String status =
        await FirebaseHelper.checkApply(widget.postId, widget.myUid);
    setState(() {
      checkStat = status;
    });
  }

  void _createEventList() {
    Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};
    for (var post in myPosts) {
      DateTime startTime = DateTime(post['startTime'].year,
          post['startTime'].month, post['startTime'].day);
      if (tempEvents[startTime] == null) {
        tempEvents[startTime] = [];
      }
      tempEvents[startTime]!.add(post);
    }
    setState(() {
      events = tempEvents;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  bool get isPostButtonEnabled {
    return selectedActivityType != null &&
        selectedStartTime != null &&
        selectedEndTime != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Senior Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(
                imgUrl: widget.imgUrl,
                username: widget.seniorName,
                memberType: '시니어',
                uid: widget.seniorUid,
                city: widget.city,
                gu: widget.gu,
                dong: widget.dong,
                rating: widget.rating,
                ratingCount: widget.ratingCount,
              ),
              SizedBox(height: 30),
              _buildConditionalSection(),
              SizedBox(height: 30),
              Text(
                '회원 상세 정보',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              MemberDetailsScrollview(
                dependentType: widget.dependentType,
                withPet: widget.withPet,
                withCam: widget.withCam,
              ),
              SizedBox(height: 30),
              Text(
                '반려동물 상세 설명',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              AutowrapTextBox(text: widget.petInfo),
              SizedBox(height: 30),
              Text(
                '해당되는 증상',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              MemberSymptomScrollview(symptoms: widget.symptom),
              SizedBox(height: 30),
              Text(
                '증상 상세 설명',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              AutowrapTextBox(text: widget.symptomInfo),
              SizedBox(height: 30),
              Text(
                '거동 상태',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              MemberSymptomScrollview(symptoms: [widget.walkingType])
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionalSection() {
    if (widget.memberType == '시니어' && widget.myUid != widget.seniorUid) {
      return _buildSeniorOtherSection();
    } else if (widget.memberType == '메이트') {
      return _buildMateSection();
    } else if (widget.memberType == '시니어' && widget.myUid == widget.seniorUid) {
      return _buildSeniorSelfSection();
    } else {
      return Container();
    }
  }

  Widget _buildSeniorOtherSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("공고 상세 정보",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 10),
        _buildInfoBox([
          '활동 종류: ${widget.activityType}',
          '날짜: ${DateFormat('yy.M.d').format(widget.startTime)}',
          '시작 시간: ${_formatTime(widget.startTime)}',
          '종료 시간: ${_formatTime(widget.endTime)}',
        ])
      ],
    );
  }

  Widget _buildMateSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("공고 상세 정보",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 10),
        _buildInfoBox([
          '활동 종류: ${widget.activityType}',
          '날짜: ${DateFormat('yy.M.d').format(widget.startTime)}',
          '시작 시간: ${_formatTime(widget.startTime)}',
          '종료 시간: ${_formatTime(widget.endTime)}',
        ], hasButton: true)
      ],
    );
  }

  Widget _buildSeniorSelfSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "공고 게시 캘린더",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          eventLoader: _getEventsForDay,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          enabledDayPredicate: (day) {
            DateTime today = DateTime.now();
            DateTime onlyTodayDate =
                DateTime(today.year, today.month, today.day);
            return !day.isBefore(onlyTodayDate);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Color.fromARGB(255, 183, 183, 183),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color.fromARGB(255, 13, 0, 255),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 0, 0),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(height: 10.0),
        _buildSelectedDayInfo(),
      ],
    );
  }

  Widget _buildSelectedDayInfo() {
    final eventList = _getEventsForDay(_selectedDay ?? DateTime.now());
    if (eventList.isNotEmpty) {
      final event = eventList.first;
      return _buildEventInfoBox(event);
    } else {
      return _buildNewEventBox();
    }
  }

  Widget _buildEventInfoBox(Map<String, dynamic> event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '활동 종류:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '${event['activityType']}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '활동 날짜:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '${DateFormat('yy.M.d').format(event['startTime'])}',
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '시작 시간:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '${_formatTime(event['startTime'])}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '종료 시간:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '${_formatTime(event['endTime'])}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Call delete function from FirebaseHelper
                // FirebaseHelper.deletePost(event['postId']);
                // Refresh the screen
                print('선택한 포스트id: ${event['postId']}');
                bool success =
                    await FirebaseHelper.deleteMyPost(event['postId']);
                // 페이지 다시 라우트 (애니메이션 제거)
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          PostScreen(
                        memberType: widget.memberType,
                        myUid: widget.myUid,
                        postId: widget.postId,
                        seniorUid: widget.seniorUid,
                        seniorName: widget.seniorName,
                        imgUrl: widget.imgUrl,
                        city: widget.city,
                        gu: widget.gu,
                        dong: widget.dong,
                        dependentType: widget.dependentType,
                        withPet: widget.withPet,
                        withCam: widget.withCam,
                        symptom: widget.symptom,
                        petInfo: widget.petInfo,
                        symptomInfo: widget.symptomInfo,
                        walkingType: widget.walkingType,
                        rating: widget.rating,
                        ratingCount: widget.ratingCount,
                        activityType: widget.activityType,
                        startTime: widget.startTime,
                        endTime: widget.endTime,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  print("공고 삭제에 실패했습니다.");
                }
              },
              child: Text('삭제'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewEventBox() {
    return _buildInfoBox([
      '활동 종류',
      '시작 시간',
      '종료 시간',
    ], isSelf: true);
  }

  Widget _buildInfoBox(List<String> lines,
      {bool hasButton = false, bool isSelf = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var line in lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: isSelf
                    ? _buildSelfLine(line)
                    : Text(line, style: TextStyle(fontSize: 18)),
              ),
            if (hasButton) _buildMateApplyButton(), // '매칭 신청' 버튼
            if (isSelf)
              ElevatedButton(
                onPressed: isPostButtonEnabled
                    ? () async {
                        DateTime startTime = stringToDate[selectedStartTime!]!;
                        DateTime endTime = stringToDate[selectedEndTime!]!;

                        // 선택한 날짜의 연, 월, 일을 시작 시간과 종료 시간에 적용
                        startTime = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                            startTime.hour,
                            startTime.minute);
                        endTime = DateTime(
                            _selectedDay!.year,
                            _selectedDay!.month,
                            _selectedDay!.day,
                            endTime.hour,
                            endTime.minute);

                        Map<String, dynamic> postInfo = {
                          'seniorUid': widget.myUid,
                          'city': widget.city,
                          'gu': widget.gu,
                          'dong': widget.dong,
                          'activityType': selectedActivityType,
                          'startTime': startTime,
                          'endTime': endTime,
                        };
                        bool success =
                            await FirebaseHelper.postMyPost(postInfo);
                        // 페이지 다시 라우트 (애니메이션 제거)
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  PostScreen(
                                memberType: widget.memberType,
                                myUid: widget.myUid,
                                postId: widget.postId,
                                seniorUid: widget.seniorUid,
                                seniorName: widget.seniorName,
                                imgUrl: widget.imgUrl,
                                city: widget.city,
                                gu: widget.gu,
                                dong: widget.dong,
                                dependentType: widget.dependentType,
                                withPet: widget.withPet,
                                withCam: widget.withCam,
                                symptom: widget.symptom,
                                petInfo: widget.petInfo,
                                symptomInfo: widget.symptomInfo,
                                walkingType: widget.walkingType,
                                rating: widget.rating,
                                ratingCount: widget.ratingCount,
                                activityType: widget.activityType,
                                startTime: widget.startTime,
                                endTime: widget.endTime,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          print("공고 올리기에 실패했습니다.");
                        }
                      }
                    : null,
                child: Text('공고 올리기'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfLine(String label) {
    if (label == '활동 종류') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 18)),
          DropdownButton<String>(
            value: selectedActivityType,
            items: ['실내활동', '실외활동', '밥 챙겨주기', '책 읽기', '재능기부']
                .map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: TextStyle(fontSize: 18)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedActivityType = value;
              });
            },
          ),
        ],
      );
    } else if (label == '시작 시간') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 18)),
          DropdownButton<String>(
            value: selectedStartTime,
            items: stringToDate.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key, style: TextStyle(fontSize: 18)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStartTime = value;
                selectedEndTime = null;
              });
            },
          ),
        ],
      );
    } else if (label == '종료 시간') {
      final DateTime startTime = selectedStartTime == null
          ? DateTime.now()
          : stringToDate[selectedStartTime!]!;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 18)),
          DropdownButton<String>(
            value: selectedEndTime,
            items: stringToDate.entries
                .where((entry) => entry.value.isAfter(startTime))
                .map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.key, style: TextStyle(fontSize: 18)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedEndTime = value;
              });
            },
          ),
        ],
      );
    } else {
      return Text(label, style: TextStyle(fontSize: 18));
    }
  }

  String _formatTime(DateTime time) {
    // 나노초와 마이크로초를 0으로 설정하여 비교 정확도를 높임
    DateTime timeWithoutNanoseconds = DateTime(
      1,
      1,
      1,
      time.hour,
    );
    return dateToString[timeWithoutNanoseconds] ?? '';
  }

  Widget _buildMateApplyButton() {
    if (checkStat == 'postNotExists') {
      return Text('공고가 존재하지 않습니다.');
    } else if (checkStat == 'canApply') {
      return ElevatedButton(
        onPressed: () async {
          bool success =
              await FirebaseHelper.applyMatching(widget.postId, widget.myUid);
          if (success) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => PostScreen(
                  memberType: widget.memberType,
                  myUid: widget.myUid,
                  postId: widget.postId,
                  seniorUid: widget.seniorUid,
                  seniorName: widget.seniorName,
                  imgUrl: widget.imgUrl,
                  city: widget.city,
                  gu: widget.gu,
                  dong: widget.dong,
                  dependentType: widget.dependentType,
                  withPet: widget.withPet,
                  withCam: widget.withCam,
                  symptom: widget.symptom,
                  petInfo: widget.petInfo,
                  symptomInfo: widget.symptomInfo,
                  walkingType: widget.walkingType,
                  rating: widget.rating,
                  ratingCount: widget.ratingCount,
                  activityType: widget.activityType,
                  startTime: widget.startTime,
                  endTime: widget.endTime,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
        child: Text('매칭 신청'),
      );
    } else if (checkStat == 'alreadyApplied') {
      return ElevatedButton(
        onPressed: () async {
          bool success =
              await FirebaseHelper.cancelApply(widget.postId, widget.myUid);
          if (success) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => PostScreen(
                  memberType: widget.memberType,
                  myUid: widget.myUid,
                  postId: widget.postId,
                  seniorUid: widget.seniorUid,
                  seniorName: widget.seniorName,
                  imgUrl: widget.imgUrl,
                  city: widget.city,
                  gu: widget.gu,
                  dong: widget.dong,
                  dependentType: widget.dependentType,
                  withPet: widget.withPet,
                  withCam: widget.withCam,
                  symptom: widget.symptom,
                  petInfo: widget.petInfo,
                  symptomInfo: widget.symptomInfo,
                  walkingType: widget.walkingType,
                  rating: widget.rating,
                  ratingCount: widget.ratingCount,
                  activityType: widget.activityType,
                  startTime: widget.startTime,
                  endTime: widget.endTime,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
        child: Text('신청 취소'),
      );
    } else if (checkStat == 'error') {
      return Text('에러');
    } else {
      return Container();
    }
  }
}
