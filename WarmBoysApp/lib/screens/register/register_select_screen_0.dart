import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warm_boys/providers/custom_auth_provider.dart';
import '../../utils/shared_preferences_helper.dart';

// 회원가입 스크린 0(가입 유형 선택)
// 가입 유형 '메이트' 선택 시, register_mate_screen_1, 2, 3, 4, 5
// 가입 유형 '시니어' 선택 시, register_senor_screen_1, 2, 3 ,4, 5,
class RegisterSelectScreen0 extends StatefulWidget {
  @override
  _RegisterSelectScreen0State createState() => _RegisterSelectScreen0State();
}

class _RegisterSelectScreen0State extends State<RegisterSelectScreen0> {
  @override
  void initState() {
    super.initState();
    _clearAllPreferences();
  }

  Future<void> _clearAllPreferences() async {
    await SharedPreferencesHelper.clearAll();
  }

  Future<void> _saveMemberType(String memberType) async {
    await SharedPreferencesHelper.saveData('_memberType', memberType);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    await SharedPreferencesHelper.clearAll();
    customAuthProvider.clearProfileImage();
    customAuthProvider.clearSchoolCertImage();
    return true; // true를 반환하여 pop 실행
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Spacer(),
            _buildMemberTypeCard(
              context,
              icon: Icons.person,
              title: '청년의 도움이 필요한 시니어 회원이에요!',
              subtitle: '시니어 회원가입  >',
              subtitleColor: Color.fromARGB(255, 224, 73, 81),
              onTap: () async {
                await _saveMemberType('시니어');
                Navigator.pushNamed(context, '/registerSenior');
              },
            ),
            SizedBox(height: 20),
            _buildMemberTypeCard(
              context,
              icon: Icons.person_outline,
              title: '든든한 케어 청년으로 활동하고 싶어요!',
              subtitle: '케어 메이트 회원가입  >',
              subtitleColor: Color.fromARGB(255, 72, 156, 224),
              onTap: () async {
                await _saveMemberType('메이트');
                Navigator.pushNamed(context, '/registerMate');
              },
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTypeCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color subtitleColor,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, size: 40),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'NotoSansKR',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 68, 68, 68),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'NotoSansKR',
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
