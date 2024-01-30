import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/components/custom_button.dart';
import 'package:note_app/components/text_form_field.dart';
import 'package:note_app/note/view.dart';

class AddNote extends StatefulWidget {
  const AddNote({Key? key, required this.docId, required this.isDarkMode})
      : super(key: key);
  final bool isDarkMode;
  final String docId;

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController note = TextEditingController();
  late StreamSubscription subscription;
  File? file;
  String?url;
  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    hasInternet
        ? addNote()
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

  Future<void> addNote() async {
    CollectionReference notes = FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.docId)
        .collection("note");
    if (formState.currentState!.validate()) {
      return await notes
          .add({
            "name": note.text,
            "photo":url,
          })
          .then((value) => AwesomeDialog(
                btnOkOnPress: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NoteView(
                              isDarkMode: widget.isDarkMode,
                              categoryId: widget.docId,url: url,)));
                },
                dismissOnTouchOutside: false,
                dismissOnBackKeyPress: false,
                context: context,
                dialogType: DialogType.SUCCES,
                animType: AnimType.RIGHSLIDE,
                title: 'Success',
                desc: 'The Note was added successfully',
              ).show())
          .catchError((error) => print(error.toString()));
    }
  }

  @override
  void initState() {
    subscription = Connectivity().onConnectivityChanged.listen(_showSnackBar);
    super.initState();
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  captureImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      file = File(photo.path);
      String imageName=DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef=FirebaseStorage.instance.ref(imageName);
      await storageRef.putFile(file!);
      url= await storageRef.getDownloadURL();
      setState(() {});
    }
  }
  selectImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      file = File(photo.path);
      String imageName=DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef=FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid).child(imageName);
      await storageRef.putFile(file!);
      url= await storageRef.getDownloadURL();
      setState(() {});

    }
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
                    hint: "Enter Your Note",
                    validator: (val) {
                      if (val == "") {
                        return "This field can't be empty";
                      }
                    }),

                SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    file == null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                          child: Image.asset("images/placeHolder.jpg",height: 200,width: 200,),
                        )
                        : ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.file(file!,height: 200,width: 200,)),
                    SizedBox(height: 10,),
                    CustomButton(
                        onTap: () async {

                          AwesomeDialog(
                            buttonsTextStyle: TextStyle(fontSize: 10,color: Colors.white),
                            btnOkText: "Capture from Camera",
                            btnOkOnPress: () async {
                              await captureImageFromCamera();
                            },
                            btnCancelText: "Select from Gallery",
                            btnCancelOnPress: ()async{
                              await selectImageFromGallery();
                            },
                            btnCancelColor: Colors.orange,
                            dismissOnTouchOutside: true,
                            dismissOnBackKeyPress: true,
                            context: context,
                            dialogType: DialogType.NO_HEADER,
                            animType: AnimType.RIGHSLIDE,
                            titleTextStyle: const TextStyle(fontFamily: "Schyler",color: Colors.black),
                            title: 'Image Selection ',
                            desc: 'Upload you image',
                          ).show();


                        },
                        title: "Add PHOTO"),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                CustomButton(
                    onTap: () async {
                      final result = await Connectivity().checkConnectivity();
                      _showSnackBar(result);
                    },
                    title: "Add NOTE"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
