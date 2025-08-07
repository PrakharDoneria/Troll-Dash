import 'package:flutter/material.dart';

class Player extends StatelessWidget {
  final double x;
  final double y;
  final double size;
  final bool isOnGround;

  const Player({
    super.key,
    required this.x,
    required this.y,
    this.size = 30,
    this.isOnGround = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      bottom: y,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOnGround ? Colors.orange : Colors.amber,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
