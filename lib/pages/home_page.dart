import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qtism_math/services/speech_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _message = "Parlez ici...";
  bool _isListening = false;
  bool _showTextInput = false;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 600;
  final TextEditingController _textController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggleTextInput() {
    setState(() {
      _showTextInput = !_showTextInput;
      if (_showTextInput) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _submitText() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _message = _textController.text;
        _textController.clear();
      });

      if (!_isDesktop) {
        _animationController.reverse().then((_) {
          setState(() {
            _showTextInput = false;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDesktop && !_showTextInput && _animationController.value == 0) {
        setState(() {
          _showTextInput = true;
        });
        _animationController.forward();
      }
    });

    final textFieldWidth = _isDesktop
        ? screenWidth * 0.5
        : (screenWidth * 0.8 > 600 ? 600.0 : screenWidth * 0.8);

    const borderRadius = 16.0;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFABC1F9),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/qt.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if ((_showTextInput || _animationController.value > 0) &&
                !_isDesktop)
              Positioned(
                bottom: screenHeight * 0.05,
                left: (screenWidth - textFieldWidth) / 2,
                child: FadeTransition(
                  opacity: _animation,
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 0.8, end: 1.0).animate(_animation),
                    child: Container(
                      width: textFieldWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _textController,
                            maxLines: 5,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            decoration: InputDecoration(
                              hintText: 'Saisissez votre texte ici...',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                height: 2.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 16,
                              ),
                              alignLabelWithHint: true,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _submitText,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('Valider'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(6.0),
          child: _isDesktop
              ? Container(
                  margin: const EdgeInsets.symmetric(vertical: 45),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      FloatingActionButton(
                        onPressed: () => SpeechText.toggleRecording(
                          (value) => setState(() {
                            _message = value;
                          }),
                          (value) {
                            setState(() {
                              _isListening = value;
                            });
                          },
                        ),
                        backgroundColor:
                            _isListening ? Colors.red : const Color(0xFF7386B6),
                        shape: const CircleBorder(),
                        child: Icon(_isListening ? Icons.stop : Icons.mic,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: TextField(
                                    controller: _textController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                    decoration: InputDecoration(
                                      hintText: 'Saisissez votre texte ici...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        height: 1.2,
                                      ),
                                      border: InputBorder.none,
                                      alignLabelWithHint: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton(
                                  onPressed: _submitText,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Valider'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      onPressed: () => SpeechText.toggleRecording(
                        (value) => setState(() {
                          _message = value;
                        }),
                        (value) {
                          setState(() {
                            _isListening = value;
                          });
                        },
                      ),
                      backgroundColor:
                          _isListening ? Colors.red : const Color(0xFF7386B6),
                      shape: const CircleBorder(),
                      child: Icon(_isListening ? Icons.stop : Icons.mic,
                          color: Colors.white),
                    ),
                    FloatingActionButton(
                      onPressed: _toggleTextInput,
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.chat_bubble, color: Colors.black),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
