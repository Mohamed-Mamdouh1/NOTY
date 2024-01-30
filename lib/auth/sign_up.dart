import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/components/custom_button.dart';
import 'package:note_app/components/custom_logo.dart';
import 'package:note_app/components/text_form_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late StreamSubscription subscription;
  void createUserAccount() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
     CollectionReference username= FirebaseFirestore.instance.collection("username");
     username.add({"username":userController.text,"id":FirebaseAuth.instance.currentUser!.uid});
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        AwesomeDialog(
          btnOkText: "verify My Email",
          btnOkOnPress: () {
            FirebaseAuth.instance.currentUser!.sendEmailVerification();
            Navigator.pushReplacementNamed(context, "login");
          },
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.RIGHSLIDE,
          title: 'Email verification ',
          desc: 'Please Verify your Email ',
        ).show();
            }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            backgroundColor: Colors.deepOrange,
            content: Text("The password provided is too weak."),
            duration: Duration(seconds: 2),
          ),
        );
        // print('The password provided is too weak.');
      }
      else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12))),
            backgroundColor: Colors.deepOrange,
            content: Text("The account already exists for that email."),
            duration: Duration(seconds: 2),
          ),
        );

        //  print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    hasInternet
        ? createUserAccount()
        : showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "No Internet",
                      style: TextStyle(color: Colors.red),
                    ),
                    Icon(
                      Icons.signal_wifi_connected_no_internet_4_sharp,
                      color: Colors.red,
                    ),
                  ],
                ),
                content: Text(
                  "Sorry, there is no internet connection at the moment.\nPlease check your internet connection and try again. ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Okay",
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ))
                ],
              );
            });
  }

  @override
  void initState() {
    subscription = Connectivity().onConnectivityChanged.listen(_showSnackBar);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Form(
            key: formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                ),
                const CustomLogo(),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "SignUp",
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Sign up to continue using the app ",
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 18,
                        color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "User Name",
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                CustomTextField(
                    validator: (val) {
                      if (val == "") {
                        return "This field can not be empty";
                      }
                    },
                    controller: userController,
                    hint: "Enter your Name"),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Email",
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                CustomTextField(
                    validator: (val) {
                      if (val == "") {
                        return "This field can not be empty";
                      }
                    },
                    controller: emailController,
                    hint: "Enter your Email"),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Password",
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                CustomTextField(
                  validator: (val) {
                    if (val == "") {
                      return "This field can not be empty";
                    }
                  },
                  controller: passwordController,
                  hint: "Enter your Password",
                  suffixIcon: Icons.remove_red_eye,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          CustomButton(
            onTap: () async {
              final result = await Connectivity().checkConnectivity();
              if (formState.currentState!.validate()) {
                _showSnackBar(result);
              }
            },
            title: "SignUp",
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(" Have an account? "),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                },
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.orange),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
