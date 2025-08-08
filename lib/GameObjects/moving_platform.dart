import 'package:flutter/material.dart';

class MovingPlatform extends StatefulWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final double startX;
  final double endX;
  final double speed;
  final VoidCallback? onCollision;

  const MovingPlatform({
    super.key,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 20,
    required this.startX,
    required this.endX,
    this.speed = 2.0,
    this.onCollision,
  });

  @override
  State<MovingPlatform> createState() => _MovingPlatformState();
}

class _MovingPlatformState extends State<MovingPlatform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: ((widget.endX - widget.startX) / widget.speed * 100).round()),
      vsync: this,
    );
    
    _positionAnimation = Tween<double>(
      begin: widget.startX,
      end: widget.endX,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value,
          bottom: widget.y,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade800, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // Get current position for collision detection
  double getCurrentX() {
    return _positionAnimation.value;
  }
}