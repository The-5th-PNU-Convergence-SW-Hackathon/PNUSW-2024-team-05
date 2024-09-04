import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/custom_auth_provider.dart';
import '../../widgets/activity_type_scrollview.dart';
import '../../widgets/member_details_scrollview.dart';
import '../../widgets/member_symptom_scrollview.dart';

class ProfileSeniorScreen extends StatelessWidget {
  const ProfileSeniorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final userInfo = customAuthProvider.userInfo!;
    final _username = userInfo['username'];
    final _age = userInfo['age'];
    final _phoneNum = userInfo['phoneNum'];
    final _phoneNum2 = userInfo['phoneNum2'];
    final _city = userInfo['city'];
    final _gu = userInfo['gu'];
    final _dong = userInfo['dong'];
    final _detailedAddress = userInfo['detailedAddress'];
    final List<String> _activityType =
        (userInfo['activityType'] as List<dynamic>)
            .map((item) => item as String)
            .toList();
    final _dependentType = userInfo['dependentType'];
    final _withPet = userInfo['withPet'];
    final _withCam = userInfo['withCam'];
    final _petInfo = userInfo['petInfo'];
    final List<String> _symptom = (userInfo['symptom'] as List<dynamic>)
        .map((item) => item as String)
        .toList();
    final _symptomInfo = userInfo['symptomInfo'];
    final _walkingType = userInfo['walkingType'];
    final _addInfo = userInfo['addInfo'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "내 프로필",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 30,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (customAuthProvider.profileImageBytes != null)
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pop(); // 클릭 시 다이얼로그 닫기
                                    },
                                    child: Center(
                                        child: CircleAvatar(
                                            radius: 200,
                                            backgroundImage: MemoryImage(
                                                customAuthProvider
                                                    .profileImageBytes!)) // 확대된 이미지
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(
                                customAuthProvider.profileImageBytes!),
                          ),
                        )
                      : CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person),
                        ),
                ],
              ),
              SizedBox(height: 20),
              Divider(
                color: Color.fromARGB(255, 216, 216, 216),
                thickness: 4,
              ),
              SizedBox(height: 24),
              Text(
                "내 신상 정보",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500]),
              ),
              SizedBox(height: 10),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "성함",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "나이",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _age,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "연락처",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _phoneNum,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "비상 연락처",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _phoneNum2,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "주소",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_city $_gu $_dong,',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _detailedAddress,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              SizedBox(height: 36),
              Text(
                "내 상세 정보",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500]),
              ),
              SizedBox(height: 10),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "희망하는 서비스",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ActivityTypeScrollView(activityTypes: _activityType),
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "주거 환경 특이사항",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  MemberDetailsScrollview(
                      dependentType: _dependentType,
                      withPet: _withPet,
                      withCam: _withCam),
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              _petInfo != ''
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "반려동물 주의사항",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _petInfo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Divider(
                          color: Color.fromARGB(255, 234, 234, 234),
                          thickness: 2,
                        ),
                      ],
                    )
                  : Container(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "해당되는 증상",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  MemberSymptomScrollview(symptoms: _symptom)
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              _symptomInfo != ''
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "증상 상세 설명",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _symptomInfo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Divider(
                          color: Color.fromARGB(255, 234, 234, 234),
                          thickness: 2,
                        ),
                      ],
                    )
                  : Container(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "거동 상태",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _walkingType,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Divider(
                color: Color.fromARGB(255, 234, 234, 234),
                thickness: 2,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "소개글",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _addInfo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Divider(
                    color: Color.fromARGB(255, 234, 234, 234),
                    thickness: 2,
                  ),
                  SizedBox(height: 80),
                  SizedBox(
                    width: double.infinity, // 버튼의 폭을 부모에 맞게 확장
                    child: ElevatedButton(
                      onPressed: () {
                        // 회원 탈퇴 확인 다이얼로그 표시
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("회원 탈퇴"),
                              content: Text("정말로 탈퇴하시겠습니까?"),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 닫기
                                      },
                                      child: Text("취소"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // 회원 탈퇴 로직 추가 (예: 로그아웃 및 탈퇴 처리)
                                        customAuthProvider.logOut().then((_) {
                                          Navigator.of(context)
                                              .pop(); // 다이얼로그 닫기
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  '/login',
                                                  (Route<dynamic> route) =>
                                                      false);
                                        });
                                      },
                                      child: Text(
                                        "탈퇴하기",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red, // 버튼 배경색을 빨간색으로 설정
                        padding: EdgeInsets.symmetric(vertical: 16), // 버튼 높이 조절
                      ),
                      child: Text(
                        '회원 탈퇴하기',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
