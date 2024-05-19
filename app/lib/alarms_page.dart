import 'package:flutter/material.dart';

class AlarmsPage extends StatefulWidget {
  const AlarmsPage({super.key});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alarms")),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Center(child: Text("Add, modify, or delete your clock's alarms")),
          ),
        ],
      ),
    );
  }
}
