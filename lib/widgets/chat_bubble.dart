import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String resultText;
  final bool isDefaultBubbleStyle;
  final bool isCorrectAnswer;
  final double adaptiveFontSize;

  const ChatBubble({
    super.key,
    required this.resultText,
    required this.isDefaultBubbleStyle,
    required this.isCorrectAnswer,
    required this.adaptiveFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isDefaultBubbleStyle
        ? const Color.fromARGB(255, 194, 194, 194)
        : isCorrectAnswer
            ? const Color.fromARGB(255, 144, 226, 151)
            : const Color.fromARGB(255, 255, 104, 137);

    final Color backgroundColor = isDefaultBubbleStyle
        ? const Color.fromARGB(255, 255, 255, 255)
        : isCorrectAnswer
            ? const Color.fromARGB(255, 239, 255, 239)
            : const Color.fromARGB(255, 255, 237, 239);

    final Color textColor = Colors.black87;

    final TextStyle textStyle =
        TextStyle(color: textColor, fontSize: adaptiveFontSize);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 3.0,
            ),
          ),
          child: Center(
            child: resultText.isEmpty
                ? Text(
                    "Bonjour, je suis QT, votre assistant mathématique !",
                    style: textStyle,
                  )
                : Text(
                    resultText,
                    style: textStyle,
                  ),
          ),
        ),
      ),
    );
  }
}