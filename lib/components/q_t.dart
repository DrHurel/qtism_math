
import 'package:flutter/material.dart';
import 'package:qtism_math/components/neutral_case.dart';
import 'package:qtism_math/components/not_neutral_case.dart';
import 'package:qtism_math/components/transcribed_text_filled.dart';
import 'package:qtism_math/controllers/qt_controller.dart';
import 'package:qtism_math/components/chat_bubble.dart';

class QT extends StatefulWidget {
  const QT({super.key});

  @override
  State<QT> createState() => _QTState();
}

class _QTState extends State<QT> with SingleTickerProviderStateMixin {
  bool get _isDesktop => MediaQuery.of(context).size.width >= 600;
  final TextEditingController _textController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late QTController _controller;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _controller = QTController(setState);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _controller.isTransitioning = false;
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
          if (_controller.isTransitioning && _controller.previousEmotion != "neutral")
            not_neutral_case(
                emotionTop: emotionTop,
                emotionRight: emotionRight,
                emotionWidth: emotionWidth,
                emotionHeight: emotionHeight,
                animationController: _animationController,
                opacityAnimation: _opacityAnimation,
                previousEmotion: _controller.previousEmotion),
          if (_controller.currentEmotion != "neutral")
            neutral_case(
                emotionTop: emotionTop,
                emotionRight: emotionRight,
                emotionWidth: emotionWidth,
                emotionHeight: emotionHeight,
                isTransitioning: _controller.isTransitioning,
                animationController: _animationController,
                opacityAnimation: _opacityAnimation,
                currentEmotion: _controller.currentEmotion),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context) {
    final adaptiveFontSize = _getAdaptiveFontSize(context);

    return ChatBubble(
      resultText: _controller.resultText,
      isDefaultBubbleStyle: _controller.isDefaultBubbleStyle,
      isCorrectAnswer: _controller.isCorrectAnswer,
      adaptiveFontSize: adaptiveFontSize,
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
          if (_controller.transcribedText.isNotEmpty)
            TranscribedTextFilled(
                transcribedText: _controller.transcribedText, 
                textFieldFontSize: textFieldFontSize),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _controller.generateCalculationProblem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7386B6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Question de calcul'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _controller.generateTrueOrFalseProblem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Vrai ou faux'),
                  ),
                ),
              ],
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
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  FloatingActionButton(
                    onPressed: () => _controller.handleVoiceInput(_animationController),
                    backgroundColor:
                        _controller.isListening ? Colors.red : const Color(0xFF7386B6),
                    shape: const CircleBorder(),
                    mini: !_isDesktop,
                    heroTag: 'mic_button',
                    child: Icon(_controller.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white),
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
                        onSubmitted: (text) => _controller.handleSubmitted(text, _animationController),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: () => _controller.handleSubmitted(_textController.text, _animationController),
                    backgroundColor: const Color(0xFF0D9488),
                    shape: const CircleBorder(),
                    mini: !_isDesktop,
                    heroTag: 'send_button',
                    child: const Icon(Icons.send, color: Colors.white),
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
