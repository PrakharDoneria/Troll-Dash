import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trolldash/GameObjects/ground_block.dart';
import 'package:trolldash/GameObjects/trap.dart';
import 'package:trolldash/GameObjects/exit_door.dart';
import 'package:trolldash/GameObjects/player.dart' as player_file;

class Level1 extends StatefulWidget {
  const Level1({super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> with WidgetsBindingObserver {
  double playerX = 100;
  double playerY = 100;
  double velocityX = 0;
  double velocityY = 0;
  bool isOnGround = false;
  bool gameOver = false;

  final double gravity = 20;
  final double moveSpeed = 5;
  final double jumpSpeed = -12;

  final List<LogicalKeyboardKey> keysPressed = [];

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent && !keysPressed.contains(event.logicalKey)) {
      keysPressed.add(event.logicalKey);
    } else if (event is RawKeyUpEvent) {
      keysPressed.remove(event.logicalKey);
    }
  }

  void resetLevel() {
    setState(() {
      playerX = 100;
      playerY = 100;
      velocityX = 0;
      velocityY = 0;
      isOnGround = false;
      gameOver = false;
    });
  }

  void gameLoop() {
    if (gameOver) return;

    setState(() {
      velocityX = 0;

      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        velocityX = -moveSpeed;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        velocityX = moveSpeed;
      }

      if (keysPressed.contains(LogicalKeyboardKey.space) && isOnGround) {
        velocityY = jumpSpeed;
        isOnGround = false;
      }

      velocityY += gravity * 0.05;
      playerX += velocityX;
      playerY += velocityY;

      if (playerY > MediaQuery.of(context).size.height) {
        gameOver = true;
      }

      // Ground collision
      if (playerY <= 50) {
        playerY = 50;
        velocityY = 0;
        isOnGround = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    RawKeyboard.instance.addListener(_onKey);
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      gameLoop();
      return mounted;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RawKeyboard.instance.removeListener(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sky background
          Container(color: Colors.blue.shade100),

          // Ground
          Positioned.fill(
            bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                color: Colors.green,
              ),
            ),
          ),

          // Ground blocks
          const GroundBlock(x: 200, y: 50, width: 100, height: 20),
          const GroundBlock(x: 350, y: 100, width: 100, height: 20),

          // Traps
          Trap(
            x: 280,
            y: 50,
            width: 30,
            height: 30,
            onTrigger: () {
              setState(() => gameOver = true);
            },
          ),
          Trap(
            x: 400,
            y: 100,
            width: 30,
            height: 30,
            onTrigger: () {
              setState(() => gameOver = true);
            },
          ),

          // Exit door
          ExitDoor(
            x: 500,
            y: 50,
            width: 40,
            height: 60,
            onEnter: () {
              debugPrint("Level Complete!");
            },
          ),

          // Player
          player_file.Player(
            x: playerX,
            y: playerY,
            size: 30,
            isOnGround: isOnGround,
          ),

          // Game Over text
          if (gameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.7),
                child: const Text(
                  'Game Over',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
