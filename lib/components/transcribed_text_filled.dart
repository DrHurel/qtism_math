import 'package:flutter/material.dart';

class TranscribedTextFilled extends StatelessWidget {
  const TranscribedTextFilled({
    super.key,
    required String transcribedText,
    required this.textFieldFontSize,
  }) : _transcribedText = transcribedText;

  final String _transcribedText;
  final double textFieldFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      color: Colors.white.withValues(alpha: 0.9),
      child: Text(
        _transcribedText,
        style: TextStyle(
          color: Colors.grey[700],
          fontStyle: FontStyle.italic,
          fontSize: textFieldFontSize * 0.9,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
