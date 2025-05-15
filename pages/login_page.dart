import 'package:chessy/services/auth_service.dart';
import 'package:chessy/pages/sign_up_page.dart';
import 'package:chessy/utils/custom_button.dart';
import 'package:chessy/utils/functions.dart';
import 'package:chessy/utils/custom_text_field.dart';
import 'package:chessy/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthService authService = AuthService();

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                themeProvider.toggleTheme();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                customSnackBar(
                  themeProvider.isDarkMode
                      ? "Dark mode enabled"
                      : "Light mode enabled",
                  context,
                ),
              );
            },
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 30,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'chessy-image',
              child: Image.asset(
                "assets/images/chessy.png",
                height: 300,
                width: 300,
              ),
            ),
            Text(
              'L O G I N    H E R E',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 10),
            CustomTextField(
              false,
              labelText: "Username",
              controller: _usernameController,
            ),
            SizedBox(height: 15),
            CustomTextField(
              true,
              labelText: "Password",
              controller: _passwordController,
            ),
            CustomButton(
              text: "L O G I N",
              onTap: () async {
                if (_usernameController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  if (await _isConnected()) {
                    try {
                      await authService.signIn(
                        email: _usernameController.text,
                        password: _passwordController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        customSnackBar("User logged in successfully!", context),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        customSnackBar("Error: ${e.toString()}", context),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      customSnackBar(
                        "No internet connection. Please check your network.",
                        context,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    customSnackBar("Please fill in all fields", context),
                  );
                }
              },
            ),
            SizedBox(height: 10),
            Text("Don't have an account?"),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpPage();
                    },
                  ),
                );
              },
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.purple : Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
