import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app/components/custom_button.dart';
import 'package:note_app/components/custom_logo.dart';
import 'package:note_app/components/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late StreamSubscription subscription;
  void userLogin() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
//Email verification
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        AwesomeDialog(
          btnOkOnPress: () async {
            Navigator.pushNamedAndRemoveUntil(context, "home-page",(route) {
              return false;
            });
          },
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.RIGHSLIDE,
          title: 'Success',
          desc: 'Login successfully',
        ).show();
      } else {
        AwesomeDialog(
          btnOkText: "Send Message",
          btnOkOnPress: () {
            FirebaseAuth.instance.currentUser!.sendEmailVerification();
          },
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.RIGHSLIDE,
          title: 'Email verification',
          desc: 'Please verify your Email to continue',
        ).show();
      }
      //Email verification
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text("No user found for that email."),
            duration: Duration(seconds: 2),
          ),
        );
        // print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text("Wrong password provided for that user."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Can not sign up with google at this time please try again later"),
        backgroundColor: Colors.deepOrange,
      ));
    }
  }

  void passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);
      AwesomeDialog(
        btnOkOnPress: () {},
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.RIGHSLIDE,
        title: 'Reset Password',
        desc: 'Please check your gmail to reset password',
      ).show();
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
          content: Text("This Email not found "),
          backgroundColor: Colors.deepOrange,
        ));
      }else if(e.code=="network-request-failed"){
        showDialog(
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
                content: Text("Sorry, there is no internet connection at the moment.\nPlease check your internet connection and try again. ",style: TextStyle(fontWeight: FontWeight.bold),),
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

      else {
        print(e.code);
      }
    }
  }

  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    hasInternet
        ? userLogin()
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
            content: Text("Sorry, there is no internet connection at the moment.\nPlease check your internet connection and try again. ",style: TextStyle(fontWeight: FontWeight.bold),),
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                    "Login",
                    style: TextStyle(
                        fontFamily: "Schyler",
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Login To continue using the app ",
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
                  controller: passwordController,
                  hint: "Enter your Password",
                  suffixIcon: Icons.remove_red_eye,
                  validator: (val) {
                    if (val == "") {
                      return "This field can not be empty";
                    }
                  },
                ),
                GestureDetector(
                  onTap: passwordReset,
                  child: Container(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: passwordReset,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          CustomButton(
            onTap: () async{
              final result = await Connectivity().checkConnectivity();
              if (formState.currentState!.validate()) {
                _showSnackBar(result);
              } else {
                print ("error");
              }
            },
            title: "Login",
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Container(height: 2, color: Colors.grey.shade200)),
              const Text(
                "Or Login with",
                textAlign: TextAlign.center,
              ),
              Expanded(
                  child: Container(height: 2, color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 25,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: signInWithGoogle,
                child: Image.asset(
                  "images/4.png",
                  height: 50,
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? "),
              TextButton(
                onPressed: (){

                  Navigator.pushNamed(context, "signup");
                },
                child: const Text(
                  "Register",
                  style: TextStyle(color: Colors.orange),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
