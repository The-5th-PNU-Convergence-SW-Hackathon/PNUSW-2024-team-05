// cayenne(lightest) Color.fromARGB(255,252,237,238)

// // 색상 리스트
// // 기본

// cayenne Color.fromARGB(255, 224, 73, 81)
// 카드 배경: Color.fromARGB(255, 252, 246, 24),
// title 텍스트: Color.fromARGB(255, 68, 68, 68),
// subtitle 텍스트: Color.fromARGB(255, 195, 195, 195),
// 회색: Color.fromARGB(255, 147, 149, 151),

// // 메뉴
// 어두운 배경: Color.fromARGB(255, 44, 45, 47),
// 리스트 아이콘: Color.fromARGB(255, 159, 159, 159),
// 리스트 텍스트: Color.fromARGB(255, 207, 207, 207),

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/custom_auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_end_drawer.dart';
import '../../utils/firebase_helper.dart';
import '../../widgets/rating_stars.dart';
import '../chatting/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTimeRange _selectedDateRange = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(Duration(days: 7)));
  String _selectedSort = "오름차순";
  String _selectedDong = "부곡1동";
  List<Map<String, dynamic>> _postcards = [];

  @override
  void initState() {
    super.initState();
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final userInfo = customAuthProvider.userInfo;
    if (userInfo != null && userInfo['dong'] != null) {
      _selectedDong = userInfo['dong'];
    }
    _fetchPostcards(); // 기본 설정된 DateTimeRange를 기반으로 _fetchPostcards 호출
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        initialDateRange: _selectedDateRange);

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _fetchPostcards();
      });
    }
  }

  Future<void> _fetchPostcards() async {
    if (_selectedDateRange == null) return;

    List<Map<String, dynamic>> fetchedPostcards =
        await FirebaseHelper.queryPostcardsByDurLocStat(
      _selectedDateRange.start,
      _selectedDateRange.end,
      _selectedDong,
      _selectedSort,
    );

    setState(() {
      _postcards = fetchedPostcards;
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('yy.MM.dd').format(date);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('a h시')
        .format(dateTime)
        .replaceAll('AM', '오전')
        .replaceAll('PM', '오후');
  }

  @override
  Widget build(BuildContext context) {
    final customAuthProvider = Provider.of<CustomAuthProvider>(context);
    final userInfo = customAuthProvider.userInfo;
    final uid = customAuthProvider.uid;
    final memberType = userInfo?['memberType'];

    return Scaffold(
      appBar: CustomAppBar(
        title: '홈',
        leading: null, // '뒤로 가기 버튼' 제거
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (memberType == '시니어')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ElevatedButton(
                      onPressed: () {
                        // 앱 사용자 정보
                        String myUid = uid ?? '';
                        String memberType = userInfo?['memberType'] ?? '';
                        // 공고 작성자 정보
                        String seniorUid = uid ?? '';
                        String seniorName = userInfo?['username'] ?? '';
                        String imgUrl = userInfo?['imgUrl'] ?? '';
                        double rating = userInfo?['rating'] ?? 0.0;
                        int ratingCount = userInfo?['ratingCount'] ?? 0;
                        String dependentType = userInfo?['dependentType'] ?? '';
                        bool withPet = userInfo?['withPet'] ?? false;
                        bool withCam = userInfo?['withCam'] ?? false;
                        List<String> symptom =
                            List<String>.from(userInfo?['symptom'] ?? []);
                        String walkingType = userInfo?['walkingType'] ?? '';
                        String petInfo = userInfo?['petInfo'] ?? '';
                        String symptomInfo = userInfo?['symptomInfo'] ?? '';
                        String addInfo = userInfo?['addInfo'] ?? '';
                        // 공고 정보
                        String postId = '';
                        String city = userInfo?['city'] ?? '';
                        String gu = userInfo?['gu'] ?? '';
                        String dong = userInfo?['dong'] ?? '';
                        String status = '';
                        String activityType = '';
                        DateTime startTime = DateTime.now();
                        DateTime endTime = DateTime.now();

                        // PostScreen으로 라우트
                        Navigator.pushNamed(context, '/post_screen',
                            arguments: {
                              'memberType': memberType,
                              'postId': postId,
                              'myUid': myUid,
                              'seniorUid': seniorUid,
                              'seniorName': seniorName,
                              'imgUrl': imgUrl,
                              'city': city,
                              'gu': gu,
                              'dong': dong,
                              'dependentType': dependentType,
                              'withPet': withPet,
                              'withCam': withCam,
                              'symptom': symptom,
                              'petInfo': petInfo,
                              'symptomInfo': symptomInfo,
                              'walkingType': walkingType,
                              'rating': rating,
                              'ratingCount': ratingCount,
                              'activityType': activityType,
                              'startTime': startTime,
                              'endTime': endTime,
                              'addInfo': addInfo,
                            });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 224, 73, 81),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        '+ 내 공고 작성하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (memberType == '시니어')
            Divider(color: Color.fromARGB(255, 238, 238, 238), thickness: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDateRange(context),
                    child: Text('기간 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w400,
                        )),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 224, 73, 81),
                      backgroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                  SizedBox(width: 15),
                  DropdownButton<String>(
                    value: _selectedSort,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSort = newValue!;
                        _fetchPostcards();
                      });
                    },
                    items: <String>['오름차순', '내림차순']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'NotoSansKR',
                                fontWeight: FontWeight.w400)),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 15),
                  DropdownButton<String>(
                    value: _selectedDong,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDong = newValue!;
                        _fetchPostcards();
                      });
                    },
                    items: <String>[
                      '전체',
                      '구서1동',
                      '구서2동',
                      '금사회동동',
                      '금성동',
                      '남산동',
                      '부곡1동',
                      '부곡2동',
                      '부곡3동',
                      '부곡4동',
                      '서1동',
                      '서2동',
                      '서3동',
                      '선두구동',
                      '장전1동',
                      '장전2동',
                      '청룡노포동',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'NotoSansKR',
                                fontWeight: FontWeight.w400)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Color.fromARGB(255, 238, 238, 238), thickness: 2),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchPostcards,
              child: ListView.builder(
                itemCount: _postcards.length,
                itemBuilder: (context, index) {
                  final postcard = _postcards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shadowColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // 모서리 반경 설정
                        ),
                        child: Row(
                          children: [
                            postcard['imgUrl'] != ''
                                ? Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pop(); // 클릭 시 다이얼로그 닫기
                                                  },
                                                  child: Center(
                                                    child: Image.network(
                                                        postcard['imgUrl']),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3, // 너비는 고정, 높이는 부모의 높이를 따르도록 설정
                                          height: 270,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  postcard['imgUrl']),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5.0),
                                              bottomLeft: Radius.circular(5.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : CircleAvatar(
                                    radius: 40,
                                    child: Icon(Icons.person),
                                  ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          postcard['seniorName'],
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontFamily: 'NotoSansKR',
                                              fontWeight: FontWeight.w400),
                                        ),
                                        memberType == '메이트'
                                            ? SizedBox(width: 3)
                                            : Container(),
                                        memberType == '메이트'
                                            ? IconButton(
                                                onPressed: () async {
                                                  final chatId =
                                                      await FirebaseHelper
                                                          .CreateChatRoomWithUserId(
                                                    postcard['seniorUid'],
                                                  );
                                                  if (chatId != null) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatScreen(
                                                                chatId: chatId),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.chat, // 채팅 모양 아이콘
                                                  size: 24.0, // 아이콘 크기
                                                  color: Color.fromARGB(255,
                                                      224, 73, 81), // 아이콘 색상
                                                ),
                                                tooltip:
                                                    '채팅하기', // 아이콘에 툴팁 제공 (선택 사항)
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        RatingStars(rating: postcard['rating']),
                                        SizedBox(width: 5),
                                        Text(
                                          "${postcard['rating'].toStringAsFixed(2)} (${postcard['ratingCount']})",
                                          style: TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${postcard['city']} ${postcard['gu']} ${postcard['dong']}",
                                          style: TextStyle(
                                              fontSize:
                                                  memberType == '시니어' ? 16 : 14,
                                              fontFamily: 'NotoSansKR',
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "날짜: ${formatDate(postcard['startTime'])}",
                                      style: TextStyle(
                                          fontSize:
                                              memberType == '시니어' ? 16 : 14,
                                          fontFamily: 'NotoSansKR',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "시간: ${formatTime(postcard['startTime'])} ~ ${formatTime(postcard['endTime'])}",
                                      style: TextStyle(
                                          fontSize:
                                              memberType == '시니어' ? 16 : 14,
                                          fontFamily: 'NotoSansKR',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "활동: ${postcard['activityType']}",
                                      style: TextStyle(
                                          fontSize:
                                              memberType == '시니어' ? 16 : 14,
                                          fontFamily: 'NotoSansKR',
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "크레딧: ${postcard['credit'].toString()}",
                                              style: TextStyle(
                                                  fontSize: memberType == '메이트'
                                                      ? 14
                                                      : 16,
                                                  fontFamily: 'NotoSansKR',
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54),
                                            ),
                                            SizedBox(height: 14),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        // 앱 사용자 정보
                        String myUid = uid ?? '';
                        String memberType = userInfo?['memberType'] ?? '';
                        // 공고 작성자 정보
                        String seniorUid = postcard['seniorUid'];
                        String seniorName = postcard['seniorName'];
                        String imgUrl = postcard['imgUrl'] ?? '';
                        double rating = postcard['rating'];
                        int ratingCount = postcard['ratingCount'];
                        String dependentType = postcard['dependentType'];
                        bool withPet = postcard['withPet'];
                        bool withCam = postcard['withCam'];
                        List<String> symptom =
                            List<String>.from(postcard['symptom']);
                        String walkingType = postcard['walkingType'];
                        String petInfo = postcard['petInfo'] ?? '';
                        String symptomInfo = postcard['symptomInfo'];
                        // 공고 정보
                        String postId = postcard['postId'];
                        String city = postcard['city'];
                        String gu = postcard['gu'];
                        String dong = postcard['dong'];
                        String status = postcard['status'];
                        String activityType = postcard['activityType'];
                        DateTime startTime = postcard['startTime'];
                        DateTime endTime = postcard['endTime'];
                        String addInfo = postcard['addInfo'];

                        // PostScreen으로 라우트
                        Navigator.pushNamed(context, '/post_screen',
                            arguments: {
                              'memberType': memberType,
                              'postId': postId,
                              'myUid': myUid,
                              'seniorUid': seniorUid,
                              'seniorName': seniorName,
                              'imgUrl': imgUrl,
                              'city': city,
                              'gu': gu,
                              'dong': dong,
                              'dependentType': dependentType,
                              'withPet': withPet,
                              'withCam': withCam,
                              'symptom': symptom,
                              'petInfo': petInfo,
                              'symptomInfo': symptomInfo,
                              'walkingType': walkingType,
                              'rating': rating,
                              'ratingCount': ratingCount,
                              'activityType': activityType,
                              'startTime': startTime,
                              'endTime': endTime,
                              'addInfo': addInfo,
                            });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      endDrawer: CustomEndDrawer(),
    );
  }
}
