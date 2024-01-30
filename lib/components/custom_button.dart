import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  const CustomButton({Key? key, required this.onTap, required this.title}) : super(key: key);
final void Function() onTap;
final String title;

  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(

          style: ElevatedButton.styleFrom(primary: Colors.orange),
          onPressed: onTap,
          child:  Text(
            title,
            style: const TextStyle(color: Colors.white),
          )),
    );
  }
}
