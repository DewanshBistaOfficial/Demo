import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const Spacer(
            flex: 2,
          ),
          _settingToggle("A"),
          const Spacer(),
          _settingToggle("B"),
          const Spacer(),
          _settingToggle("C"),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _settingToggle(text) {
    return Container(
      color: Colors.blue,
      child: Row(
        children: [
          const Spacer(
            flex: 2,
          ),
          Text(text),
          const Spacer(),
          Switch(
            value: true,
            onChanged: (value) {
              setState(
                () {
                  false;
                },
              );
            },
          ),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
