import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warm_boys/providers/custom_auth_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EducationScreen extends StatefulWidget {
  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  late YoutubePlayerController _controller;
  bool _isVideoCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'wpMq6oGhj24', // 유튜브 영상 ID
      flags: YoutubePlayerFlags(
        hideControls: true,
        autoPlay: true,
        disableDragSeek: true,
        mute: false,
        forceHD: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    // 영상이 끝나는 시점을 감지하는 리스너
    if (_controller.value.playerState == PlayerState.ended) {
      setState(() {
        _isVideoCompleted = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateIsVerified() async {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    final userCredential = customAuthProvider.userCredential;

    if (userCredential != null) {
      final user = userCredential.user;
      final userId = user?.uid;

      if (userId != null) {
        final firestore = FirebaseFirestore.instance;
        try {
          await firestore.collection('user').doc(userId).update({
            'isVerified': true,
          });
          Navigator.pushReplacementNamed(context, '/main');
        } catch (e) {
          print("Error updating isVerified: $e"); // 에러 메시지 출력
        }
      } else {
        print("User ID is null");
      }
    } else {
      print("UserCredential is null");
    }
  }

  void _logOut() {
    final customAuthProvider =
        Provider.of<CustomAuthProvider>(context, listen: false);
    customAuthProvider.logOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('교육 영상 페이지'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _logOut,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              onReady: () {
                print('플레이어가 준비되었습니다.');
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isVideoCompleted // 영상 시청 완료 여부에 따라 다음 버튼 활성화/비활성화
              ? () async {
                  await _updateIsVerified();
                  print("------------교육영상 이수완료------------");
                  print("홈 스크린으로 이동합니다.");
                }
              : null,
          child: Text('다음'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}
