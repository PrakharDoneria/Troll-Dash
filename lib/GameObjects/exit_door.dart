import 'package:flutter/material.dart';

class ExitDoor extends StatefulWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final VoidCallback onEnter;

  const ExitDoor({
    required this.x,
    required this.y,
    required this.onEnter,
    this.width = 50,
    this.height = 80,
    super.key,
  });

  @override
  State<ExitDoor> createState() => _ExitDoorState();
}

class _ExitDoorState extends State<ExitDoor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onEnter();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x,
      bottom: widget.y,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                    if (_isPressed)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B4513), Color(0xFF5D2E0A)],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD2691E), Color(0xFFA0522D)],
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  border: Border.all(
                                    color: const Color(0xFF654321),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  border: Border.all(
                                    color: const Color(0xFF654321),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 35,
                      child: Container(
                        width: 6,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      left: 2,
                      right: 2,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Text(
                            'EXIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      top: 8,
                      child: Container(
                        width: 4,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F4F4F),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      bottom: 8,
                      child: Container(
                        width: 4,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F4F4F),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
