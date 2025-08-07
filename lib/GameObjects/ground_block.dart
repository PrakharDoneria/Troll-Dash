import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const GroundGameApp());
}

class GroundGameApp extends StatelessWidget {
  const GroundGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ground Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _gameController;
  late Timer _gameTimer;

  // Player properties
  double playerX = 50;
  double playerY = 100;
  double playerVelocityX = 0;
  double playerVelocityY = 0;
  bool isOnGround = false;
  bool isJumping = false;

  // Game properties
  static const double gravity = 800;
  static const double jumpSpeed = 400;
  static const double moveSpeed = 200;
  static const double playerSize = 30;

  // Input handling
  Set<LogicalKeyboardKey> pressedKeys = {};

  // Ground blocks
  List<GroundBlock> groundBlocks = [
    GroundBlock(x: 0, y: 0, width: 200, height: 30),
    GroundBlock(x: 250, y: 50, width: 150, height: 30),
    GroundBlock(x: 450, y: 100, width: 200, height: 30),
    GroundBlock(x: 200, y: 150, width: 100, height: 30),
    GroundBlock(x: 350, y: 200, width: 150, height: 30),
    GroundBlock(x: 550, y: 250, width: 200, height: 30),
    GroundBlock(x: 100, y: 300, width: 120, height: 30),
    GroundBlock(x: 400, y: 350, width: 180, height: 30),
  ];

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    );

    startGameLoop();
  }

  void startGameLoop() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (!mounted) return;

    setState(() {
      // Handle input
      handleInput();

      // Update physics
      updatePhysics();

      // Check collisions
      checkCollisions();
    });
  }

  void handleInput() {
    // Reset horizontal velocity
    playerVelocityX = 0;

    if (pressedKeys.contains(LogicalKeyboardKey.arrowLeft) ||
        pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      playerVelocityX = -moveSpeed;
    }

    if (pressedKeys.contains(LogicalKeyboardKey.arrowRight) ||
        pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      playerVelocityX = moveSpeed;
    }

    if ((pressedKeys.contains(LogicalKeyboardKey.space) ||
        pressedKeys.contains(LogicalKeyboardKey.arrowUp) ||
        pressedKeys.contains(LogicalKeyboardKey.keyW)) &&
        isOnGround && !isJumping) {
      playerVelocityY = jumpSpeed;
      isOnGround = false;
      isJumping = true;
    }
  }

  void updatePhysics() {
    const double deltaTime = 0.016; // 60 FPS

    // Apply gravity
    if (!isOnGround) {
      playerVelocityY -= gravity * deltaTime;
    }

    // Update position
    playerX += playerVelocityX * deltaTime;
    playerY += playerVelocityY * deltaTime;

    // Keep player within screen bounds (horizontal)
    playerX = playerX.clamp(0, MediaQuery.of(context).size.width - playerSize);

    // Reset jumping flag when falling
    if (playerVelocityY < 0) {
      isJumping = false;
    }

    // Ground boundary (bottom of screen)
    if (playerY < 0) {
      playerY = 0;
      playerVelocityY = 0;
      isOnGround = true;
    }
  }

  void checkCollisions() {
    bool wasOnGround = isOnGround;
    isOnGround = false;

    for (GroundBlock block in groundBlocks) {
      // Check if player is colliding with this block
      if (playerX < block.x + block.width &&
          playerX + playerSize > block.x &&
          playerY < block.y + block.height &&
          playerY + playerSize > block.y) {

        // Landing on top of block
        if (playerVelocityY <= 0 && playerY + playerSize <= block.y + block.height / 2) {
          playerY = block.y + block.height;
          playerVelocityY = 0;
          isOnGround = true;
          isJumping = false;
        }
        // Hitting block from below
        else if (playerVelocityY > 0 && playerY >= block.y + block.height / 2) {
          playerY = block.y - playerSize;
          playerVelocityY = 0;
        }
        // Side collisions
        else {
          if (playerX + playerSize / 2 < block.x + block.width / 2) {
            playerX = block.x - playerSize;
          } else {
            playerX = block.x + block.width;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            pressedKeys.add(event.logicalKey);
          } else if (event is KeyUpEvent) {
            pressedKeys.remove(event.logicalKey);
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // Background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.lightBlue.shade200,
                    Colors.lightBlue.shade50,
                  ],
                ),
              ),
            ),

            // Ground blocks
            ...groundBlocks,

            // Player
            Player(
              x: playerX,
              y: playerY,
              size: playerSize,
              isOnGround: isOnGround,
            ),

            // Instructions
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Controls:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Arrow Keys / WASD - Move',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Space / Up Arrow / W - Jump',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Score/Info
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Position: (${playerX.toInt()}, ${playerY.toInt()})',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'On Ground: ${isOnGround ? "Yes" : "No"}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameController.dispose();
    _gameTimer.cancel();
    super.dispose();
  }
}

class GroundBlock extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;

  const GroundBlock({
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      bottom: y,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade400,
              Colors.green.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(4),
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
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class Player extends StatelessWidget {
  final double x;
  final double y;
  final double size;
  final bool isOnGround;

  const Player({
    required this.x,
    required this.y,
    required this.size,
    required this.isOnGround,
    super.key,
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
          gradient: RadialGradient(
            colors: [
              isOnGround ? Colors.blue.shade300 : Colors.red.shade300,
              isOnGround ? Colors.blue.shade700 : Colors.red.shade700,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}