import 'package:flutter/material.dart';

class ActivityTypeScrollView extends StatelessWidget {
  final List<String> activityTypes;

  const ActivityTypeScrollView({
    Key? key,
    required this.activityTypes,
  }) : super(key: key);

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case '디지털 교육':
        return Icons.computer;
      case '병원 동행':
        return Icons.local_hospital;
      case '실내 오락':
        return Icons.games;
      case '실외 활동':
        return Icons.nature_people;
      case '사회적 교류':
        return Icons.people;
      case '문화 및 여가':
        return Icons.theater_comedy;
      case '정서적 지원':
        return Icons.favorite;
      case '지적 활동':
        return Icons.book;
      case '예술 및 창작':
        return Icons.brush;
      case '재능 기부':
        return Icons.volunteer_activism;
      case '취미 활동':
        return Icons.local_florist;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: activityTypes.map((activity) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Icon(
                  _getActivityIcon(activity),
                  size: 40,
                ),
                SizedBox(height: 5),
                Text(
                  activity,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
