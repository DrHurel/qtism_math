import 'package:flutter/material.dart';
import 'package:qtism_math/pages/home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'firebase_options.dart';


void main() async {

await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,
    
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    final model =
      FirebaseVertexAI.instance.generativeModel(model: 'gemini-2.0-flash');

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
