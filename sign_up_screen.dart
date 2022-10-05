import 'package:dilo/screens/sign_up_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(),
              TextField(
                controller: _passwordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const Spacer(flex: 2),
              ElevatedButton(onPressed: _signUp, child: const Text("Next")),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() {
    if (_authenticate()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SignUpScreen2(
                  username: _usernameController.text,
                  password: _passwordController.text,
                  email: _emailController.text)));
    }
  }

  bool _authenticate() {
    return _authenticateUsername() &&
        _authenticateEmail() &&
        _authenticatePassword();
  }

  bool _authenticateUsername() {
    String username = _usernameController.text;
    if (username.isEmpty) {
      _displayDialog("Username can't be blank");
      return false;
    }

    return true;
  }

  bool _authenticateEmail() {
    String email = _emailController.text;
    if (email.isEmpty) {
      _displayDialog("email can't be blank");
      return false;
    }

    return true;
  }

  bool _authenticatePassword() {
    String password = _passwordController.text;
    String passwordConfirm = _passwordConfirmController.text;
    if (password.length < 6) {
      _displayDialog("Passwords must 6 characters or greater");
      return false;
    }

    if (password.compareTo(passwordConfirm) != 0) {
      _displayDialog("Passwords must match");
      return false;
    }
    return true;
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
