import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField(
      {Key? key,
      required this.controller,
      required this.hint,
      this.suffixIcon,
      required this.validator})
      : super(key: key);
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        cursorColor: Colors.orange,
        style: TextStyle(
          color: Colors.deepOrange,
          fontWeight: FontWeight.w600,
        ),
        obscureText: _obscureText,
        validator: widget.validator,
        controller: widget.controller,
        decoration: InputDecoration(
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? widget.suffixIcon : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                )
              : Icon(widget.suffixIcon),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          filled: false,
          hintText: widget.hint,
        ),
      ),
    );
  }
}
