import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_end_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chatting/chat_screen.dart';
import '/utils/firebase_helper.dart';

class ChattingScreen extends StatefulWidget {
  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, String?> userProfileUrls = {};
  Map<String, String?> userNames = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '채팅',
        leading: null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseHelper.getChatsStream(_auth.currentUser!.uid),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('채팅이 없습니다.',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'NotoSansKR',
                              fontWeight: FontWeight.w400)));
                }
                final chatDocs = chatSnapshot.data!.docs;
                chatDocs.sort((a, b) {
                  Timestamp aTime = a['lastMessageTime'] ?? Timestamp.now();
                  Timestamp bTime = b['lastMessageTime'] ?? Timestamp.now();
                  return bTime.compareTo(aTime);
                });
                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    var chatData = chatDocs[index];
                    var participants =
                        chatData['participants'] as List<dynamic>;
                    var otherUserId = participants.firstWhere(
                        (id) => id != _auth.currentUser!.uid,
                        orElse: () => null);
                    var isRead =
                        (chatData['lastMessageReadBy'] as List<dynamic>?)
                                ?.contains(_auth.currentUser!.uid) ??
                            false;

                    return FutureBuilder<Map<String, String?>>(
                      future: _getUserProfileAndName(otherUserId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Loading...'),
                            subtitle: Text(chatData['lastMessageTime'] != null
                                ? FirebaseHelper.formatDate(
                                    chatData['lastMessageTime'].toDate())
                                : ''),
                          );
                        }
                        var userProfileUrl = snapshot.data?['profileUrl'];
                        var userName = snapshot.data?['userName'] ?? 'Unknown';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: userProfileUrl != null &&
                                      userProfileUrl.isNotEmpty
                                  ? NetworkImage(userProfileUrl)
                                  : const AssetImage(
                                          'assets/images/default_profile.png')
                                      as ImageProvider,
                            ),
                            title: Text(
                              userName,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'NotoSansKR',
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatData['lastMessage'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'NotoSansKR',
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  chatData['lastMessageTime'] != null
                                      ? FirebaseHelper.formatTime(
                                          chatData['lastMessageTime'].toDate())
                                      : '',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: !isRead
                                ? Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                            onTap: () async {
                              await FirebaseHelper.markMessageAsRead(
                                  chatData.id, _auth.currentUser!.uid);
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatScreen(chatId: chatData.id),
                                  ),
                                );
                              }
                            },
                          ),
                          // const Divider(), // 리스트 항목 구분선
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      endDrawer: CustomEndDrawer(),
    );
  }

  Future<Map<String, String?>> _getUserProfileAndName(String? userId) async {
    if (userId == null) return {'profileUrl': null, 'userName': null};

    if (userProfileUrls.containsKey(userId) && userNames.containsKey(userId)) {
      return {
        'profileUrl': userProfileUrls[userId],
        'userName': userNames[userId]
      };
    } else {
      final doc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (doc.exists) {
        String? imgUrl = doc['imgUrl'];
        String? userName = doc['username'];
        userProfileUrls[userId] = imgUrl;
        userNames[userId] = userName;
        return {'profileUrl': imgUrl, 'userName': userName};
      }
      return {'profileUrl': null, 'userName': 'Unknown'};
    }
  }
}
