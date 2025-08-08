import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trolldash/GameObjects/ground_block.dart';
import 'package:trolldash/GameObjects/trap.dart';
import 'package:trolldash/GameObjects/exit_door.dart';
import 'package:trolldash/GameObjects/temp_platform.dart';
import 'package:trolldash/GameObjects/player.dart' as player_file;
import 'package:trolldash/sound_manager.dart';

class Level4 extends StatefulWidget {
  const Level4({super.key});

  @override
  State<Level4> createState() => _Level4State();
}

class _Level4State extends State<Level4> with WidgetsBindingObserver {
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

  // Static platforms for Level 4
  List<Map<String, double>> platforms = [
    {'x': 0, 'y': 0, 'width': 100, 'height': 50}, // Ground start
    {'x': 550, 'y': 80, 'width': 80, 'height': 20}, // Safe platform
    {'x': 700, 'y': 50, 'width': double.infinity, 'height': 50}, // End ground
  ];

  // Global keys for temp platforms to control their state
  final List<GlobalKey<_TempPlatformState>> _tempPlatformKeys = [
    GlobalKey<_TempPlatformState>(),
    GlobalKey<_TempPlatformState>(),
    GlobalKey<_TempPlatformState>(),
    GlobalKey<_TempPlatformState>(),
  ];

  // Track temp platform states
  List<bool> tempPlatformStates = [true, true, true, true];

  void resetLevel() {
    setState(() {
      playerX = 50;
      playerY = 50;
      velocityX = 0;
      velocityY = 0;
      isOnGround = false;
      gameOver = false;
      levelComplete = false;
      tempPlatformStates = [true, true, true, true];
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

    // Check temporary platforms
    List<Map<String, double>> tempPlatforms = [
      {'x': 150, 'y': 80, 'width': 100, 'height': 20},   // Temp platform 1
      {'x': 280, 'y': 120, 'width': 100, 'height': 20},  // Temp platform 2
      {'x': 410, 'y': 160, 'width': 100, 'height': 20},  // Temp platform 3
      {'x': 250, 'y': 180, 'width': 100, 'height': 20},  // Temp platform 4
    ];

    for (int i = 0; i < tempPlatforms.length; i++) {
      if (!tempPlatformStates[i]) continue; // Skip if platform is gone

      var platform = tempPlatforms[i];
      if (playerX + playerSize > platform['x']! &&
          playerX < platform['x']! + platform['width']! &&
          playerY <= platform['y']! + platform['height']! &&
          playerY + playerSize > platform['y']!) {
        
        if (velocityY <= 0 && playerY > platform['y']! + platform['height']! - 5) {
          playerY = platform['y']! + platform['height']!;
          velocityY = 0;
          isOnGround = true;
          
          // Trigger platform disappearing
          final key = _tempPlatformKeys[i].currentState;
          if (key != null) {
            key.triggerDisappear();
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  tempPlatformStates[i] = false;
                });
                // Restore platform after 3 seconds
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      tempPlatformStates[i] = true;
                    });
                  }
                });
              }
            });
          }
        }
      }
    }

    // Check trap collisions
    if ((playerX < 630 && playerX > 580 && playerY <= 100) ||
        (playerX < 180 && playerX > 120 && playerY <= 100)) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Check exit door collision
    if (playerX > 750 && playerX < 810 && playerY <= 110 && playerY > 50) {
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
            // Volcanic/Lava background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red.shade900,
                    Colors.orange.shade800,
                    Colors.red.shade800,
                  ],
                ),
              ),
            ),

            // Lava bubbles/fire effects
            ...List.generate(15, (index) => Positioned(
              left: (index * 67) % MediaQuery.of(context).size.width,
              top: (index * 29) % 180,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange.shade300,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            )),

            // Ground segments
            Positioned.fill(
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.red.shade700,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 700,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.red.shade700,
              ),
            ),

            // Safe static platform
            const GroundBlock(x: 550, y: 80, width: 80, height: 20),

            // Temporary platforms
            TempPlatform(
              key: _tempPlatformKeys[0],
              x: 150,
              y: 80,
              width: 100,
              height: 20,
              disappearDelayMs: 1500,
              onStep: () {
                print('Stepped on temp platform 1');
              },
            ),
            TempPlatform(
              key: _tempPlatformKeys[1],
              x: 280,
              y: 120,
              width: 100,
              height: 20,
              disappearDelayMs: 1500,
              onStep: () {
                print('Stepped on temp platform 2');
              },
            ),
            TempPlatform(
              key: _tempPlatformKeys[2],
              x: 410,
              y: 160,
              width: 100,
              height: 20,
              disappearDelayMs: 1500,
              onStep: () {
                print('Stepped on temp platform 3');
              },
            ),
            TempPlatform(
              key: _tempPlatformKeys[3],
              x: 250,
              y: 180,
              width: 100,
              height: 20,
              disappearDelayMs: 1500,
              onStep: () {
                print('Stepped on temp platform 4');
              },
            ),

            // Traps
            Trap(
              x: 150,
              y: 50,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),
            Trap(
              x: 600,
              y: 80,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),

            // Exit door
            ExitDoor(
              x: 760,
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
                      'Level 4 - Vanishing Steps',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Platforms disappear after you step on them!',
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
                        'Fell Into The Lava!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '🔥 GAME OVER 🔥',
                        style: TextStyle(
                          color: Colors.orange,
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
                        '🔥 Volcano Conquered! 🔥',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Level 4 Complete!',
                        style: TextStyle(
                          color: Colors.orange,
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