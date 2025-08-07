import 'package:flutter/material.dart';

class Trap extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final VoidCallback onTrigger;

  const Trap({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.onTrigger,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      bottom: y,
      child: GestureDetector(
        onTap: onTrigger,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
