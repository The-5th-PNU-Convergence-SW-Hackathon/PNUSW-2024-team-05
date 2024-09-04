import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/utils/firebase_helper.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? otherUserProfileUrl;
  String? otherUsername;

  @override
  void initState() {
    super.initState();
    _loadOtherUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _loadOtherUserProfile() async {
    var chatData = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();
    var participants = chatData.data()?['participants'] as List<dynamic>?;
    if (participants != null) {
      var otherUserId = participants
          .firstWhere((id) => id != _auth.currentUser?.uid, orElse: () => null);

      if (otherUserId != null) {
        otherUserProfileUrl = await _getUserProfileUrl(otherUserId);
        otherUsername = await _getUsername(otherUserId);
        setState(() {});
      }
    }
  }

  Future<String?> _getUserProfileUrl(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (doc.exists) {
      return doc['imgUrl'];
    }
    return 'assets/images/default_profile.png'; // 기본 이미지 경로
  }

  Future<String?> _getUsername(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (doc.exists) {
      return doc['username'];
    }
    return 'Unknown';
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await FirebaseHelper.sendMessage(
        chatId: widget.chatId,
        text: _controller.text,
        senderId: _auth.currentUser!.uid,
      );
      _controller.clear();
      _scrollToBottom();
    }
  }

  String formatDate(Timestamp timestamp) {
    return FirebaseHelper.formatDate(timestamp.toDate());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUsername ?? 'Loading...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                    if (chatSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!chatSnapshot.hasData ||
                        chatSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No messages found.'));
                    }
                    final chatDocs = chatSnapshot.data!.docs;
                    DateTime? previousDate;

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: chatDocs.length,
                      itemBuilder: (ctx, index) {
                        var message =
                            chatDocs[index].data() as Map<String, dynamic>;
                        bool isMe =
                            message['senderId'] == _auth.currentUser!.uid;
                        DateTime messageDate =
                            (message['createdAt'] as Timestamp).toDate();
                        bool showDateSeparator = false;

                        if (previousDate == null ||
                            previousDate!.day != messageDate.day) {
                          showDateSeparator = true;
                          previousDate = messageDate;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateSeparator)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Divider(
                                          color: Colors.grey,
                                          thickness: 1,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatDate(
                                          Timestamp.fromDate(messageDate)),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Divider(
                                          color: Colors.grey,
                                          thickness: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: otherUserProfileUrl !=
                                                  null &&
                                              otherUserProfileUrl!.isNotEmpty
                                          ? NetworkImage(otherUserProfileUrl!)
                                          : const AssetImage(
                                                  'assets/images/default_profile.png')
                                              as ImageProvider,
                                    ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.green[300]
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(message['text']),
                                        SizedBox(height: 5),
                                        Text(
                                          message['createdAt']
                                              .toDate()
                                              .toString()
                                              .substring(11, 16),
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onTap: () {
                          // 현재 스크롤 위치를 유지하기 위해 아무것도 하지 않음
                        },
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
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
