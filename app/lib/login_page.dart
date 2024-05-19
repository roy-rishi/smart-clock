import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import 'settings_page.dart';
import 'credentials.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passController = TextEditingController();

  Future<bool> verifyCredentials() async {
    final response = await http.post(Uri.parse("$SERVER_URL/verify"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader:
              "Bearer ${base64Encode(utf8.encode(PASSWORD))}",
        });
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text("Invalid Credentials"))));
      return false;
    }
    throw Exception(response.body);
  }

  void onLoginSubmit() async {
    PASSWORD = _passController.text.trim();
    bool isValid = await verifyCredentials();
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var titleStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 100,
        );
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text("Clock", style: titleStyle, textAlign: TextAlign.center,)),
              Column(
                children: [
                  SizedBox(
                    width: 330,
                    child: TextField(
                      controller: _passController,
                      style: Theme.of(context).textTheme.bodyMedium,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
                      onSubmitted: (value) {
                        onLoginSubmit();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: OutlinedButton(
                      child: const Text("Continue"),
                      onPressed: () async {
                          onLoginSubmit();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
