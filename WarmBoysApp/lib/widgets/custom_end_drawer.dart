import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/custom_auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/service/customer_service_screen.dart';
import '../screens/profile/profile_mate_screen.dart';
import '../screens/profile/profile_senior_screen.dart';
import '../screens/history/history_screen.dart';

class CustomEndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final userInfo = Provider.of<CustomAuthProvider>(context).userInfo!;
    final username = userInfo['username'] ?? '사용자 이름';
    final memberType = userInfo['memberType'] ?? '';
    final age = userInfo['age'] ?? '';
    final uid = Provider.of<CustomAuthProvider>(context).uid;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 224, 73, 81),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              customAuthProvider.profileImageBytes != null
                                  ? MemoryImage(
                                      customAuthProvider.profileImageBytes!)
                                  : AssetImage('assets/default_profile.png')
                                      as ImageProvider,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            memberType,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('내 프로필',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                if (memberType == '메이트') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileMateScreen(),
                    ),
                  );
                } else if (memberType == '시니어') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileSeniorScreen(),
                    ),
                  );
                } else
                  print("잘못된 회원 유형입니다.");
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('활동 기록',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('고객센터',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CustomerServiceScreen(uid: uid!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'NotoSansKR',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                // CustomAuthProvider의 logOut 메서드를 호출하고 로그인 페이지로 이동
                Provider.of<CustomAuthProvider>(context, listen: false)
                    .logOut()
                    .then(
                  (_) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            LoginScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
