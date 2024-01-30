import 'package:flutter/material.dart';

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:note_app/components/custom_button.dart';
import 'package:note_app/components/text_form_field.dart';

class UpdateCategory extends StatefulWidget {
  const UpdateCategory({Key? key, required this.docID, required this.oldName})
      : super(key: key);
  final String docID;
  final String oldName;

  @override
  State<UpdateCategory> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController categoryName = TextEditingController();

  CollectionReference categories =
      FirebaseFirestore.instance.collection("categories");
  late StreamSubscription subscription;
  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    hasInternet
        ? updateCategory()
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
                content: const Text(
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

  Future<void> updateCategory() async {
    if (formState.currentState!.validate()) {
      return await categories
          .doc(widget.docID)
          .set({
            "name": categoryName.text,
            "id": FirebaseAuth.instance.currentUser!.uid,
          }, SetOptions(merge: true))
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
                desc: 'The Category was updated successfully',
              ).show())
          .catchError((error) => print(error.toString()));
    }
  }

  @override
  void initState() {
    categoryName.text = widget.oldName;
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
              CustomButton(
                  onTap: () async {
                    subscription = Connectivity().onConnectivityChanged.listen(_showSnackBar);

                    final result = await Connectivity().checkConnectivity();
                    _showSnackBar(result);
                  },
                  title: "Save Changes")
            ],
          ),
        ),
      ),
    );
  }
}
