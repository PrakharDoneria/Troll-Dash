import 'package:flutter/material.dart';
import 'levels/level1.dart';
import 'levels/level2.dart';
import 'levels/level3.dart';
import 'levels/level4.dart';
import 'levels/level5.dart';
// Just import new levels here

final List<LevelInfo> levels = [
  LevelInfo(name: 'Level 1 - Tutorial', widget: Level1()),
  LevelInfo(name: 'Level 2 - Troll\'s Revenge', widget: Level2()),
  LevelInfo(name: 'Level 3 - Moving Madness', widget: Level3()),
  LevelInfo(name: 'Level 4 - Vanishing Steps', widget: Level4()),
  LevelInfo(name: 'Level 5 - Troll Master', widget: Level5()),
  // Add new levels here only
];

class LevelInfo {
  final String name;
  final Widget widget;

  LevelInfo({required this.name, required this.widget});
}
