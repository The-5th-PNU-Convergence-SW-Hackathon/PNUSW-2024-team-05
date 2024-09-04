import 'package:flutter/material.dart';
import 'package:warm_boys/widgets/custum_alarm.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;

  CustomAppBar({
    required this.title,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      title: Text(title,
          style:
              TextStyle(fontFamily: 'NotoSansKR', fontWeight: FontWeight.w400)),
      actions: [
        CustomAlarmButton(),
        IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
