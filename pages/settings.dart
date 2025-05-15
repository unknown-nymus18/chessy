import 'package:chessy/services/auth_service.dart';
import 'package:chessy/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Widget tile(Widget leading, Widget trailing) {
      return Container(
        padding: EdgeInsets.all(12),
        // margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [leading, trailing],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("S E T T I N G S"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            tile(
              Text(
                "DARK MODE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            tile(
              Text(
                "Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  // Todo: Navigate to profile page
                },
              ),
            ),
            tile(
              Text(
                "LOG OUT",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  authService.signOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
