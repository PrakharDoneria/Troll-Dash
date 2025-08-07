import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trolldash/GameObjects/ground_block.dart';
import 'package:trolldash/GameObjects/trap.dart';
import 'package:trolldash/GameObjects/exit_door.dart';
import 'package:trolldash/GameObjects/fake_platform.dart';
import 'package:trolldash/GameObjects/player.dart' as player_file;
import 'package:trolldash/sound_manager.dart';

class Level3 extends StatefulWidget {
  const Level3({super.key});

  @override
  State<Level3> createState() => _Level3State();
}

class _Level3State extends State<Level3> with WidgetsBindingObserver {
  double playerX = 100;
  double playerY = 100;
  double velocityX = 0;
  double velocityY = 0;
  bool isOnGround = false;
  bool gameOver = false;
  bool levelComplete = false;

  final double gravity = 15;
  final double moveSpeed = 5;
  final double jumpSpeed = -12;
  final double playerSize = 30;

  Set<LogicalKeyboardKey> keysPressed = {};
  final SoundManager _soundManager = SoundManager();

  // Level 3 - Ultimate Troll Challenge
  List<Map<String, double>> platforms = [
    {'x': 0, 'y': 0, 'width': 100, 'height': 50}, // Starting ground
    {'x': 150, 'y': 60, 'width': 60, 'height': 20}, // Platform 1
    {'x': 250, 'y': 90, 'width': 60, 'height': 20}, // Platform 2
    {'x': 350, 'y': 120, 'width': 60, 'height': 20}, // Platform 3
    {'x': 480, 'y': 140, 'width': 80, 'height': 20}, // Platform 4
    {'x': 600, 'y': 100, 'width': 60, 'height': 20}, // Platform 5
    {'x': 700, 'y': 80, 'width': 200, 'height': 50}, // End ground
  ];

  void resetLevel() {
    setState(() {
      playerX = 100;
      playerY = 100;
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

    // Multiple trap zones
    if ((playerX < 220 && playerX > 180 && playerY <= 80) ||
        (playerX < 320 && playerX > 280 && playerY <= 110) ||
        (playerX < 450 && playerX > 410 && playerY <= 140) ||
        (playerX < 570 && playerX > 530 && playerY <= 160) ||
        (playerX < 670 && playerX > 630 && playerY <= 120)) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Fake platform trap
    if (playerX > 120 && playerX < 150 && playerY <= 30 && playerY > 10) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Exit door collision
    if (playerX > 780 && playerX < 840 && playerY <= 130 && playerY > 80) {
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

      velocityY += gravity * 0.05;
      playerX += velocityX;
      playerY += velocityY;

      if (playerX < 0) playerX = 0;
      if (playerX > 900 - playerSize) {
        playerX = 900 - playerSize;
      }

      checkCollisions();
    });
  }

  @override
  void initState() {
    super.initState();
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
            // Sunset/Volcano background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepOrange.shade800,
                    Colors.red.shade900,
                    Colors.orange.shade800,
                    Colors.yellow.shade700,
                  ],
                ),
              ),
            ),

            // Floating embers effect
            ...List.generate(15, (index) => Positioned(
              left: (index * 61 + 100) % 800.0,
              top: (index * 43 + 50) % 300,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            )),

            // Ground segments
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 100,
                height: 50,
                color: Colors.brown.shade800,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 100,
              child: Container(
                width: 200,
                height: 50,
                color: Colors.brown.shade800,
              ),
            ),

            // Lava pools (visual only)
            Positioned(
              bottom: 0,
              left: 100,
              child: Container(
                width: 600,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade600,
                      Colors.orange.shade500,
                      Colors.red.shade600,
                    ],
                  ),
                ),
              ),
            ),

            // Ground blocks (platforms)
            const GroundBlock(x: 150, y: 60, width: 60, height: 20),
            const GroundBlock(x: 250, y: 90, width: 60, height: 20),
            const GroundBlock(x: 350, y: 120, width: 60, height: 20),
            const GroundBlock(x: 480, y: 140, width: 80, height: 20),
            const GroundBlock(x: 600, y: 100, width: 60, height: 20),

            // Fake platform near start (troll element)
            FakePlatform(
              x: 120,
              y: 20,
              width: 50,
              height: 15,
              onStep: () {
                setState(() => gameOver = true);
              },
            ),

            // Multiple traps
            Trap(x: 190, y: 60, width: 25, height: 25, onTrigger: () => setState(() => gameOver = true)),
            Trap(x: 290, y: 90, width: 25, height: 25, onTrigger: () => setState(() => gameOver = true)),
            Trap(x: 420, y: 120, width: 25, height: 25, onTrigger: () => setState(() => gameOver = true)),
            Trap(x: 540, y: 140, width: 25, height: 25, onTrigger: () => setState(() => gameOver = true)),
            Trap(x: 640, y: 100, width: 25, height: 25, onTrigger: () => setState(() => gameOver = true)),

            // Exit door
            ExitDoor(
              x: 800,
              y: 80,
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
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade400),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level 3 - Volcano Chaos',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Ultimate troll challenge!',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      'Don\'t trust anything!',
                      style: TextStyle(color: Colors.red, fontSize: 10),
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
                  backgroundColor: Colors.deepOrange.shade700,
                  minimumSize: const Size(60, 36),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 12)),
              ),
            ),

            // Game Over overlay
            if (gameOver)
              Container(
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🌋 ROASTED! 🔥',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'The trolls got you again!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
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
                            child: const Text('Rise from Ashes'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                            ),
                            child: const Text('Retreat'),
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
                color: Colors.black.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🏆 TROLL LEGEND! 🏆',
                        style: TextStyle(
                          color: Colors.gold,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You\'ve conquered all trolls!',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
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
                            child: const Text('Master It Again'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                            ),
                            child: const Text('Victory Lap'),
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