import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:note_app/screens/category/update_Page.dart';

import '../note/view.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.isDarkMode,
    required this.text,
    required this.onDeleteButtonPressed,
    required this.docID,
  }) : super(key: key);

  final bool isDarkMode;
  final String text;
  final Future<void> Function() onDeleteButtonPressed;
  final String docID;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return NoteView(
            isDarkMode: isDarkMode,
            categoryId: docID,
          );
        }));
      },
      onLongPress: () {
        AwesomeDialog(
          btnOkOnPress: () async {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return UpdateCategory(docID: docID, oldName: text);
            }));
          },
          btnOkText: "Update",
          titleTextStyle: TextStyle(color: Colors.red),
          btnCancelOnPress: () {
            onDeleteButtonPressed();
          },
          btnCancelText: "Delete",
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.RIGHSLIDE,
          title: 'Update or Delete',
          desc: 'Choose an action for your item.',
        ).show();
      },
      child: Container(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              children: [
                !isDarkMode
                    ? Image.asset(
                        "images/folderIcon.png",
                        height: 100,
                      )
                    : Image.asset(
                        "images/blackFolderIcon.png",
                        height: 100,
                      ),
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFamily: "Kalnia",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
