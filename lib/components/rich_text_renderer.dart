import 'package:flutter/material.dart';

class RichTextRenderer extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const RichTextRenderer({
    super.key,
    required this.text,
    required this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildTextSpan(text, baseStyle),
    );
  }

  TextSpan _buildTextSpan(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];

    RegExp exp = RegExp(r'\*\*(.*?)\*\*');

    int lastIndex = 0;

    for (Match match in exp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
