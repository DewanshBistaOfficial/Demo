import 'package:flutter/material.dart';

class FlipScreen extends StatefulWidget {
  const FlipScreen({Key? key}) : super(key: key);

  @override
  State<FlipScreen> createState() => _FlipScreenState();
}

class _FlipScreenState extends State<FlipScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flip"),
        automaticallyImplyLeading: false,
      ),
    );
  }
}
