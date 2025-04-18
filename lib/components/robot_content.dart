import 'package:flutter/material.dart';

class RobotContent extends StatelessWidget {
  const RobotContent({
    super.key,
    required this.fontSize,
    required this.isNarrowScreen,
    required this.constraints,
  });

  final double fontSize;
  final bool isNarrowScreen;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 5),
        Text(
          "Bienvenue",
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Amusez-vous avec QT, le robot calculateur !",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize * 0.6,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 30),
        Image.asset(
          'assets/homeQT.png',
          height: isNarrowScreen
              ? constraints.maxHeight * 0.3
              : constraints.maxHeight * 0.5,
        ),
      ],
    );
  }
}
