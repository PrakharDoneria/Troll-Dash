import 'package:flutter/material.dart';

class FakePlatform extends StatefulWidget {
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
  State<FakePlatform> createState() => _FakePlatformState();
}

class _FakePlatformState extends State<FakePlatform>
    with SingleTickerProviderStateMixin {
  late AnimationController _flickerController;
  late Animation<double> _flickerAnimation;
  bool _isTriggered = false;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _flickerAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flickerController,
      curve: Curves.easeInOut,
    ));
    
    // Make it flicker to hint it's fake
    _flickerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  void _triggerTrap() {
    if (!_isTriggered) {
      setState(() => _isTriggered = true);
      _flickerController.stop();
      widget.onStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x,
      bottom: widget.y,
      child: GestureDetector(
        onTap: _triggerTrap,
        child: AnimatedBuilder(
          animation: _flickerAnimation,
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade400.withOpacity(_flickerAnimation.value * 0.7),
                    Colors.green.shade700.withOpacity(_flickerAnimation.value * 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green.shade300.withOpacity(_flickerAnimation.value * 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Center(
                  child: Text(
                    '?',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
