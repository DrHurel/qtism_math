import 'package:flutter/material.dart';
import 'package:qtism_math/components/grid_content.dart';
import 'package:qtism_math/components/robot_content.dart';

void main() {
  runApp(QTRobotApp());
}

class QTRobotApp extends StatelessWidget {
  const QTRobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QTRobotHomePage(),
    );
  }
}

class QTRobotHomePage extends StatelessWidget {
  const QTRobotHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFABC1F9),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isNarrowScreen = constraints.maxWidth < 800;

          double fontSize = constraints.maxWidth * 0.035;

          if (isNarrowScreen) {
            fontSize = constraints.maxWidth * 0.05;
          }

          Widget robotContent_ = RobotContent(fontSize: fontSize, isNarrowScreen: isNarrowScreen, constraints: constraints);

          Widget gridContent_ = GridContent(fontSize: fontSize, isNarrowScreen: isNarrowScreen, constraints: constraints);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: isNarrowScreen
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        robotContent_,
                        SizedBox(height: 40),
                        gridContent_,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: robotContent_),
                        Expanded(flex: 1, child: gridContent_),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
