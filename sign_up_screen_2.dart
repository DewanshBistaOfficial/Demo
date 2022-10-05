import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dilo/screens/signed_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen2 extends StatefulWidget {
  const SignUpScreen2(
      {super.key,
      required this.username,
      required this.password,
      required this.email});

  final String username;
  final String password;
  final String email;

  @override
  State<SignUpScreen2> createState() => _SignUpScreen2State();
}

class _SignUpScreen2State extends State<SignUpScreen2> {
  DateTime selectedDate = DateTime.now();
  bool agreeToTerms = false;
  int age = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Container(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Spacer(),
              const Text("Date of Birth:", textScaleFactor: 2),
              Text("${selectedDate.toLocal()}".split(' ')[0],
                  textScaleFactor: 3),
              ElevatedButton(
                onPressed: () => _selectDate(context), // Refer step 3
                child: const Text(
                  'Select date',
                ),
              ),
              const Spacer(flex: 2),
              Row(
                children: <Widget>[
                  const Spacer(),
                  const Text("Agree to Terms and Conditions"),
                  Checkbox(
                      checkColor: Colors.white,
                      value: agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          agreeToTerms = value!;
                        });
                      }),
                  const Spacer(),
                ],
              ),
              ElevatedButton(
                onPressed: () => _signUp(), // Refer step 3
                child: const Text(
                  'Submit',
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: selectedDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        age = _updateAge(selectedDate);
      });
    }
  }

  void _signUp() {
    bool canSignUp = true;
    if (!agreeToTerms) {
      _displayDialog("Need To Agree To Terms and Conditions");
      canSignUp = false;
    }

    if (age < 18) {
      _displayDialog("Must be a valid adult age");
      canSignUp = false;
    }

    if (canSignUp) {
      _signUpHelper(context, widget.email, widget.password);
    }
  }

  int _updateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int userAge = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      userAge--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        userAge--;
      }
    }
    return userAge;
  }

  Future<void> populateUserInformation() async {
    final images = FirebaseStorage.instance;
    final db = FirebaseFirestore.instance;
    String? id = FirebaseAuth.instance.currentUser?.uid;

    //Populate profile picture and create user bucket in image storage
    var storageRef =
        images.ref().child("users").child("Error").child("profile");
    if (id != null) {
      storageRef = images.ref().child("users").child(id).child("profile");
    }
    storageRef = storageRef.child("profile.jpg");
    try {
      final data =
          await images.ref().child("default").child("profile.jpg").getData();
      if (data != null) {
        await storageRef.putData(data);
      }
    } on FirebaseException {
      return;
    }

    //Set user data
    final userData = <String, dynamic>{
      "Username": widget.username,
      "Birthdate": selectedDate,
      "Outfits": 0,
      "Followers": 0,
      "Following": 0,
    };
    db.collection("users").doc(id).set(userData);
  }

  Future<void> _signUpHelper(context, email, password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await populateUserInformation();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignedInScreen()),
        ModalRoute.withName('SignedInScreen'),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _displayDialog('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        _displayDialog('The account already exists for that email.');
      } else {
        _displayDialog('Please double check your information');
      }
    }
  }

  _displayDialog(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }
}
