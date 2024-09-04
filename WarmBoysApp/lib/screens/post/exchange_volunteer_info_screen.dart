import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/firebase_helper.dart';
import '../../providers/custom_auth_provider.dart';
import '../history/history_detailed_screen.dart';

class ExchangeVolunteerInfoScreen extends StatefulWidget {
  final String inc;

  ExchangeVolunteerInfoScreen({
    required this.inc,
  });

  @override
  _ExchangeVolunteerInfoScreenState createState() =>
      _ExchangeVolunteerInfoScreenState();
}

class _ExchangeVolunteerInfoScreenState
    extends State<ExchangeVolunteerInfoScreen> {
  late Future<List<Map<String, dynamic>>> _activitiesFuture;
  Map<String, int> _selectedActivities = {};
  int _totalHours = 0;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final _uid = customAuthProvider.uid;
    if (_uid != null) {
      _activitiesFuture = FirebaseHelper.queryActivities(_uid, '메이트');
    } else {
      _activitiesFuture = Future.value([]);
    }
  }

  void _updateTotalHours() {
    setState(() {
      _totalHours =
          _selectedActivities.values.fold(0, (sum, hourDiff) => sum + hourDiff);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.inc == '1365'
            ? Text(
                "1365 봉사시간 신청",
                style: TextStyle(
                    fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400),
              )
            : Text(
                "대학교 봉사시간 신청",
                style: TextStyle(
                    fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400),
              ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.inc == '1365')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1365 회원 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 15),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '총 시간: $_totalHours 시간',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('에러가 발생했습니다.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('활동 기록이 없습니다.'));
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        children: snapshot.data!.map((activity) {
                          bool isSelected = _selectedActivities
                              .containsKey(activity['postId']);

                          return GestureDetector(
                            child: Card(
                              color: Colors.white,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 20, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          (activity['imgUrl'] != '')
                                              ? GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return Dialog(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: CircleAvatar(
                                                              radius: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.5,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      activity[
                                                                          'imgUrl']),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 40,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            activity['imgUrl']),
                                                  ),
                                                )
                                              : CircleAvatar(
                                                  radius: 40,
                                                  child: Icon(Icons.person),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activity['username'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "장소: ${activity['activityCity']} ${activity['activityGu']} ${activity['activityDong']}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            "날짜: ${activity['date']}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            "시간: ${activity['startTime']} ~ ${activity['endTime']}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            "활동 종류: ${activity['activityType']}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: widget.inc == '1365'
                                          ? activity['volunteer1365'] ==
                                                  'notApplied'
                                              ? (bool? value) {
                                                  setState(
                                                    () {
                                                      if (value == true) {
                                                        _selectedActivities[
                                                                activity[
                                                                    'postId']] =
                                                            activity[
                                                                'hourDiff'];
                                                      } else {
                                                        _selectedActivities
                                                            .remove(activity[
                                                                'postId']);
                                                      }
                                                      _updateTotalHours();
                                                    },
                                                  );
                                                }
                                              : null
                                          : activity['volunteerUniv'] ==
                                                  'notApplied'
                                              ? (bool? value) {
                                                  setState(
                                                    () {
                                                      if (value == true) {
                                                        _selectedActivities[
                                                                activity[
                                                                    'postId']] =
                                                            activity[
                                                                'hourDiff'];
                                                      } else {
                                                        _selectedActivities
                                                            .remove(activity[
                                                                'postId']);
                                                      }
                                                      _updateTotalHours();
                                                    },
                                                  );
                                                }
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryDetailedScreen(
                                      memberType: '메이트', activity: activity),
                                ),
                              )
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 30.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedActivities.isNotEmpty
                ? () async {
                    // firebase helper의 applyVolunteerTime에 건네줄 List<Map> 생성
                    List<Map<String, String>> selectedActivities =
                        _selectedActivities.keys
                            .map((key) => {
                                  'postId': key,
                                  'inc': widget.inc == '1365' ? '1365' : 'univ'
                                })
                            .toList();

                    bool result = await FirebaseHelper.applyVolunteerTime(
                        selectedActivities);

                    if (result) {
                      // 신청 성공
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('신청이 완료되었습니다.')),
                      );

                      // 화면 초기화
                      setState(() {
                        _selectedActivities.clear();
                        _activitiesFuture = FirebaseHelper.queryActivities(
                          Provider.of<CustomAuthProvider>(context,
                                  listen: false)
                              .uid!,
                          '메이트',
                        );
                        _totalHours = 0; // 리셋
                        _idController.clear();
                        _passwordController.clear();
                      });
                    } else {
                      // 신청 실패
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('신청에 실패했습니다. 다시 시도해주세요.')),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Color.fromARGB(255, 224, 73, 81),
              foregroundColor: Colors.white,
            ),
            child: Text(
              '신청하기',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'NotoSansKR',
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
