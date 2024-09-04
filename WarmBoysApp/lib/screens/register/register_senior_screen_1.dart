import 'package:flutter/material.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 1(시니어)
class RegisterSeniorScreen1 extends StatefulWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  RegisterSeniorScreen1(
      {required this.onNextPage, required this.onPreviousPage});

  @override
  _RegisterSeniorScreen1State createState() => _RegisterSeniorScreen1State();
}

class _RegisterSeniorScreen1State extends State<RegisterSeniorScreen1> {
  List<String> _selectedActivities = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedActivities(); // 저장된 활동들을 불러오기
  }

  Future<void> _loadSelectedActivities() async {
    List<String>? activities =
        await SharedPreferencesHelper.getStringList('_activityType');
    if (activities != null) {
      setState(() {
        _selectedActivities = activities;
      });
    }
  }

  void _toggleSelection(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
      _saveSelectedActivities();
    });
  }

  Future<void> _saveSelectedActivities() async {
    await SharedPreferencesHelper.saveStringList(
        '_activityType', _selectedActivities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어떤 서비스를 원하시나요?',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("버튼을 길게 눌러보세요.",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w400)),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildIconText(Icons.computer, '디지털 교육',
                      '예시 활동: 스마트폰 사용법 교육, SNS 및 이메일 사용 지원, 온라인 쇼핑 및 뱅킹 도우미, 비디오 통화 설정 및 사용법.'),
                  _buildIconText(Icons.local_hospital, '병원 동행',
                      '예시 활동: 병원까지 안내, 진료 예약 도우미, 의료 서류 및 정보 전달, 약국 동행하기.'),
                  _buildIconText(Icons.games, '실내 오락',
                      '예시 활동: 퍼즐 맞추기, 보드게임, 카드 게임, 영화 감상, 음악 감상 및 노래 부르기.'),
                  _buildIconText(Icons.nature_people, '실외 활동',
                      '예시 활동: 산책 동행, 공원 방문, 정원 가꾸기, 근처 마을 탐방, 외출 시 동행(장보기, 병원 방문 등).'),
                  _buildIconText(Icons.people, '사회적 교류',
                      '예시 활동: 모임 참여 동행, 교회나 종교 활동 동행, 친구나 가족과의 만남 지원, 지역 커뮤니티 행사 참석.'),
                  _buildIconText(Icons.theater_comedy, '문화 및 여가',
                      '예시 활동: 박물관 및 전시회 관람, 공연 및 영화관 방문, 미술 활동, 도서관 방문.'),
                  _buildIconText(Icons.favorite, '정서적 지원',
                      '예시 활동: 대화 및 심리적 위로, 추억 이야기 나누기, 애완동물 돌보기, 명상 및 요가 지도.'),
                  _buildIconText(Icons.book, '지적 활동',
                      '예시 활동: 책 읽어주기, 신문 및 뉴스 읽기, 퀴즈 및 문제 풀이, 역사 및 과학 이야기 나누기.'),
                  _buildIconText(Icons.brush, '예술 및 창작',
                      '예시 활동: 그림 그리기, 손작업(뜨개질, 종이접기), 시 쓰기 및 글쓰기, 사진 촬영 및 편집.'),
                  _buildIconText(Icons.volunteer_activism, '재능 기부',
                      '예시 활동: 외국어 교육 및 회화, 음악 연주 지도, 악기 배우기, 노인 대상 특강 및 워크숍.'),
                  _buildIconText(Icons.local_florist, '취미 활동',
                      '예시 활동: 원예 및 식물 가꾸기, 요리 배우기, DIY 공예, 애완동물과의 시간 보내기.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          onPressed: _selectedActivities.isNotEmpty ? widget.onNextPage : null,
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

  Widget _buildIconText(IconData icon, String text, String message) {
    final isSelected = _selectedActivities.contains(text);
    return GestureDetector(
      onTap: () => _toggleSelection(text),
      child: Tooltip(
        message: message,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  isSelected ? Color.fromARGB(255, 224, 73, 81) : Colors.grey,
              child: Icon(icon,
                  size: 30, color: isSelected ? Colors.white : Colors.black),
            ),
            SizedBox(height: 8.0),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Color.fromARGB(255, 224, 73, 81)
                    : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
