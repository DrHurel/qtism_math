import 'package:flutter/material.dart';
import 'dart:async';

class TypingEffect extends StatefulWidget {
  final String text;
  final TextStyle baseStyle;
  final VoidCallback? onComplete;
  final Duration typingDelay;

  const TypingEffect({
    Key? key,
    required this.text,
    required this.baseStyle,
    this.onComplete,
    this.typingDelay = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  _TypingEffectState createState() => _TypingEffectState();
}

class _TypingEffectState extends State<TypingEffect> {
  String _displayedText = '';
  late Timer _typingTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.typingDelay, (timer) {
      if (_displayedText.length < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_displayedText.length];
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _typingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.baseStyle,
      textAlign: TextAlign.center,
    );
  }
}
