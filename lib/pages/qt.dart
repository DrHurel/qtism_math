import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qtism_math/components/rich_text_renderer.dart';

class TypingEffect extends StatefulWidget {
  final String text;
  final TextStyle baseStyle;
  final VoidCallback onComplete;

  const TypingEffect({
    super.key,
    required this.text,
    required this.baseStyle,
    required this.onComplete,
  });

  @override
  State<TypingEffect> createState() => _TypingEffectState();
}

class _TypingEffectState extends State<TypingEffect> {
  String _displayText = "";
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingEffect();
  }

  @override
  void didUpdateWidget(TypingEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _timer?.cancel();
      _charIndex = 0;
      _displayText = "";
      _startTypingEffect();
    }
  }

  void _startTypingEffect() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        _timer?.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichTextRenderer(
      text: _displayText,
      baseStyle: widget.baseStyle,
    );
  }
}

