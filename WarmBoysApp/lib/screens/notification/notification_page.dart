import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/../providers/custom_auth_provider.dart';
import '../index/main_index.dart';
import '../chatting/chat_screen.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<CustomAuthProvider>(context, listen: false).uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('알림'),
          backgroundColor: Colors.grey, // 상단 타일 배경색을 옅은 회색으로 설정
        ),
        body: Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        backgroundColor: Colors.grey[200], // 상단 타일 배경색을 옅은 회색으로 설정
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alarms')
            .doc(userId)
            .collection('userAlarms')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var alarms = snapshot.data!.docs;

          if (alarms.isEmpty) {
            return Center(child: Text('새로운 알림이 없습니다.'));
          }

          return ListView.separated(
            itemCount: alarms.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey), // 회색 구분선 추가
            itemBuilder: (context, index) {
              var alarm = alarms[index].data() as Map<String, dynamic>;
              var alarmId = alarms[index].id;
              bool isRead = alarm['read'] ?? true; // read 상태를 확인, 기본값은 true

              return Container(
                color: isRead ? Colors.transparent : Colors.grey[200], // 읽지 않은 알림의 배경을 옅은 회색으로 설정
                child: ListTile(
                  title: Text(alarm['message']),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd HH:mm')
                        .format(alarm['timestamp'].toDate()),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close, color: Colors.red), // 우측 상단에 X 아이콘 추가
                    onPressed: () async {
                      // Firestore에서 알림 삭제
                      await FirebaseFirestore.instance
                          .collection('alarms')
                          .doc(userId)
                          .collection('userAlarms')
                          .doc(alarmId)
                          .delete();

                      // 알림이 삭제되었다는 스낵바 메시지
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('알림이 삭제되었습니다.')),
                      );
                    },
                  ),
                  onTap: () async {
                    // 알림 읽음으로 표시
                    await FirebaseFirestore.instance
                        .collection('alarms')
                        .doc(userId)
                        .collection('userAlarms')
                        .doc(alarmId)
                        .update({'read': true});

                    if (alarm['alarmType'] == 'chat') {
                      // 채팅 알림일 경우 특정 채팅방으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: alarm['chatId'],
                          ),
                        ),
                      );
                    } else if (alarm['alarmType'] == 'post') {
                      // 공고 알림일 경우 MainIndex의 매칭 화면으로 이동
                      MainIndex.globalKey.currentState?.navigateToMatchingScreen();
                      Navigator.pop(context); // 알림 페이지에서 벗어나기 위해 pop 호출
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}