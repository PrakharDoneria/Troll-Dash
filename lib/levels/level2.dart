import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trolldash/GameObjects/ground_block.dart';
import 'package:trolldash/GameObjects/trap.dart';
import 'package:trolldash/GameObjects/exit_door.dart';
import 'package:trolldash/GameObjects/fake_platform.dart';
import 'package:trolldash/GameObjects/player.dart' as player_file;
import 'package:trolldash/sound_manager.dart';

class Level2 extends StatefulWidget {
  const Level2({super.key});

  @override
  State<Level2> createState() => _Level2State();
}

class _Level2State extends State<Level2> with WidgetsBindingObserver {
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

  // Level 2 has more challenging platforms and fake platforms
  List<Map<String, double>> platforms = [
    {'x': 0, 'y': 0, 'width': 150, 'height': 50}, // Ground (partial)
    {'x': 200, 'y': 80, 'width': 80, 'height': 20}, // Platform 1
    {'x': 320, 'y': 120, 'width': 80, 'height': 20}, // Platform 2
    {'x': 450, 'y': 160, 'width': 80, 'height': 20}, // Platform 3
    {'x': 580, 'y': 100, 'width': 100, 'height': 20}, // Platform 4
    {'x': 720, 'y': 50, 'width': double.infinity, 'height': 50}, // End ground
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

    // Check trap collisions
    if ((playerX < 350 && playerX > 290 && playerY <= 100) ||
        (playerX < 520 && playerX > 420 && playerY <= 180) ||
        (playerX < 650 && playerX > 550 && playerY <= 120)) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Check fake platform "collision" (it disappears)
    if (playerX > 150 && playerX < 200 && playerY <= 130 && playerY > 110) {
      _soundManager.playTrapSound();
      gameOver = true;
    }

    // Check exit door collision
    if (playerX > 800 && playerX < 860 && playerY <= 110 && playerY > 50) {
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
            // Night sky background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.purple.shade900,
                    Colors.indigo.shade800,
                  ],
                ),
              ),
            ),

            // Stars
            ...List.generate(20, (index) => Positioned(
              left: (index * 47) % MediaQuery.of(context).size.width,
              top: (index * 31) % 200,
              child: Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )),

            // Ground segments
            Positioned.fill(
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 150,
                  height: 50,
                  color: Colors.brown.shade600,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width - 720,
                height: 50,
                color: Colors.brown.shade600,
              ),
            ),

            // Ground blocks (platforms)
            const GroundBlock(x: 200, y: 80, width: 80, height: 20),
            const GroundBlock(x: 320, y: 120, width: 80, height: 20),
            const GroundBlock(x: 450, y: 160, width: 80, height: 20),
            const GroundBlock(x: 580, y: 100, width: 100, height: 20),

            // Fake platform (looks like a real one but disappears when touched)
            FakePlatform(
              x: 150,
              y: 110,
              width: 80,
              height: 20,
              onStep: () {
                setState(() => gameOver = true);
              },
            ),

            // Traps
            Trap(
              x: 310,
              y: 80,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),
            Trap(
              x: 480,
              y: 160,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),
            Trap(
              x: 620,
              y: 100,
              width: 30,
              height: 30,
              onTrigger: () {
                setState(() => gameOver = true);
              },
            ),

            // Exit door
            ExitDoor(
              x: 820,
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
                      'Level 2 - Troll\'s Revenge',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Watch out for fake platforms!',
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

            // Game Over overlay
            if (gameOver)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You\'ve Been Trolled!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '🤡 GAME OVER 🤡',
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
                        '🎭 Troll Master! 🎭',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Level 2 Complete!',
                        style: TextStyle(
                          color: Colors.yellow,
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