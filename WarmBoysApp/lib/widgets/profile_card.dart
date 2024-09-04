import 'package:flutter/material.dart';
import 'rating_stars.dart';
import '../screens/review/review.dart'; // ReviewScreen 파일 임포트

class ProfileCard extends StatelessWidget {
  final String imgUrl;
  final String username;
  final String memberType;
  final String uid;
  final String city;
  final String gu;
  final String dong;
  final double rating;
  final int ratingCount;

  ProfileCard({
    required this.imgUrl,
    required this.username,
    required this.memberType,
    required this.uid,
    required this.city,
    required this.gu,
    required this.dong,
    required this.rating,
    required this.ratingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Row(
          children: [
            (imgUrl != '')
                ? GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(); // 클릭 시 다이얼로그 닫기
                              },
                              child: Center(
                                child: Image.network(imgUrl), // 확대된 이미지
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(imgUrl),
                    ),
                  )
                : CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person),
                  ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(username,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    '${city} > ${gu} > ${dong}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RatingStars(rating: rating),
                      Text(
                        "${rating.toStringAsFixed(2)} (${ratingCount})",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 5),
                      TextButton(
                        onPressed: () {
                          // 리뷰 보기 버튼 클릭 시 ReviewScreen으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                username: username,
                                uid: uid,
                                memberType: memberType,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '리뷰 보기',
                          style: TextStyle(
                            color: Color.fromARGB(255, 224, 73, 81),
                          ),
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
    );
  }
}
