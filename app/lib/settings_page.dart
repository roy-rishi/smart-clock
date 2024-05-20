import 'package:flutter/material.dart';

import 'alarms_page.dart';

class NavButton extends StatelessWidget {
  const NavButton({super.key, required this.name, required this.nextPage});
  final String name;
  final Widget nextPage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card.filled(
          color: Theme.of(context).colorScheme.primaryContainer,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            splashColor: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name),
              ],
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => nextPage));
            },
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clock Settings")),
      body: const Column(
        children: [ 
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 10),
            child: Text("Update your clock's settings"),
          ),
          NavButton(name: "Alarms", nextPage: AlarmsPage()),
          NavButton(name: "Routines", nextPage: Placeholder()),
        ],
      ),
    );
  }
}
