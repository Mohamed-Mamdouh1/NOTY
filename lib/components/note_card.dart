import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:note_app/note/edit.dart';
import 'package:note_app/screens/category/update_Page.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    Key? key,
    required this.isDarkMode,
    required this.text,
    required this.onDeleteButtonPressed,
    required this.docID,
    required this.categoryId, this.url,
  }) : super(key: key);

  final bool isDarkMode;
  final String text;
  final Future<void> Function() onDeleteButtonPressed;
  final String docID;
  final String categoryId;
  final String?url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => UpdateNote(
                noteDocId: docID,
                isDarkMode: isDarkMode,
                categoryId: categoryId,
                oldNote: text,
            url:url
            ),
          ),
        );
      },
      onLongPress: () {
        AwesomeDialog(
          btnOkOnPress: () async {
            onDeleteButtonPressed();
          },
          btnOkText: "Delete",
          titleTextStyle: TextStyle(color: Colors.red),
          btnCancelOnPress: () {},
          btnCancelText: "Cancel",
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.RIGHSLIDE,
          title: 'Confirm Removal',
          desc:
              'Are you sure you want to remove this note?\nThis action cannot be undone.',
        ).show();
      },
      child: Card(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFamily: "Kalnia",
                  ),
                ),
                SizedBox(height: 8,),
                url!=null ?Image.network(url!,fit: BoxFit.cover,):Container()

              ],
            ),
          ),
        ),
      ),
    );
  }
}
