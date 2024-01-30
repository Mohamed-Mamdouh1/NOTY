import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart  ';
import 'package:note_app/components/category_card.dart';

import '../components/note_card.dart';
import 'add.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key, required this.isDarkMode, required this.categoryId, this.url})
      : super(key: key);
  final bool isDarkMode;
final String? url;
  final String categoryId;
  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  List<QueryDocumentSnapshot> data = [];
  List<QueryDocumentSnapshot> username = [];
  void userSignOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
  }

  bool isLoading = true;
  void getData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .doc(widget.categoryId)
        .collection("note")
        .orderBy("name",descending: true)
        .get();
    setState(() {
      data.addAll(snapshot.docs);
      isLoading = false;
    });
  }

  void getUsername() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("username")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      username.addAll(snapshot.docs);
      isLoading = false;
    });
  }

  Future<void> deleteNote(int index) async {
    try {
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.categoryId)
          .collection("note")
          .doc(data[index].id)
          .delete()
          .then((value) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => NoteView(
                isDarkMode: widget.isDarkMode, categoryId: widget.categoryId)));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Note was deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Note was not deleted $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    if(data[index]["photo"]!=null){
      FirebaseStorage.instance.refFromURL(data[index]["photo"]).delete();
    }

  }

  @override
  void initState() {
    getUsername();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
          onWillPop: () {
            Navigator.pushNamedAndRemoveUntil(
                context, "home-page", (route) => false);
            return Future.value(false);
          },
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                )
              : data.isEmpty
                  ? SingleChildScrollView(
                      child: width > height
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                username.isEmpty
                                    ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                    ))
                                    :
                                Container(
                                  width: MediaQuery.of(context).size.width/2,
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "HELLO , \n ${username[0]["username"]}"
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w800,
                                              fontFamily: "Kalnia",
                                              fontSize: 30),

                                        ),
                                      ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      widget.isDarkMode
                                          ? Image.asset(
                                              "images/vector3.jpg",
                                            )
                                          : Image.asset("images/vector.jpg"),
                                      const Text("Please Add Notes")
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Column(
                              children: [
                                username.isEmpty
                                    ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                    ))
                                    :
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "HELLO , \n ${username[0]["username"]}"
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: "Kalnia",
                                        fontSize: 30),
                                    maxLines: 2,
                                  ),
                                ),
                                Column(
                                  children: [
                                    widget.isDarkMode
                                        ? Image.asset(
                                            "images/vector3.jpg",
                                          )
                                        : Image.asset("images/vector.jpg"),
                                    const Text("Please Add Notes")
                                  ],
                                )
                              ],
                            ),
                    )
                  : width > height
                      ? Row(
                          children: [
                            username.isEmpty
                                ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ))
                                :
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              alignment: Alignment.topLeft,
                              child: Text(
                                "hello , \n ${username[0]["username"]}"
                                    .toUpperCase(),
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: "Kalnia",
                                    fontSize: 30),
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                itemCount: data.length,
                                itemBuilder: ((ctx, index) {
                                  return NoteCard(
                                    categoryId: widget.categoryId,
                                    docID: data[index].id,
                                    isDarkMode: widget.isDarkMode,
                                    text: data[index]["name"],
                                    onDeleteButtonPressed: () async {
                                      deleteNote(index);
                                    },
                                    url:data[index]["photo"],
                                  );
                                }),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, mainAxisExtent: 160),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            username.isEmpty
                                ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ))
                                :
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "HELLO , \n ${username[0]["username"]}".toUpperCase(),
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: "Kalnia",
                                    fontSize: 30),
                                maxLines: 2,
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                itemCount: data.length,
                                itemBuilder: ((ctx, index) {
                                  return NoteCard(
                                    categoryId: widget.categoryId,
                                    docID: data[index].id,
                                    isDarkMode: widget.isDarkMode,
                                    text: data[index]["name"],
                                    onDeleteButtonPressed: () async {
                                      deleteNote(index);
                                    },
                                    url:data[index]["photo"] ,
                                  );
                                }),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, mainAxisExtent: 160),
                              ),
                            ),
                          ],
                        )),
      floatingActionButton: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddNote(
                isDarkMode: widget.isDarkMode,
                docId: widget.categoryId,
              ),
            ),
          );
        },
        child: const CircleAvatar(
            backgroundColor: Colors.deepOrange,
            radius: 30,
            child: Icon(
              Icons.add,
              color: Colors.white,
            )),
      ),
    );
  }
}
