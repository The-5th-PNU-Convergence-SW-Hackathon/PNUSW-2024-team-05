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
      body: StreamBuilder(
        stream: FirebaseHelper.getChatsStream(_auth.currentUser!.uid),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!chatSnapshot.hasData) {
            return Center(child: Text('No chats found.'));
          }
          final chatDocs = chatSnapshot.data!.docs;
          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              var chatData = chatDocs[index];
              var participants = chatData['participants'] as List<dynamic>;
              var otherUserId = participants.firstWhere((id) => id != _auth.currentUser!.uid, orElse: () => null);
              var isRead = (chatData['lastMessageReadBy'] as List<dynamic>?)?.contains(_auth.currentUser!.uid) ?? false;

              return FutureBuilder<String?>(
                future: _getUserProfileUrl(otherUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text(chatData['lastMessageTime'] != null
                          ? FirebaseHelper.formatDate(chatData['lastMessageTime'].toDate())
                          : ''),
                    );
                  }
                  var userProfileUrl = snapshot.data;
                  return FutureBuilder<String?>(
                    future: _getUserName(otherUserId),
                    builder: (context, nameSnapshot) {
                      if (nameSnapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text('Loading...'),
                          subtitle: Text(chatData['lastMessageTime'] != null
                              ? FirebaseHelper.formatDate(chatData['lastMessageTime'].toDate())
                              : ''),
                        );
                      }
                      var userName = nameSnapshot.data ?? 'Unknown';
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage: userProfileUrl != null && userProfileUrl.isNotEmpty
                                  ? NetworkImage(userProfileUrl)
                                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                            ),
                            title: Text(
                              userName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatData['lastMessage'],
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  chatData['lastMessageTime'] != null
                                      ? FirebaseHelper.formatTime(chatData['lastMessageTime'].toDate())
                                      : '',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                              if (context != null) {
                                await FirebaseHelper.markMessageAsRead(chatData.id, _auth.currentUser!.uid);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(chatId: chatData.id),
                                  ),
                                );
                              }
                            },
                          ),
                          Divider(), // 리스트 항목 구분선
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      endDrawer: CustomEndDrawer(),
    );
  }

  Future<String?> _getUserProfileUrl(String? userId) async {
    if (userId == null) return null;

    if (userProfileUrls.containsKey(userId)) {
      return userProfileUrls[userId];
    } else {
      final doc = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (doc.exists) {
        String? imgUrl = doc['imgUrl'];
        userProfileUrls[userId] = imgUrl;
        return imgUrl;
      }
      return null;
    }
  }

  Future<String?> _getUserName(String? userId) async {
    if (userId == null) return null;

    if (userNames.containsKey(userId)) {
      return userNames[userId];
    } else {
      final doc = await FirebaseFirestore.instance.collection('user').doc(userId).get();
      if (doc.exists) {
        String? userName = doc['username'];
        userNames[userId] = userName;
        return userName;
      }
      return null;
    }
  }
}