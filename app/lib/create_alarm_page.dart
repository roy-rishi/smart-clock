import 'package:app/credentials.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class NameTextField extends StatefulWidget {
  NameTextField({super.key});

  final TextEditingController _nameController = TextEditingController();

  @override
  State<NameTextField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 335,
      child: TextField(
        controller: widget._nameController,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(labelText: "Name"),
      ),
    );
  }
}

class RepeatDay extends StatefulWidget {
  RepeatDay({super.key, required this.dayLetter});

  final String dayLetter;
  bool isPressed = false;

  @override
  State<RepeatDay> createState() => _RepeatDayState();
}

class _RepeatDayState extends State<RepeatDay> {
  Color color = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: AspectRatio(
        aspectRatio: 7 / 8,
        child: Card.outlined(
          clipBehavior: Clip.hardEdge,
          color: color,
          child: InkWell(
              onTap: () {
                widget.isPressed = !widget.isPressed;
                setState(() {
                  if (widget.isPressed) {
                    color = Theme.of(context).colorScheme.primaryContainer;
                  } else {
                    color = Colors.transparent;
                  }
                });
              },
              child: Center(child: Text(widget.dayLetter))),
        ),
      ),
    );
  }
}

class TimeSelector extends StatefulWidget {
  TimeSelector({super.key});

  TimeOfDay alarmTime = TimeOfDay.now();
  String buttonText = "Set start time";
  bool selectionMade = false;

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: 335,
      child: Card.filled(
        color: Theme.of(context).colorScheme.secondaryContainer,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              barrierDismissible: false,
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (selectedTime == null) {
              return;
            }
            widget.alarmTime = selectedTime as TimeOfDay;
            setState(() {
              widget.selectionMade = true;
              widget.buttonText = selectedTime.format(context);
            });
          },
          splashColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Center(
            child: Text(widget.buttonText),
          ),
        ),
      ),
    );
  }
}

class CreateAlarmPage extends StatefulWidget {
  const CreateAlarmPage({super.key});

  @override
  State<CreateAlarmPage> createState() => _CreateAlarmPageState();
}

class _CreateAlarmPageState extends State<CreateAlarmPage> {
  TimeSelector timeSelector = TimeSelector();
  List<RepeatDay> repeatDays = [
    RepeatDay(dayLetter: "S"),
    RepeatDay(dayLetter: "M"),
    RepeatDay(dayLetter: "T"),
    RepeatDay(dayLetter: "W"),
    RepeatDay(dayLetter: "T"),
    RepeatDay(dayLetter: "F"),
    RepeatDay(dayLetter: "S")
  ];
  NameTextField nameField = NameTextField();

  Future<bool> postAlarm() async {
    final response = await http.post(
      Uri.parse("$SERVER_URL/add-alarm"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $PASSWORD",
      },
      body: jsonEncode(<String, dynamic>{
        "hour": timeSelector.alarmTime.hour,
        "minute": timeSelector.alarmTime.minute,
        "routine": "standard",
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Configure Alarm"), toolbarHeight: 100),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 4),
                    child: Text("Start time"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      timeSelector,
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25, bottom: 4),
                    child: Text("Repeat days"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [...repeatDays],
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 25, bottom: 4),
                  //   child: Text("Routine"),
                  // ),

                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: nameField,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 70, top: 20),
              child: FilledButton(
                onPressed: () async {
                  if (!timeSelector.selectionMade ||
                      nameField._nameController.text.trim() == "") {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Center(
                            child: Text("Complete all required fields"))));
                  } else {
                    await postAlarm();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ));
  }
}
