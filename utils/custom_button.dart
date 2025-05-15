import 'dart:ui';

import 'package:chessy/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomButton extends StatefulWidget {
  final String text;
  Function() onTap;
  CustomButton({super.key, required this.text, required this.onTap});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double height = 70;

  void animate() {
    setState(() {
      height = 60;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        height = 70;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        animate();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        height: height,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.purple : Colors.blue,
          border: Border.all(
            color: themeProvider.isDarkMode ? Colors.purple : Colors.blue,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'lib/assets/images/pieces.png',
                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                ),
              ],
            ),
            Text(
              widget.text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
