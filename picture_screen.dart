import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';

class PictureScreen extends StatefulWidget {
  const PictureScreen({Key? key}) : super(key: key);
  @override
  State<PictureScreen> createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  late TextEditingController _tagController;
  var db = FirebaseFirestore.instance;
  bool confirm = false;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyUser user = Provider.of<MyUser>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take a picture"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          confirm ? _preview() : _logo(),
          confirm ? _tagWriter() : const Text(""),
          confirm ? _overlayBar2(user, _tagController.text) : _overlayBar(user),
        ],
      ),
    );
  }

  Widget _tagWriter() {
    const myStyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30);
    return Row(
      children: [
        const Text("#", style: myStyle),
        Expanded(
          child: TextField(
            style: myStyle,
            controller: _tagController,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Type of outfit?",
                hintStyle: myStyle),
          ),
        ),
      ],
    );
  }

  Widget _logo() {
    const myStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 50);
    return const SizedBox.expand(
      child: Center(
        child: Text("Dilo", style: myStyle),
      ),
    );
  }

  Widget _preview() {
    if (imagePath == null) {
      return const Text("Error");
    } else {
      return SizedBox.expand(
        child: Image.file(File(imagePath!), fit: BoxFit.cover),
      );
    }
  }

  Widget _overlayBar(MyUser user) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        child: Container(
          color: Colors.grey.withOpacity(0.5),
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  selectPicture();
                },
                child: const Icon(Icons.arrow_circle_up),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  takePicture();
                },
                child: const Icon(Icons.camera_alt),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overlayBar2(MyUser user, String text) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        child: Container(
          color: Colors.grey.withOpacity(0.5),
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    confirm = false;
                    imagePath = null;
                  });
                },
                child: const Icon(Icons.stop),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text("Submit ?"),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  submitPicture(user, text);
                  user.addPicture();
                },
                child: const Icon(Icons.check),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  submitPicture(MyUser user, String text) {
    storePictureFirebase(user, text);
    setState(() {
      confirm = false;
      imagePath = null;
    });
  }

  takePicture() async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      Fluttertoast.showToast(
          msg: "No Picture",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    } else {
      setState(() {
        imagePath = image.path;
        confirm = true;
      });
    }
  }

  selectPicture() async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      Fluttertoast.showToast(
          msg: "No Image Selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    } else {
      imagePath = image.path;
      setState(() {
        confirm = true;
      });
    }
  }

  Future<void> storePictureFirebase(MyUser user, String keyword) async {
    final file = File(imagePath!);
    // Create a storage reference from our app
    final storageRef =
        FirebaseStorage.instance.ref().child("users").child(user.id);
    String picName = db.collection("ID").doc().id;

    //Need to generate id
    final imageRef = storageRef.child("$picName.jpg");

    try {
      await imageRef.putFile(file);
    } on FirebaseException {
      return;
    }

    List<String> keywords = ["all"];
    if (keyword != '') {
      keywords.add(keyword.toLowerCase());
    }
    final url = await imageRef.getDownloadURL();
    final picture = <String, String>{
      "url": url,
    };

    //Add to firebase
    for (String word in keywords) {
      db.collection(word).doc(picName).set(picture);
    }
    db
        .collection("users")
        .doc(user.id)
        .collection("pictureList")
        .doc(picName)
        .set(picture);

    user.populatePictureFromUrl(url);
  }
}
