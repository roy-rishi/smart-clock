import 'package:app/credentials.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import 'create_alarm_page.dart';

class AlarmCard extends StatelessWidget {
  AlarmCard({super.key, required this.time, required this.routine});
  TimeOfDay time;
  String routine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 335,
      child: Card.outlined(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time.format(context)),
            Text(routine),
          ],
        ),
      ),
    );
  }
}

Future<List<dynamic>> loadAlarms() async {
  final response =
      await http.get(Uri.parse("$SERVER_URL/alarms"), headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    HttpHeaders.authorizationHeader: "Bearer $PASSWORD",
  });

  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  throw Exception(response.body);
}

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
      body: ListView(children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child:
              Center(child: Text("Add, modify, or delete your clock's alarms")),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 95,
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Card.filled(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      splashColor: Theme.of(context).colorScheme.primaryContainer,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                          builder: (context) => const CreateAlarmPage(),
                        ))
                            .then((value) {
                          setState(() {});
                        });
                      },
                      child: Center(
                          child: Text("+",
                              style: Theme.of(context).textTheme.displayMedium))),
                ),
              ),
            ),
          ],
        ),
        FutureBuilder(
            future: loadAlarms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.data == null) {
                throw Exception("No data");
              }

              List<AlarmCard> alarms = [];
              List<dynamic> rows = snapshot.data as List<dynamic>;
              for (int i = 0; i < rows.length; i++) {
                Map<String, dynamic> row = rows[i];
                TimeOfDay time =
                    TimeOfDay(hour: row["Hour"], minute: row["Minute"]);
                alarms.add(AlarmCard(time: time, routine: row["Routine"]));
              }

              return Column(children: [...alarms]);
            }),
      ]),
    );
  }
}
