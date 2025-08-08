import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trolldash/GameObjects/ground_block.dart';
import 'package:trolldash/GameObjects/trap.dart';
import 'package:trolldash/GameObjects/exit_door.dart';
import 'package:trolldash/GameObjects/moving_platform.dart';
import 'package:trolldash/GameObjects/player.dart' as player_file;
import 'package:trolldash/sound_manager.dart';

class Level3 extends StatefulWidget {
  const Level3({super.key});

  @override
  State<Level3> createState() => _Level3State();
}

class _Level3State extends State<Level3> with WidgetsBindingObserver {
  double playerX = 50;
  double playerY = 50;
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

  // Static platforms for Level 3
  List<Map<String, double>> platforms = [
    {'x': 0, 'y': 0, 'width': 120, 'height': 50}, // Ground start
    {'x': 200, 'y': 80, 'width': 80, 'height': 20}, // Static platform 1
    {'x': 400, 'y': 120, 'width': 80, 'height': 20}, // Static platform 2
    {'x': 650, 'y': 50, 'width': double.infinity, 'height': 50}, // End ground
  ];

  // Moving platforms - we'll track these separately
  final List<GlobalKey<_MovingPlatformState>> _movingPlatformKeys = [
    GlobalKey<_MovingPlatformState>(),
    GlobalKey<_MovingPlatformState>(),
  ];

  void resetLevel() {
    setState(() {
      playerX = 50;
      playerY = 50;
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

    // Check static platforms
    for (var platform in platforms) {
      if (playerX + playerSize > platform['x']! &&
          playerX < platform['x']! + platform['width']! &&
          playerY <= platform['y']! + platform['height']! &&
          playerY + playerSize > platform['y']!) {
        
        if (velocityY <= 0 && playerY > platform['y']! + platform['height']! - 5) {
          playerY = platform['y']! + platform['height']!;
          velocityY = 0;
          isOnGround = true;
        }
      }
    }

    // Check moving platforms
    // Moving platform 1: x moves between 150-350, y=100
    double movingPlatform1X = 150 + (200 * ((DateTime.now().millisecondsSinceEpoch / 2000) % 2 - 1).abs());
    if (playerX + playerSize > movingPlatform1X &&
        playerX < movingPlatform1X + 100 &&
        playerY <= 120 &&
        playerY + playerSize > 100) {
      
      if (velocityY <= 0 && playerY > 115) {
        playerY = 120;
        velocityY = 0;
        isOnGround = true;
      }
    }

    // Moving platform 2: x moves between 450-550, y=160
    double movingPlatform2X = 450 + (100 * ((DateTime.now().millisecondsSinceEpoch / 3000) % 2 - 1).abs());
    if (playerX + playerSize > movingPlatform2X &&
        playerX < movingPlatform2X + 100 &&
        playerY <= 180 &&
        playerY + playerSize > 160) {
      
      if (velocityY <= 0 && playerY > 175) {
        playerY = 180;
        velocityY = 0;
        isOnGround = true;
      }
    }

    // Check trap collisions
    if ((playerX < 310 && playerX > 270 && playerY <= 100) ||
        (playerX < 530 && playerX > 480 && playerY <= 140)) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Check exit door collision
    if (playerX > 700 && playerX < 760 && playerY <= 110 && playerY > 50) {
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
      // Handle horizontal movement (can work independently of jumping)
      velocityX = 0;
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || 
          keysPressed.contains(LogicalKeyboardKey.keyA)) {
        velocityX = -moveSpeed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || 
          keysPressed.contains(LogicalKeyboardKey.keyD)) {
        velocityX = moveSpeed;
      }

      // Handle jumping (independent of horizontal movement)
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
            // Industrial/Factory background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade600,
                    Colors.grey.shade700,
                  ],
                ),
              ),
            ),

            // Factory pipes/steam effects
            ...List.generate(8, (index) => Positioned(
              left: (index * 100) % MediaQuery.of(context).size.width,
              top: (index * 23) % 150,
              child: Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade500,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),

            // Ground segments
            Positioned.fill(
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 120,
                  height: 50,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 650,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.grey.shade700,
              ),
            ),

            // Static platforms
            const GroundBlock(x: 200, y: 80, width: 80, height: 20),
            const GroundBlock(x: 400, y: 120, width: 80, height: 20),

            // Moving platforms
            MovingPlatform(
              x: 150,
              y: 100,
              width: 100,
              height: 20,
              startX: 150,
              endX: 350,
              speed: 2.0,
            ),
            MovingPlatform(
              x: 450,
              y: 160,
              width: 100,
              height: 20,
              startX: 450,
              endX: 550,
              speed: 1.5,
            ),

            // Traps
            Trap(
              x: 280,
              y: 80,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),
            Trap(
              x: 505,
              y: 120,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),

            // Exit door
            ExitDoor(
              x: 720,
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

            // Level indicator
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
                      'Level 3 - Moving Madness',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Jump on the moving platforms!',
                      style: TextStyle(color: Colors.white, fontSize: 10),
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
              bottom: 30,
              left: 30,
              child: Row(
                children: [
                  // Left arrow button
                  GestureDetector(
                    onPanStart: (_) {
                      keysPressed.add(LogicalKeyboardKey.arrowLeft);
                    },
                    onPanEnd: (_) {
                      keysPressed.remove(LogicalKeyboardKey.arrowLeft);
                    },
                    onPanCancel: () {
                      keysPressed.remove(LogicalKeyboardKey.arrowLeft);
                    },
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
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white54, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_left,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Right arrow button  
                  GestureDetector(
                    onPanStart: (_) {
                      keysPressed.add(LogicalKeyboardKey.arrowRight);
                    },
                    onPanEnd: (_) {
                      keysPressed.remove(LogicalKeyboardKey.arrowRight);
                    },
                    onPanCancel: () {
                      keysPressed.remove(LogicalKeyboardKey.arrowRight);
                    },
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
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade700.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white54, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Jump button
            Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onPanStart: (_) {
                  keysPressed.add(LogicalKeyboardKey.space);
                },
                onPanEnd: (_) {
                  keysPressed.remove(LogicalKeyboardKey.space);
                },
                onPanCancel: () {
                  keysPressed.remove(LogicalKeyboardKey.space);
                },
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'JUMP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                        'Crushed by Machinery!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '⚙️ GAME OVER ⚙️',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 24,
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
                            child: const Text('Try Again'),
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
                        '⚙️ Factory Cleared! ⚙️',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Level 3 Complete!',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 24,
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