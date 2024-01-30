import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:note_app/components/custom_button.dart';
import 'package:note_app/components/text_form_field.dart';
import 'package:note_app/note/view.dart';

class UpdateNote extends StatefulWidget {
  const UpdateNote({Key? key, required this.noteDocId, required this.isDarkMode, required this.categoryId, required this.oldNote, this.url})
      : super(key: key);
  final bool isDarkMode;
  final String noteDocId;
  final String categoryId;
  final String oldNote;
  final String ?url;

  @override
  State<UpdateNote> createState() => _UpdateNoteState();
}

class _UpdateNoteState extends State<UpdateNote> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();

  late StreamSubscription subscription;
  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    hasInternet
        ? updateNote()
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

  Future<void> updateNote() async {
    CollectionReference notes = FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryId)
        .collection("note");
    if (formState.currentState!.validate()) {
      return await notes.doc(widget.noteDocId).update(
          {
        "name": note.text,
          }
      )
          .then((value) => AwesomeDialog(
        btnOkOnPress: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NoteView(
                      isDarkMode: widget.isDarkMode,
                      categoryId: widget.categoryId))
          );
        },
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.RIGHSLIDE,
        title: 'Success',
        desc: 'The Note was Updated successfully',
      ).show())
          .catchError((error) => print(error.toString()));
    }
  }

  @override
  void initState() {
    note.text=widget.oldNote;

    super.initState();
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formState,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                    controller: note,
                    hint: "Edit Your Note",
                    validator: (val) {
                      if (val == "") {
                        return "This field can't be empty";
                      }
                    }),
                const SizedBox(
                  height: 30,
                ),
                CustomButton(
                    onTap: () async {
                      subscription = Connectivity().onConnectivityChanged.listen(_showSnackBar);
                      final result = await Connectivity().checkConnectivity();
                      _showSnackBar(result);
                    },
                    title: "Edit Note"),
                const SizedBox(
                  height: 30,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child:
                  widget.url!=null?
                  Image.network(widget.url!):Container(),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
