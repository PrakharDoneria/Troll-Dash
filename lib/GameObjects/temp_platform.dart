import 'package:flutter/material.dart';

class TempPlatform extends StatefulWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final int disappearDelayMs;
  final VoidCallback? onStep;
  final VoidCallback? onDisappear;

  const TempPlatform({
    super.key,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 20,
    this.disappearDelayMs = 1500,
    this.onStep,
    this.onDisappear,
  });

  @override
  State<TempPlatform> createState() => _TempPlatformState();
}

class _TempPlatformState extends State<TempPlatform>
    with SingleTickerProviderStateMixin {
  bool isVisible = true;
  bool isWarning = false;
  late AnimationController _flashController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  void triggerDisappear() {
    if (!isVisible || isWarning) return;

    setState(() {
      isWarning = true;
    });

    // Start flashing warning
    _flashController.repeat(reverse: true);

    // Trigger onStep callback
    widget.onStep?.call();

    // Disappear after delay
    Future.delayed(Duration(milliseconds: widget.disappearDelayMs), () {
      if (mounted) {
        setState(() {
          isVisible = false;
          isWarning = false;
        });
        _flashController.stop();
        widget.onDisappear?.call();

        // Reappear after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              isVisible = true;
              isWarning = false;
            });
            _flashController.reset();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      left: widget.x,
      bottom: widget.y,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: isWarning ? _opacityAnimation.value : 1.0,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isWarning 
                      ? [Colors.red.shade600, Colors.red.shade400]
                      : [Colors.yellow.shade600, Colors.yellow.shade400],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isWarning ? Colors.red.shade800 : Colors.yellow.shade800, 
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isWarning ? Colors.red : Colors.yellow).withOpacity(0.3),
                    blurRadius: isWarning ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isWarning ? Icons.warning : Icons.timer,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Check if platform is currently solid (visible and not in warning state that would cause falling)
  bool isSolid() {
    return isVisible;
  }
}