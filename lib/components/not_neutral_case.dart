import 'package:flutter/material.dart';

class not_neutral_case extends StatelessWidget {
  const not_neutral_case({
    super.key,
    required this.emotionTop,
    required this.emotionRight,
    required this.emotionWidth,
    required this.emotionHeight,
    required AnimationController animationController,
    required Animation<double> opacityAnimation,
    required String previousEmotion,
  }) : _animationController = animationController, _opacityAnimation = opacityAnimation, _previousEmotion = previousEmotion;

  final double emotionTop;
  final double emotionRight;
  final double emotionWidth;
  final double emotionHeight;
  final AnimationController _animationController;
  final Animation<double> _opacityAnimation;
  final String _previousEmotion;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}
