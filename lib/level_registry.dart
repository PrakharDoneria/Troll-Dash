import 'package:flutter/material.dart';
import 'levels/level1.dart';
// import 'levels/level2.dart';
// Just import new levels here

final List<LevelInfo> levels = [
  LevelInfo(name: 'Level 1', widget: Level1()),
  // LevelInfo(name: 'Level 2', widget: Level2()),
  // Add new levels here only
];

class LevelInfo {
  final String name;
  final Widget widget;

  LevelInfo({required this.name, required this.widget});
}
