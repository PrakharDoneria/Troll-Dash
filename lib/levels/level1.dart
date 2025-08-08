import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trolldash/GameObjects/ground_block.dart';
import 'package:trolldash/GameObjects/trap.dart';
import 'package:trolldash/GameObjects/exit_door.dart';
import 'package:trolldash/GameObjects/player.dart' as player_file;
import 'package:trolldash/sound_manager.dart';

class Level1 extends StatefulWidget {
  const Level1({super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> with WidgetsBindingObserver {
  double playerX = 50;
  double playerY = 50; // Start on ground level
  double velocityX = 0;
  double velocityY = 0;
  bool isOnGround = false;
  bool gameOver = false;
  bool levelComplete = false;

  final double gravity = -15;
  final double moveSpeed = 5;
  final double jumpSpeed = 12;
  final double playerSize = 30;

  Set<LogicalKeyboardKey> keysPressed = {};
  final SoundManager _soundManager = SoundManager();

  // Define platform positions for collision detection
  List<Map<String, double>> platforms = [
    {'x': 0, 'y': 0, 'width': double.infinity, 'height': 50}, // Ground
    {'x': 200, 'y': 50, 'width': 100, 'height': 20}, // Platform 1
    {'x': 350, 'y': 100, 'width': 100, 'height': 20}, // Platform 2
  ];

  void resetLevel() {
    setState(() {
      playerX = 50;
      playerY = 50; // Start on ground level
      velocityX = 0;
      velocityY = 0;
      isOnGround = false;
      gameOver = false;
      levelComplete = false;
    });
  }

  void checkCollisions() {
    bool wasOnGround = isOnGround;
    isOnGround = false;

    for (var platform in platforms) {
      // Check collision with platform
      if (playerX + playerSize > platform['x']! &&
          playerX < platform['x']! + platform['width']! &&
          playerY <= platform['y']! + platform['height']! &&
          playerY + playerSize > platform['y']!) {
        
        // Landing on top of platform
        if (velocityY <= 0 && playerY > platform['y']! + platform['height']! - 5) {
          playerY = platform['y']! + platform['height']!;
          velocityY = 0;
          isOnGround = true;
        }
      }
    }

    // Check trap collisions (approximately)
    if ((playerX < 310 && playerX > 250 && playerY <= 70) ||
        (playerX < 450 && playerX > 370 && playerY <= 120)) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Check exit door collision
    if (playerX > 480 && playerX < 540 && playerY <= 110 && playerY > 50) {
      _soundManager.playLevelCompleteSound();
      levelComplete = true;
    }

    // Fall off screen
    if (playerY < -100) {
      gameOver = true;
    }
  }

  void gameLoop() {
    if (gameOver || levelComplete) return;

    setState(() {
      velocityX = 0;

      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || 
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        velocityX = -moveSpeed;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || 
                 keysPressed.contains(LogicalKeyboardKey.keyD)) {
        velocityX = moveSpeed;
      }

      if ((keysPressed.contains(LogicalKeyboardKey.space) ||
           keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
           keysPressed.contains(LogicalKeyboardKey.keyW)) && isOnGround) {
        _soundManager.playJumpSound();
        velocityY = jumpSpeed;
        isOnGround = false;
      }

      // Apply physics
      velocityY += gravity * 0.05;
      playerX += velocityX;
      playerY += velocityY;

      // Keep player in bounds horizontally
      if (playerX < 0) playerX = 0;
      if (playerX > MediaQuery.of(context).size.width - playerSize) {
        playerX = MediaQuery.of(context).size.width - playerSize;
      }

      // Check collisions
      checkCollisions();
    });
  }

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addObserver(this);
    _soundManager.playBackgroundMusic();
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 16));
      gameLoop();
      return mounted;
    });
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    _soundManager.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            keysPressed.add(event.logicalKey);
          } else if (event is KeyUpEvent) {
            keysPressed.remove(event.logicalKey);
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // Sky background
            Container(
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

            // Ground
            Positioned.fill(
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 50,
                  color: Colors.green.shade600,
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
                setState(() => levelComplete = true);
              },
            ),

            // Player
            player_file.Player(
              x: playerX,
              y: playerY,
              size: playerSize,
              isOnGround: isOnGround,
            ),

            // Controls instruction
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
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Arrow Keys / WASD - Move',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      'Space / W / Up - Jump',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  minimumSize: const Size(60, 36),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 12)),
              ),
            ),

            // On-screen touch controls for mobile
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  // Left arrow button
                  GestureDetector(
                    onTapDown: (_) {
                      keysPressed.add(LogicalKeyboardKey.arrowLeft);
                    },
                    onTapUp: (_) {
                      keysPressed.remove(LogicalKeyboardKey.arrowLeft);
                    },
                    onTapCancel: () {
                      keysPressed.remove(LogicalKeyboardKey.arrowLeft);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Icon(
                        Icons.arrow_left,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Right arrow button  
                  GestureDetector(
                    onTapDown: (_) {
                      keysPressed.add(LogicalKeyboardKey.arrowRight);
                    },
                    onTapUp: (_) {
                      keysPressed.remove(LogicalKeyboardKey.arrowRight);
                    },
                    onTapCancel: () {
                      keysPressed.remove(LogicalKeyboardKey.arrowRight);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Jump button
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTapDown: (_) {
                  keysPressed.add(LogicalKeyboardKey.space);
                },
                onTapUp: (_) {
                  keysPressed.remove(LogicalKeyboardKey.space);
                },
                onTapCancel: () {
                  keysPressed.remove(LogicalKeyboardKey.space);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Center(
                    child: Text(
                      'JUMP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Game Over overlay
            if (gameOver)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: resetLevel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                            ),
                            child: const Text('Restart Level'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                            ),
                            child: const Text('Main Menu'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Level Complete overlay
            if (levelComplete)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🎉 Level Complete! 🎉',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: resetLevel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                            ),
                            child: const Text('Play Again'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                            ),
                            child: const Text('Main Menu'),
                          ),
                        ],
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
}
