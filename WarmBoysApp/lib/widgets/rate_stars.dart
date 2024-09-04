import 'package:flutter/material.dart';

class RateStars extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;

  const RateStars({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Color.fromARGB(255, 229, 173, 5),
                    size: 30,
                  ),
                  onPressed: () {
                    onRatingChanged(index + 1);
                  },
                );
              },
            ),
          ),
          SizedBox(width: 10),
          Text(
            '${rating}점 / 5점',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
