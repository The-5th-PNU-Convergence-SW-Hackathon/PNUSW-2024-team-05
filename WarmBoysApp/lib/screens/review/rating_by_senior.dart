import 'package:flutter/material.dart';
import '../index/main_index.dart';
import '../../widgets/rate_stars.dart';
import '../../utils/firebase_helper.dart';

class RatingBySeniorPage extends StatefulWidget {
  final String postId;

  RatingBySeniorPage({
    required this.postId,
  });

  @override
  _RatingBySeniorPageState createState() => _RatingBySeniorPageState();
}

class _RatingBySeniorPageState extends State<RatingBySeniorPage> {
  int ratingBySenior = 0; // 시니어의 별점 값을 저장할 변수
  final TextEditingController _reviewController = TextEditingController();

  bool get isReviewFilled =>
      _reviewController.text.isNotEmpty && ratingBySenior > 0;

  @override
  void initState() {
    super.initState();

    // TextField의 텍스트가 변경될 때마다 setState 호출
    _reviewController.addListener(() {
      setState(() {}); // 상태 업데이트
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 작성'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. 활동에 참여한 메이트에 대해 평가해주세요.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    RateStars(
                      rating: ratingBySenior,
                      onRatingChanged: (rating) {
                        setState(() {
                          ratingBySenior = rating;
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    Text(
                      "2. 메이트에 대한 후기를 작성해주세요.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: '후기를 작성하세요',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      maxLength: 300,
                      onChanged: (text) {
                        setState(() {}); // 텍스트가 변경될 때마다 상태 업데이트
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isReviewFilled
                  ? () async {
                      bool success = await FirebaseHelper.submitRatingBySenior(
                          widget.postId,
                          ratingBySenior,
                          _reviewController.text);
                      if (success) {
                        MainIndex.globalKey.currentState
                            ?.navigateToMatchingScreen();
                        Navigator.pop(context);
                      } else {
                        // 실패 시 다이얼로그 표시
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('오류'),
                              content: Text('리뷰 제출에 실패했습니다.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  : null,
              child: Text(
                "후기 제출하기",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // 버튼을 페이지 하단에 고정
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
