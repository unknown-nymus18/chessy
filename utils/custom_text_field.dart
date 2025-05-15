import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  bool isPassword = false;
  final Function(String)? onChanged;
  final TextEditingController controller;
  EdgeInsets? padding;
  CustomTextField(
    this.isPassword, {
    super.key,
    this.onChanged,
    this.padding,
    required this.labelText,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 3,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).highlightColor,
          hintText: widget.labelText,

          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  )
                  : null,
        ),
        obscureText: widget.isPassword ? obscureText : false,
      ),
    );
  }
}
