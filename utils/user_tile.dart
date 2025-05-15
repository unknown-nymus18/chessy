import 'package:chessy/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  final String username;
  final List<Widget> trailing;
  const UserTile({super.key, required this.username, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Color backgroundColor =
        themeProvider.isDarkMode
            ? const Color.fromARGB(255, 39, 38, 38)
            : const Color.fromARGB(97, 212, 209, 209);
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text(username), Row(children: trailing)],
      ),
    );
  }
}
