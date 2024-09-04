import 'package:flutter/material.dart';

class MemberDetailsScrollview extends StatelessWidget {
  final String dependentType;
  final bool withPet;
  final bool withCam;

  MemberDetailsScrollview({
    required this.dependentType,
    required this.withPet,
    required this.withCam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (dependentType.isNotEmpty)
              _MemberDetailsCard(type: dependentType),
            if (withPet) _MemberDetailsCard(type: '반려동물'),
            if (withCam) _MemberDetailsCard(type: 'CCTV'),
          ],
        ),
      ),
    );
  }
}

class _MemberDetailsCard extends StatelessWidget {
  final String type;

  _MemberDetailsCard({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case '독거':
        icon = Icons.person;
        break;
      case '2~3인':
        icon = Icons.group;
        break;
      case '4인 이상':
        icon = Icons.people;
        break;
      case '반려동물':
        icon = Icons.pets;
        break;
      case 'CCTV':
        icon = Icons.videocam;
        break;
      default:
        icon = Icons.help_outline;
    }
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.0),
      ),
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 60),
            SizedBox(height: 10),
            Text(type, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
