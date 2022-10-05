import 'package:dilo/screens/flip_screen.dart';
import 'package:dilo/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../screens/feed_screen.dart';
import '../screens/picture_screen.dart';
import '../screens/profile_screen.dart';

class SignedInScreen extends StatefulWidget {
  const SignedInScreen({Key? key}) : super(key: key);

  @override
  State<SignedInScreen> createState() => _SignedInScreenState();
}

class _SignedInScreenState extends State<SignedInScreen> {
  int _currentIndex = 0;
  final screens = [
    const PictureScreen(),
    const FeedScreen(),
    const FlipScreen(),
    const ProfileScreen(),
    const SettingScreen()
  ];

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyUser>(
      create: (context) => MyUser(),
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: 'Picture',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.feed),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flip),
                label: 'Flip',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Profile',
              ),
            ],
            onTap: (index) => setState(() {
              _currentIndex = index;
            }),
            currentIndex: _currentIndex,
          ),
        ),
      ),
    );
  }
}
