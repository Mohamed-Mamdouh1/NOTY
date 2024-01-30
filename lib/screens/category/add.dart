import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/components/custom_button.dart';
import 'package:note_app/components/text_form_field.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController categoryName = TextEditingController();

  CollectionReference categories =
      FirebaseFirestore.instance.collection("categories");
  late StreamSubscription subscription;
  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    hasInternet
        ? addCategory()
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

  Future<void> addCategory() async {
    if (formState.currentState!.validate()) {
      return await categories
          .add({
            "name": categoryName.text,
        "id":FirebaseAuth.instance.currentUser!.uid,

          })
          .then((value) => AwesomeDialog(
                btnOkOnPress: () async {
                  Navigator.pushNamedAndRemoveUntil(context, "home-page",
                      (route) {
                    return false;
                  });
                },
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                context: context,
                dialogType: DialogType.SUCCES,
                animType: AnimType.RIGHSLIDE,
                title: 'Success',
                desc: 'The Category was added successfully',
              ).show())
          .catchError((error) => print(error.toString()));
    }
  }
  @override
  void initState() {
    subscription=Connectivity().onConnectivityChanged.listen(_showSnackBar);
    super.initState();
  }
  @override
  void dispose() {
    categoryName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formState,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                  controller: categoryName,
                  hint: "Enter Category Name",
                  validator: (val) {
                    if (val == "") {
                      return "This field can't be empty";
                    }
                  }),
              SizedBox(
                height: 30,
              ),
              CustomButton(onTap: ()async{
                final result = await Connectivity().checkConnectivity();
                _showSnackBar(result);
              }, title: "Add Category")
            ],
          ),
        ),
      ),
    );
  }
}
