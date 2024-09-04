import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();

    bool hasHalfStar = (rating - fullStars) >= 0.5;

    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, color: Color.fromARGB(255, 224, 73, 81), size: 16),
        if (hasHalfStar)
          Icon(Icons.star_half,
              color: Color.fromARGB(255, 224, 73, 81), size: 16),
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_border,
              color: Color.fromARGB(255, 224, 73, 81), size: 16),
      ],
    );
  }
}
