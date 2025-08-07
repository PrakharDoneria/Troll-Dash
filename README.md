# 🎮 Troll Dash - Puzzle Platformer with Mind Games 🎮

A challenging Flutter-based puzzle platformer where nothing is as it seems! Navigate through treacherous levels filled with traps, fake platforms, and mind-bending challenges. Can you outsmart the trolls and reach the exit?

## 🎯 Game Features

- **Multiple Challenging Levels**: Each level introduces new mechanics and troll elements
- **Deceptive Gameplay**: Fake platforms, hidden traps, and visual tricks await
- **Smooth Controls**: Responsive keyboard controls for precise platforming
- **Sound Effects**: Immersive audio feedback for jumps, traps, and level completion
- **Beautiful UI**: Animated menus and polished game visuals
- **Progressive Difficulty**: Levels get more challenging and creative with troll elements

## 🎮 How to Play

### Controls
- **Movement**: Arrow Keys or WASD
- **Jump**: Spacebar, W key, or Up Arrow
- **Back to Menu**: Back button (in-game) or ESC key

### Objective
- Navigate from the starting position to the exit door
- Avoid red traps that will end your run
- Be careful - some platforms might not be what they seem!
- Collect your wits and prepare to be trolled!

## 📱 Levels

### Level 1 - Tutorial
- Learn the basic controls
- Simple platform jumping
- Introduction to traps and exit doors

### Level 2 - Troll's Revenge  
- Night theme with stars
- Fake platforms that disappear when touched
- More complex trap layouts
- Multiple platform sequences

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/PrakharDoneria/Troll-Dash.git
   cd Troll-Dash
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the game**
   ```bash
   flutter run
   ```

### Building for Release

```bash
# Android
flutter build apk --release

# Web
flutter build web

# Windows (if on Windows)
flutter build windows
```

## 🎵 Audio Assets

The game supports sound effects and background music. To add your own audio files:

1. Place sound effects in `assets/sounds/`
2. Place background music in `assets/music/`
3. Supported formats: MP3, WAV, OGG

### Default Audio Files (Optional)
- `jump.mp3` - Jump sound effect
- `trap.mp3` - Trap trigger sound
- `level_complete.mp3` - Level completion sound
- `background.mp3` - Background music loop

## 🔧 Development

### Adding New Levels

1. Create a new level file in `lib/levels/`
2. Import it in `lib/level_registry.dart`
3. Add it to the `levels` list

### Game Objects Available
- **Player**: The main character (orange/amber circle)
- **GroundBlock**: Solid platforms to jump on
- **Trap**: Red danger zones that end the game
- **FakePlatform**: Platforms that disappear when touched
- **ExitDoor**: Level completion trigger

### Sound Integration
The `SoundManager` class handles all audio:
- `playJumpSound()` - Play jump effect
- `playTrapSound()` - Play trap trigger sound
- `playLevelCompleteSound()` - Play level completion sound
- `playBackgroundMusic()` - Start background music loop

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingTroll`)
3. Commit your changes (`git commit -m 'Add some AmazingTroll'`)
4. Push to the branch (`git push origin feature/AmazingTroll`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎭 Acknowledgments

- Inspired by classic puzzle platformers
- Built with Flutter for cross-platform compatibility
- Special thanks to all the trolls who made this game possible! 😈

---

**May the trolls be ever in your favor!** 🎮✨
