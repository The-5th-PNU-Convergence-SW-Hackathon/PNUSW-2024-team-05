import 'package:flutter/material.dart';

class MemberSymptomScrollview extends StatelessWidget {
  final List<String> symptoms;

  MemberSymptomScrollview({required this.symptoms});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: symptoms.map((symptom) {
            return Row(
              children: [
                Material(
                  elevation: 1.0, // 그림자 깊이를 조절
                  borderRadius: BorderRadius.circular(3.0), // 모서리를 둥글게 설정
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    padding: EdgeInsets.all(10.0),
                    child: Text(symptom, style: TextStyle(fontSize: 18)),
                  ),
                ),
                SizedBox(width: 10),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
