import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qtism_math/services/speech_text.dart';

class TypingEffect extends StatefulWidget {
  final String text;
  final TextStyle baseStyle;
  final VoidCallback onComplete;

  const TypingEffect({
    Key? key,
    required this.text,
    required this.baseStyle,
    required this.onComplete,
  }) : super(key: key);

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

class RichTextRenderer extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const RichTextRenderer({
    Key? key,
    required this.text,
    required this.baseStyle,
  }) : super(key: key);

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

class QT extends StatefulWidget {
  const QT({super.key});

  @override
  State<QT> createState() => _QTState();
}

class _QTState extends State<QT> with SingleTickerProviderStateMixin {
  String _transcribedText = "";
  String _resultText = "";
  bool _isListening = false;
  bool _isTyping = false;
  String _currentEmotion = "neutral";
  String _previousEmotion = "neutral";
  bool get _isDesktop => MediaQuery.of(context).size.width >= 600;
  final TextEditingController _textController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _isTransitioning = false;
  bool _isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _clearTranscription() {
    setState(() {
      _transcribedText = "";
    });
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    setState(() {
      _transcribedText = text;
    });

    _textController.clear();

    String mathExpression = SpeechText.convertToMathExpression(text);
    String result = SpeechText.evaluateMathExpression(mathExpression);

    // Speak the result
    SpeechText.speakResult(result);

    _showResult(result);
  }

  void _showResult(String result) {
    String newEmotion = "neutral";
    bool isCorrect = false;

    if (result.startsWith("Oui, bonne réponse")) {
      newEmotion = "enjoy";
      isCorrect = true;
    } else if (result.startsWith("Non")) {
      newEmotion = "sad";
      isCorrect = false;
    } else {
      newEmotion = "happy";
      isCorrect = true;
    }

    if (newEmotion != _currentEmotion && _currentEmotion != "neutral") {
      setState(() {
        _previousEmotion = _currentEmotion;
        _currentEmotion = newEmotion;
        _isTransitioning = true;
        _isTyping = true;
        _resultText = result;
        _isCorrectAnswer = isCorrect;
      });

      _animationController.reset();
      _animationController.forward();
    } else {
      setState(() {
        _currentEmotion = newEmotion;
        _isTyping = true;
        _resultText = result;
        _isCorrectAnswer = isCorrect;
      });
    }
  }

  void _handleVoiceInput() async {
    if (_currentEmotion != "neutral") {
      setState(() {
        _previousEmotion = _currentEmotion;
        _currentEmotion = "neutral";
        _isTransitioning = true;
      });

      _animationController.reset();
      _animationController.forward();
    } else {
      setState(() {
        _currentEmotion = "neutral";
      });
    }

    await SpeechText.toggleRecording(
      (transcription) {
        setState(() {
          _transcribedText = transcription;
        });
      },
      (expression, result) {
        _showResult(result);
      },
      () {
        _clearTranscription();
      },
      (value) {
        setState(() {
          _isListening = value;
        });
      },
    );
  }

  double _getAdaptiveFontSize(BuildContext context,
      {double baseFontSize = 21.0, double minFontSize = 12.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final smallestDimension =
        screenWidth < screenHeight ? screenWidth : screenHeight;

    const referenceSize = 600.0;

    final fontSizeRatio = (smallestDimension / referenceSize).clamp(0.0, 1.0);

    final fontSize = baseFontSize * fontSizeRatio;

    return fontSize < minFontSize ? minFontSize : fontSize;
  }

  Widget _buildRobotWithEmotions(
      BuildContext context, BoxConstraints constraints) {
    final robotHeight =
        _isDesktop ? constraints.maxHeight * 0.8 : constraints.maxHeight * 0.7;
    final emotionWidth = robotHeight * 0.275;
    final emotionHeight = robotHeight * 0.1425;

    final emotionTop = constraints.maxHeight / 2 - robotHeight * 0.39;
    final emotionRight = _isDesktop
        ? constraints.maxWidth / 2 - robotHeight * 0.105
        : constraints.maxWidth / 2 - robotHeight * 0.105;

    return SizedBox(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/qt.png',
                  height: robotHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          if (_isTransitioning && _previousEmotion != "neutral")
            Positioned(
              top: emotionTop,
              right: emotionRight,
              width: emotionWidth,
              height: emotionHeight,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1 - _opacityAnimation.value,
                    child: child,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/$_previousEmotion.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          if (_currentEmotion != "neutral")
            Positioned(
              top: emotionTop,
              right: emotionRight,
              width: emotionWidth,
              height: emotionHeight,
              child: _isTransitioning
                  ? AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: child,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/$_currentEmotion.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/$_currentEmotion.png',
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final adaptiveFontSize = _getAdaptiveFontSize(context);

    final Color borderColor = _resultText.isEmpty
        ? const Color.fromARGB(255, 194, 194, 194)
        : _isCorrectAnswer
            ? const Color.fromARGB(255, 144, 226, 151)
            : const Color.fromARGB(255, 255, 104, 137);

    final Color backgroundColor = _resultText.isEmpty
        ? const Color.fromARGB(255, 255, 255, 255)
        : _isCorrectAnswer
            ? const Color.fromARGB(255, 239, 255, 239)
            : const Color.fromARGB(255, 255, 237, 239);

    final Color textColor =
        _resultText.isEmpty ? Colors.black87 : Colors.black87;

    final TextStyle textStyle =
        TextStyle(color: textColor, fontSize: adaptiveFontSize);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: _isDesktop ? screenHeight * 0.3 : screenHeight * 0.2,
            maxWidth: _isDesktop ? 550 : double.infinity,
          ),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor,
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Center(
              child: _resultText.isEmpty
                  ? Text(
                      "Bonjour, je suis QT, votre assistant mathématique !",
                      style: textStyle,
                    )
                  : TypingEffect(
                      text: _resultText,
                      baseStyle: textStyle,
                      onComplete: () {
                        setState(() {
                          _isTyping = false;
                        });
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textFieldFontSize =
        _getAdaptiveFontSize(context, baseFontSize: 15.0, minFontSize: 10.0);
    final hintTextSize =
        _getAdaptiveFontSize(context, baseFontSize: 13.0, minFontSize: 9.0);

    return Scaffold(
      backgroundColor: const Color(0xFFABC1F9),
      body: Column(
        children: [
          Expanded(
            child: _isDesktop
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildRobotWithEmotions(
                                    context, constraints);
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildChatBubble(context),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return _buildRobotWithEmotions(
                                    context, constraints);
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: _buildChatBubble(context),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_transcribedText.isNotEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              color: Colors.white.withOpacity(0.9),
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
            ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  FloatingActionButton(
                    onPressed: _handleVoiceInput,
                    backgroundColor:
                        _isListening ? Colors.red : const Color(0xFF7386B6),
                    shape: const CircleBorder(),
                    child: Icon(_isListening ? Icons.stop : Icons.mic,
                        color: Colors.white),
                    mini: !_isDesktop,
                    heroTag: 'mic_button',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(fontSize: textFieldFontSize),
                        decoration: InputDecoration(
                          hintText: 'Saisissez une opération ou équation...',
                          hintStyle: TextStyle(fontSize: hintTextSize),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _handleSubmitted(_textController.text),
                    backgroundColor: const Color(0xFF0D9488),
                    shape: const CircleBorder(),
                    child: const Icon(Icons.send, color: Colors.white),
                    mini: !_isDesktop,
                    heroTag: 'send_button',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
