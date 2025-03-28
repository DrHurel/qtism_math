import 'package:flutter/material.dart';
import 'package:qtism_math/pages/home.dart';
import 'package:qtism_math/pages/qt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QTism Math',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFABC1F9),
      ),
      home: QTRobotHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
