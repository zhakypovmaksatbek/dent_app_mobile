import 'package:flutter/material.dart';

class AnimatedDigit extends StatefulWidget {
  final int digit;
  final Duration duration;
  final TextStyle textStyle;

  const AnimatedDigit({
    super.key,
    required this.digit,
    this.duration = const Duration(milliseconds: 1000),
    required this.textStyle,
  });

  @override
  State<AnimatedDigit> createState() => _AnimatedDigitState();
}

class _AnimatedDigitState extends State<AnimatedDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = IntTween(begin: 0, end: widget.digit).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedDigit oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.digit != widget.digit) {
      setState(() {
        _animation = IntTween(
          begin: oldWidget.digit,
          end: widget.digit,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(_animation.value.toString(), style: widget.textStyle);
      },
    );
  }
}
