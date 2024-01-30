import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.height * .25,
          height: MediaQuery.of(context).size.height * .25,
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.orangeAccent),
              borderRadius: BorderRadius.circular(40),
              color: Colors.grey.shade300),
          child: Image.asset(
            "images/sticky-note.png",
            height: MediaQuery.of(context).size.height * .25,
            width: MediaQuery.of(context).size.height * .25,
          )),
    );
  }
}
