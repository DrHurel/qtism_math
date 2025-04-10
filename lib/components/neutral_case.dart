import 'package:flutter/material.dart';

class neutral_case extends StatelessWidget {
  const neutral_case({
    super.key,
    required this.emotionTop,
    required this.emotionRight,
    required this.emotionWidth,
    required this.emotionHeight,
    required bool isTransitioning,
    required AnimationController animationController,
    required Animation<double> opacityAnimation,
    required String currentEmotion,
  }) : _isTransitioning = isTransitioning, _animationController = animationController, _opacityAnimation = opacityAnimation, _currentEmotion = currentEmotion;

  final double emotionTop;
  final double emotionRight;
  final double emotionWidth;
  final double emotionHeight;
  final bool _isTransitioning;
  final AnimationController _animationController;
  final Animation<double> _opacityAnimation;
  final String _currentEmotion;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}
