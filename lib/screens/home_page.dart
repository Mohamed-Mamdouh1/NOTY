import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart  ';
import 'package:note_app/components/category_card.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {Key? key, required this.isDarkMode, required this.toggleTheme})
      : super(key: key);
  final bool isDarkMode;
  final Function() toggleTheme;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QueryDocumentSnapshot> data = [];
  List<QueryDocumentSnapshot> username = [];
  late StreamSubscription subscription;
  final Stream<QuerySnapshot> categoriesStream =
      FirebaseFirestore.instance.collection("categories").snapshots();

  _showSnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    if (!hasInternet) {
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
  }

  void userSignOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
  }

  bool isLoading = true;
  void getCategories() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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

  Future<void> deleteCategory(int index) async {
    try {
      await deleteSubcollectionDocuments("categories", data[index].id, "note",);
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(data[index].id)
          .delete()
          .then((value) {
        Navigator.of(context).pushReplacementNamed("home-page");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Category was deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Category was not deleted $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
    
  }

  Future<void> deleteSubcollectionDocuments(String collectionPath,
      String documentId, String subcollectionPath) async {
    final QuerySnapshot subcollectionSnapshot = await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(documentId)
        .collection(subcollectionPath)
        .get();
    for (QueryDocumentSnapshot doc in subcollectionSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  void initState() {
    getUsername();
    getCategories();
    subscription = Connectivity().onConnectivityChanged.listen(_showSnackBar);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NOTY",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontFamily: "Schyler"
          ),
        ),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.deepOrange,
            child: IconButton(
                onPressed: () {
                  widget.toggleTheme();
                },
                icon: widget.isDarkMode == false
                    ? const Icon(
                        Icons.dark_mode_rounded,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.light_mode_rounded,
                        color: Colors.white,
                      )),
          ),
          const SizedBox(
            width: 2,
          ),
          CircleAvatar(
            backgroundColor: Colors.deepOrange,
            child: IconButton(
              onPressed: userSignOut,
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body:
      isLoading
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
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
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
                            Expanded(
                              child: Column(
                                children: [
                                  widget.isDarkMode
                                      ? Image.asset(
                                          "images/vector3.jpg",
                                        )
                                      : Image.asset("images/vector.jpg"),
                                  const Text("Please Add categories")
                                ],
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            username.isNotEmpty
                                ? Container(
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
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            Column(
                              children: [
                                widget.isDarkMode
                                    ? Image.asset(
                                        "images/vector3.jpg",
                                      )
                                    : Image.asset("images/vector.jpg"),
                                const Text("Please Add categories")
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
                            : Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "hello , \n${username[0]["username"]}"
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: "Kalnia",
                                        fontSize: 30),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                        Expanded(
                          child: StreamBuilder(
                              stream: categoriesStream,
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Text("Something went wrong");
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(color: Colors.red,));
                                }
                                if (snapshot.data == null) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        widget.isDarkMode
                                            ? Image.asset(
                                                "images/vector3.jpg",
                                              )
                                            : Image.asset("images/vector.jpg"),
                                        const Text("Please Add categories")
                                      ],
                                    ),
                                  );
                                } else {
                                  return GridView.builder(
                                    itemCount: data.length,
                                    itemBuilder: ((ctx, index) {
                                      return CategoryCard(
                                        docID: data[index].id,
                                        isDarkMode: widget.isDarkMode,
                                        text: data[index]["name"],
                                        onDeleteButtonPressed: () async {
                                          deleteCategory(index);
                                        },
                                      );
                                    }),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisExtent: 160),
                                  );
                                }
                              }),
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
                            : Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "HELLO , \n ${username[0]["username"]}"
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontFamily: "Kalnia",
                                      fontSize: 30),
                                  maxLines: 2,
                                ),
                              ),
                        Expanded(
                          child: StreamBuilder(
                              stream: categoriesStream,
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.data == null) {

                                  return Column(
                                    children: [
                                      widget.isDarkMode
                                          ? Image.asset(
                                              "images/vector3.jpg",
                                            )
                                          : Image.asset("images/vector.jpg"),
                                      const Text("Please Add categories")
                                    ],
                                  );
                                } else {

                                  return


                                    GridView.builder(
                                    itemCount: data.length,
                                    itemBuilder: ((ctx, index) {
                                       return CategoryCard(
                                        docID: data[index].id,
                                        isDarkMode: widget.isDarkMode,
                                        text: data[index]["name"],
                                        onDeleteButtonPressed: () async {
                                          deleteCategory(index);
                                        },
                                      );
                                    }),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisExtent: 160),
                                  );
                                }
                              }),
                        ),
                      ],
                    ),
      floatingActionButton: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          final result = await Connectivity().checkConnectivity();
          _showSnackBar(result);
          Navigator.of(context).pushNamed("add-category");
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
