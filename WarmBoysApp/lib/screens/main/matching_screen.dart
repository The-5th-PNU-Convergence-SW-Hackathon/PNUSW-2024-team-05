import 'package:flutter/material.dart';
import 'package:warm_boys/utils/firebase_helper.dart';
import '../../widgets/custom_app_bar_with_tab.dart';
import '../../widgets/custom_end_drawer.dart';
import 'package:provider/provider.dart';
import '../../providers/custom_auth_provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/member_details_scrollview.dart';
import '../../widgets/member_symptom_scrollview.dart';
import '../../widgets/autowrap_text_box.dart';
import '../activity/activity_screen.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/rate_stars.dart';
import '../review/rating_by_senior.dart';
import '../../screens/chatting/chat_screen.dart';
import '../../widgets/activity_type_scrollview.dart';
import '../../widgets/day_time_calendar.dart';
import 'dart:convert';

class MatchingScreen extends StatefulWidget {
  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Provider.of<CustomAuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('a h시')
        .format(dateTime)
        .replaceAll('AM', '오전')
        .replaceAll('PM', '오후');
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('yy.MM.dd').format(dateTime);
  }

// 메이트 정보 다이얼로그(시니어 시점)
  void _buildMateInfoDialog(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final List<String> activityType =
            (post['mateActivityType'] as List<dynamic>)
                .map((item) => item as String)
                .toList();
        final dayTime = jsonDecode(post['dayTime']);
        return Scaffold(
          appBar: AppBar(
            leading: Container(),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('닫기', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 2),
                        Icon(Icons.close),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  ProfileCard(
                      imgUrl: post['imgUrl'],
                      username: post['username'],
                      memberType: '메이트',
                      uid: post['uid'],
                      city: post['city'],
                      gu: post['gu'],
                      dong: post['dong'],
                      rating: post['rating'],
                      ratingCount: post['ratingCount']),
                  SizedBox(height: 30),
                  Text(
                    "신상 정보",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500]),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '이름',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  MemberSymptomScrollview(symptoms: [post['username']]),
                  // AutowrapTextBox(text: post['username']),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '나이',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  MemberSymptomScrollview(symptoms: [post['age']]),
                  // AutowrapTextBox(text: post['age']),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '성별',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  MemberSymptomScrollview(symptoms: [post['gender']]),
                  // AutowrapTextBox(text: post['gender']),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 50),
                  Text(
                    "활동 정보",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500]),
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '제공 서비스',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ActivityTypeScrollView(activityTypes: activityType),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '선호 활동 시간',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  DayTimeCalendar(dayTime: dayTime),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '메이트 소개글',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  AutowrapTextBox(text: post['addInfo']),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// 시니어 정보 다이얼로그(메이트 시점)
  void _buildSeniorInfoDialog(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            leading: Container(),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('닫기', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 2),
                        Icon(Icons.close),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  ProfileCard(
                      imgUrl: post['imgUrl'],
                      username: post['username'],
                      memberType: '시니어',
                      uid: post['uid'],
                      city: post['city'],
                      gu: post['gu'],
                      dong: post['dong'],
                      rating: post['rating'],
                      ratingCount: post['ratingCount']),
                  SizedBox(height: 30),
                  if (post['detailedAddress'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상세 주소',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        AutowrapTextBox(
                            text:
                                '${post['city']} ${post['gu']} ${post['dong']}, ${post['detailedAddress']}'),
                        SizedBox(height: 10),
                        Divider(
                          color: Color.fromARGB(255, 234, 234, 234),
                          thickness: 2,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  Text(
                    '시니어 주거 환경',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  MemberDetailsScrollview(
                      dependentType: post['dependentType'],
                      withPet: post['withPet'],
                      withCam: post['withCam']),
                  if (post['petInfo'] != '')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Divider(
                          color: Color.fromARGB(255, 234, 234, 234),
                          thickness: 2,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '반려동물 상세 설명',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        AutowrapTextBox(text: post['petInfo']),
                        SizedBox(height: 10),
                      ],
                    ),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '해당되는 증상',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  MemberSymptomScrollview(symptoms: post['symptom']),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '증상 상세 설명',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  AutowrapTextBox(text: post['symptomInfo']),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '거동 상태',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  MemberSymptomScrollview(symptoms: [post['walkingType']]),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '시니어 소개글',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  AutowrapTextBox(text: post['addInfo']),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  SizedBox(height: 16),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider = Provider.of<CustomAuthProvider>(context);
    final userInfo = customAuthProvider.userInfo;
    final myUid = customAuthProvider.uid;
    final memberType = userInfo?['memberType'];

    if (memberType == '메이트') {
      return _buildMateScaffold(myUid!);
    } else if (memberType == '시니어') {
      return _buildSeniorScaffold(myUid!);
    } else {
      return Scaffold(
        appBar: CustomAppBarWithTab(
          title: '매칭',
        ),
        body: Center(child: Text('알 수 없는 회원 타입입니다.')),
        endDrawer: CustomEndDrawer(),
      );
    }
  }

  // 메이트가 보는 화면
  Scaffold _buildMateScaffold(String myUid) {
    return Scaffold(
      appBar: CustomAppBarWithTab(
        title: '매칭',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color.fromARGB(255, 224, 73, 81), // 선택된 탭의 하단 라인 색상
          labelColor: Color.fromARGB(255, 224, 73, 81), // 선택된 탭의 텍스트 색상
          labelStyle:
              TextStyle(fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400),
          unselectedLabelColor: Colors.grey, // 선택되지 않은 탭의 텍스트 색상
          tabs: [
            Tab(text: '매칭 전'),
            Tab(text: '매칭 후'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 매칭 전 화면(메이트)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseHelper.queryNotMatchedByMate(myUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('매칭 전 공고가 없습니다.',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400)));
              } else {
                final posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          _buildSeniorInfoDialog(context, post);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 20,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            (post['imgUrl'] != '')
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
                                                                    .pop(); // 클릭 시 다이얼로그 닫기
                                                              },
                                                              child: Center(
                                                                child: Image
                                                                    .network(post[
                                                                        'imgUrl']), // 확대된 이미지
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 45,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              post['imgUrl']),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    radius: 45,
                                                    child: Icon(Icons.person),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    post['username'],
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    post['applyTimeText'],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              110,
                                                              110,
                                                              110),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () async {
                                                      final chatId =
                                                          await FirebaseHelper
                                                              .CreateChatRoomWithUserId(
                                                        post['uid'],
                                                      );
                                                      if (chatId != null) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChatScreen(
                                                                    chatId:
                                                                        chatId),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.chat, // 채팅 모양 아이콘
                                                      size: 22.0, // 아이콘 크기
                                                      color: Color.fromARGB(
                                                          255,
                                                          224,
                                                          73,
                                                          81), // 아이콘 색상
                                                    ),
                                                    tooltip:
                                                        '채팅하기', // 아이콘에 툴팁 제공 (선택 사항)
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  RatingStars(
                                                      rating: post['rating']),
                                                  Text(
                                                    "${post['rating'].toStringAsFixed(2)} (${post['ratingCount']})",
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${post['city']} ${post['gu']} ${post['dong']}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(
                                        255, 251, 242, 243), // 배경색
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 60,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '활동 날짜:  ${formatDate(post['startTime'])}',
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54)),
                                              Text(
                                                  '활동 시간: ${formatTime(post['startTime'])} ~ ${formatTime(post['endTime'])}',
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  )),
                                              Text(
                                                  '활동 종류:  ${post['activityType']}',
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54)),
                                              Text(
                                                '크레딧: ${post['credit'].toString()}',
                                                overflow: TextOverflow.visible,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 30,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            15),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                foregroundColor:
                                                                    const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        224,
                                                                        73,
                                                                        81)),
                                                        onPressed: () async {
                                                          await FirebaseHelper
                                                              .cancelApply(
                                                                  post[
                                                                      'postId'],
                                                                  myUid);
                                                          // 페이지 새로 고침
                                                          setState(() {});
                                                        },
                                                        child: Text(
                                                          '신청 취소',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          // 매칭 후 화면(메이트)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseHelper.queryMatchedByMate(myUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('매칭 후 공고가 없습니다.',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400)));
              } else {
                final posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          _buildSeniorInfoDialog(context, post);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 20,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            (post['imgUrl'] != '')
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
                                                                    .pop(); // 클릭 시 다이얼로그 닫기
                                                              },
                                                              child: Center(
                                                                child: Image
                                                                    .network(post[
                                                                        'imgUrl']), // 확대된 이미지
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 45,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              post['imgUrl']),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    radius: 45,
                                                    child: Icon(Icons.person),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10.0, 0, 0, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    post['username'],
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    post['acceptTimeText'],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              110,
                                                              110,
                                                              110),
                                                      // fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () async {
                                                      final chatId =
                                                          await FirebaseHelper
                                                              .CreateChatRoomWithUserId(
                                                        post['uid'],
                                                      );
                                                      if (chatId != null) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChatScreen(
                                                                    chatId:
                                                                        chatId),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.chat, // 채팅 모양 아이콘
                                                      size: 22.0, // 아이콘 크기
                                                      color: Color.fromARGB(
                                                          255,
                                                          224,
                                                          73,
                                                          81), // 아이콘 색상
                                                    ),
                                                    tooltip:
                                                        '채팅하기', // 아이콘에 툴팁 제공 (선택 사항)
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  RatingStars(
                                                      rating: post['rating']),
                                                  Text(
                                                      "${post['rating'].toStringAsFixed(2)} (${post['ratingCount']})",
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${post['city']} ${post['gu']} ${post['dong']}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 251, 242, 243),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 60,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '활동 날짜: ${formatDate(post['startTime'])}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  )),
                                              Text(
                                                  '활동 시간: ${formatTime(post['startTime'])} ~ ${formatTime(post['endTime'])}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  )),
                                              Text(
                                                  '활동 종류: ${post['activityType']} ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  )),
                                              Text('크레딧: ${post['credit']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 28,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: post['status'] ==
                                                            'matched'
                                                        ? () {
                                                            // print(post['postId']);
                                                            // print(post['status']);
                                                            // print(post['uid']);
                                                            // print(post['phoneNum2']);
                                                            // print(myUid);
                                                            // '활동 시작' 버튼을 눌렀을 때의 동작
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/activity_screen',
                                                                arguments: {
                                                                  'postId': post[
                                                                      'postId'],
                                                                  'currentStatus':
                                                                      post[
                                                                          'status'],
                                                                  'seniorUid':
                                                                      post[
                                                                          'uid'],
                                                                  'seniorPhoneNum2':
                                                                      post[
                                                                          'phoneNum2'],
                                                                  'mateUid':
                                                                      myUid,
                                                                });
                                                          }
                                                        : post['status'] ==
                                                                'activated'
                                                            ? () {
                                                                // '활동 중' 버튼을 눌렀을 때의 동작
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    '/activity_screen',
                                                                    arguments: {
                                                                      'postId':
                                                                          post[
                                                                              'postId'],
                                                                      'currentStatus':
                                                                          post[
                                                                              'status'],
                                                                      'seniorUid':
                                                                          post[
                                                                              'uid'],
                                                                      'seniorPhoneNum2':
                                                                          post[
                                                                              'phoneNum2'],
                                                                      'mateUid':
                                                                          myUid,
                                                                    });
                                                              }
                                                            : null, // 기타 상태일 때는 비활성화
                                                    child: Text(
                                                      post['status'] ==
                                                              'matched'
                                                          ? '활동 시작'
                                                          : post['status'] ==
                                                                  'activated'
                                                              ? '활동 종료'
                                                              : '활동 실패', // status가 'failed'일 때는 '활동 실패' 표시
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 2,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                      ),
                                                      backgroundColor: post[
                                                                  'status'] ==
                                                              'matched'
                                                          ? Color.fromARGB(255,
                                                              254, 248, 249)
                                                          : post['status'] ==
                                                                  'activated'
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  254,
                                                                  248,
                                                                  249)
                                                              : Colors.grey,
                                                      foregroundColor: post[
                                                                  'status'] ==
                                                              'matched'
                                                          ? const Color.fromARGB(
                                                              255, 72, 156, 224)
                                                          : post['status'] ==
                                                                  'activated'
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  224,
                                                                  102,
                                                                  72)
                                                              : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      endDrawer: CustomEndDrawer(),
    );
  }

  // 시니어가 보는 화면
  Scaffold _buildSeniorScaffold(String myUid) {
    return Scaffold(
      appBar: CustomAppBarWithTab(
        title: '매칭',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color.fromARGB(255, 224, 73, 81), // 선택된 탭의 하단 라인 색상
          labelColor: Color.fromARGB(255, 224, 73, 81),
          labelStyle: TextStyle(
              fontSize: 18,
              fontFamily: 'NotoSansKR',
              fontWeight: FontWeight.w400),
          tabs: [
            Tab(text: '매칭 전'),
            Tab(text: '매칭 후'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 매칭 전 화면(시니어)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseHelper.queryNotMatchedBySenior(myUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('매칭 전 공고가 없습니다.',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400)));
              } else {
                final posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          _buildMateInfoDialog(context, post);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  post['username'],
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                SizedBox(width: 14),
                                                Text(
                                                  post['applyTimeText'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: const Color.fromARGB(
                                                        255, 110, 110, 110),
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                RatingStars(
                                                    rating: post['rating']),
                                                Text(
                                                  "${post['rating'].toStringAsFixed(2)} (${post['ratingCount']})",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                                '활동 날짜:  ${formatDate(post['startTime'])}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                )),
                                            Text(
                                                "활동 시간:  ${formatTime(post['startTime'])} ~ ${formatTime(post['endTime'])}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                )),
                                            Text(
                                                '활동 종류:  ${post['activityType']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                )),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          (post['imgUrl'] != '')
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
                                                                  .pop(); // 클릭 시 다이얼로그 닫기
                                                            },
                                                            child: Center(
                                                              child: Image
                                                                  .network(post[
                                                                      'imgUrl']), // 확대된 이미지
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 130,
                                                    height: 130,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                post['imgUrl']),
                                                            fit: BoxFit.cover),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                  ),
                                                )
                                              : Container(
                                                  width: 130,
                                                  height: 130,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Icon(Icons.person),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7),
                                  Divider(
                                    color: Color.fromARGB(255, 234, 234, 234),
                                    thickness: 2,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween, // Row 내부 요소 간의 간격을 최대화하여 좌우 끝으로 배치
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor:
                                              Color.fromARGB(255, 224, 73, 81),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await FirebaseHelper.acceptMatching(
                                              post['uid'], post['postId']);
                                          // 페이지 새로 고침
                                          setState(() {});
                                        },
                                        child: Text(
                                          '매칭 수락',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final chatId = await FirebaseHelper
                                              .CreateChatRoomWithUserId(
                                            post['uid'],
                                          );
                                          if (chatId != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(chatId: chatId),
                                              ),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '대화하기',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 224, 73, 81)),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 20,
                                              color: Color.fromARGB(
                                                  255, 224, 73, 81),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),

          // 매칭 후 화면(시니어)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirebaseHelper.queryMatchedBySenior(myUid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('매칭 후 공고가 없습니다.',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKR',
                            fontWeight: FontWeight.w400)));
              } else {
                final posts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          _buildMateInfoDialog(context, post);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            elevation: 1,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  post['username'],
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                SizedBox(width: 14),
                                                Text(
                                                  post['acceptTimeText'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: const Color.fromARGB(
                                                        255, 110, 110, 110),
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                RatingStars(
                                                    rating: post['rating']),
                                                Text(
                                                  "${post['rating'].toStringAsFixed(2)} (${post['ratingCount']})",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                                '활동 날짜:  ${formatDate(post['startTime'])}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                )),
                                            Text(
                                                "활동 시간:  ${formatTime(post['startTime'])} ~ ${formatTime(post['endTime'])}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                )),
                                            Text(
                                                '활동 종류:  ${post['activityType']}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                )),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          (post['imgUrl'] != '')
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
                                                                  .pop(); // 클릭 시 다이얼로그 닫기
                                                            },
                                                            child: Center(
                                                              child: Image
                                                                  .network(post[
                                                                      'imgUrl']), // 확대된 이미지
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 130,
                                                    height: 130,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                post['imgUrl']),
                                                            fit: BoxFit.cover),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                  ),
                                                )
                                              : Container(
                                                  width: 130,
                                                  height: 130,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Icon(Icons.person),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7),
                                  Divider(
                                    color: Color.fromARGB(255, 234, 234, 234),
                                    thickness: 2,
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 32, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          backgroundColor: post['status'] ==
                                                  'notReviewedBySenior'
                                              ? Color.fromARGB(
                                                  255, 255, 255, 255)
                                              : Color.fromARGB(
                                                  255, 129, 129, 129),
                                          foregroundColor: post['status'] ==
                                                  'notReviewedBySenior'
                                              ? Color.fromARGB(255, 224, 73, 81)
                                              : Colors.black,
                                        ),
                                        onPressed: post['status'] ==
                                                'notReviewedBySenior'
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RatingBySeniorPage(
                                                      postId: post['postId'],
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Text(
                                          post['status'] == 'matched'
                                              ? '활동 전'
                                              : post['status'] == 'activated'
                                                  ? '활동 중'
                                                  : post['status'] ==
                                                          'notReviewedBySenior'
                                                      ? '리뷰 쓰기'
                                                      : '활동 에러', // status가 notReviewedBySenior일 때
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () async {
                                          final chatId = await FirebaseHelper
                                              .CreateChatRoomWithUserId(
                                            post['uid'],
                                          );
                                          if (chatId != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(chatId: chatId),
                                              ),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '대화하기',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 224, 73, 81)),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 20,
                                              color: Color.fromARGB(
                                                  255, 224, 73, 81),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      endDrawer: CustomEndDrawer(),
    );
  }
}
