import 'package:flutter/material.dart';
import 'package:warm_boys/widgets/custum_alarm.dart';

class CustomAppBarWithTab extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  CustomAppBarWithTab({
    required this.title,
    this.leading,
    this.bottom,
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
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
