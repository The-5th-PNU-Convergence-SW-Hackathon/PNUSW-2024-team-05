import 'package:flutter/material.dart';

class ExchangeCard extends StatelessWidget {
  final String goodsName;
  final String inc;
  final String imgUrl;
  final int maxHeadcounts;
  final int needCredit;

  ExchangeCard({
    required this.goodsName,
    required this.inc,
    required this.imgUrl,
    required this.maxHeadcounts,
    required this.needCredit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            (imgUrl != '')
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(imgUrl),
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
                  Text('${goodsName} <-> 크레딧 ${needCredit}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(inc),
                  Text('모집 인원 : ${maxHeadcounts}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
