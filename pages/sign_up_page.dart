import 'package:chessy/services/auth_service.dart';
import 'package:chessy/services/database.dart';
import 'package:chessy/utils/custom_button.dart';
import 'package:chessy/utils/custom_text_field.dart';
import 'package:chessy/utils/functions.dart';
import 'package:chessy/utils/theme_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  AuthService authService = AuthService();
  Database db = Database();

  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  bool valid() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty & emailController.text.isNotEmpty) {
      if (passwordController.text == confirmPasswordController.text) {
        return true;
      }
      return false;
    }
    return false;
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
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'chessy-image',
            child: Image.asset(
              "lib/assets/images/chessy.png",
              height: 400,
              width: 400,
              color: Colors.white.withOpacity(0.4),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'S I G N   U P   H E R E',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color:
                              themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        false,
                        labelText: "Username",
                        controller: usernameController,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        false,
                        labelText: "Email",
                        controller: emailController,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        true,
                        labelText: "Password",
                        controller: passwordController,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        true,
                        labelText: "Confirm Password",
                        controller: confirmPasswordController,
                      ),
                      SizedBox(height: 15),
                      CustomButton(
                        text: "S I G N  U P",
                        onTap: () async {
                          if (valid()) {
                            if (await db.isUsernameTaken(
                              usernameController.text,
                            )) {
                              customSnackBar(
                                'Username is already taken',
                                context,
                              );
                            } else {
                              authService.createUser(
                                username: usernameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              Navigator.pop(context);
                              customSnackBar(
                                "User created successfully",
                                context,
                              );
                            }
                          } else {
                            customSnackBar(
                              "An unexpected error occurred. Check the details",
                              context,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Text("Already have an account?"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                themeProvider.isDarkMode
                                    ? Colors.purple
                                    : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
