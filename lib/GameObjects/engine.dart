import 'package:flutter/scheduler.dart';

class GameEngine {
  double playerX = 50;
  double playerY;
  double velocityY = 0;
  double gravity = -0.8;
  double jumpForce = 12;
  double moveSpeed = 3;
  double groundY;

  bool isJumping = false;
  bool isMovingLeft = false;
  bool isMovingRight = false;

  late final Ticker _ticker;
  final void Function(double x, double y) onUpdate;

  GameEngine({
    required this.onUpdate,
    this.groundY = 50,
    double initialY = 160,
  }) : playerY = initialY {
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration _) {
    velocityY += gravity;
    playerY += velocityY;

    if (playerY <= groundY) {
      playerY = groundY;
      velocityY = 0;
      isJumping = false;
    }

    if (isMovingLeft) {
      playerX -= moveSpeed;
    } else if (isMovingRight) {
      playerX += moveSpeed;
    }

    onUpdate(playerX, playerY);
  }

  void jump() {
    if (!isJumping) {
      velocityY = jumpForce;
      isJumping = true;
    }
  }

  void startMoveLeft() => isMovingLeft = true;
  void startMoveRight() => isMovingRight = true;
  void stopMove() {
    isMovingLeft = false;
    isMovingRight = false;
  }

  void dispose() {
    _ticker.dispose();
  }

  void stop() {
    _ticker.stop();
  }

}
