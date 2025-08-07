import 'package:flutter/material.dart';

class FakePlatform extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final VoidCallback onStep;

  const FakePlatform({
    required this.x,
    required this.y,
    required this.onStep,
    this.width = 100,
    this.height = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      bottom: y,
      child: GestureDetector(
        onTap: onStep,
        child: Container(
          width: width,
          height: height,
          color: Colors.grey.withOpacity(0.4),
        ),
      ),
    );
  }
}
