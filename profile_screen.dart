import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  NetworkImage profilePicture = const NetworkImage(
      'https://upload.wikimedia.org/wikipedia/commons/2/21/Turtle_diversity.jpg');

  int focusedIndex = 0;
  final List<double> percentages = <double>[.654, .315, .95];

  @override
  void initState() {
    super.initState();
    _populateProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Closet"),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            _profilePic(),
            const SizedBox(
              height: 12.0,
            ),
            _statBar(),
            const SizedBox(
              height: 12.0,
            ),
            Expanded(
              child: _userOutfits(),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfilePic() async {
    ImagePicker picker = ImagePicker();
    final user = Provider.of<MyUser>(context, listen: false);
    final storageRef =
        FirebaseStorage.instance.ref().child("users").child(user.id);
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      Fluttertoast.showToast(
          msg: "No Image Selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    } else {
      try {
        await storageRef
            .child('profile')
            .child('profile.jpg')
            .putFile(File(image.path));
        _populateProfile();
      } on FirebaseException {
        Fluttertoast.showToast(
            msg: "Database Error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    }
  }

  void _populateProfile() {
    final user = Provider.of<MyUser>(context, listen: false);
    FirebaseStorage.instance
        .ref()
        .child("users")
        .child(user.id)
        .child('profile')
        .child('profile.jpg')
        .getDownloadURL()
        .then((profilePic) {
      setState(() {
        profilePicture = NetworkImage(profilePic);
      });
    });
  }

  Widget _profilePic() {
    return Stack(
      children: <Widget>[
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: Ink.image(
              fit: BoxFit.cover,
              height: 128,
              width: 128,
              image: profilePicture,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: -10,
          child: ElevatedButton(
            onPressed: _editProfilePic,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
            ),
            child: const Icon(
              Icons.edit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBar() {
    final user = Provider.of<MyUser>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildStat(user.outfitNumber.toString(), '# Outfits'),
        _buildStat(user.followers.toString(), '# Followers'),
        _buildStat(user.following.toString(), '# Following'),
      ],
    );
  }

  void _onItemFocus(int index) {
    setState(() {
      focusedIndex = index;
    });
  }

  Widget _userOutfits() {
    final user = Provider.of<MyUser>(context);
    return ScrollSnapList(
      onItemFocus: _onItemFocus,
      itemSize: 256,
      itemBuilder: (BuildContext context, int index) {
        return _outfitcard(user.picturePaths[index], percentages[1]);
      },
      itemCount: user.picturePaths.length,
      dynamicItemSize: true,
    );
  }

  Widget _outfitcard(picturePath, double stat) {
    int no = (100 * (1.0 - stat)).round();
    int yes = (100 * stat).round();
    return Column(
      children: <Widget>[
        Ink.image(
          fit: BoxFit.cover,
          height: 220,
          width: 256,
          image: NetworkImage(picturePath),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          'Yes: $yes% / No: $no%',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String text) => MaterialButton(
        padding: const EdgeInsets.all(4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
