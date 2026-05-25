import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorialKeys {
  final List<List<GlobalKey>> cellKeys = List.generate(9, (_) => List.generate(9, (_) => GlobalKey()));
  final List<GlobalKey> numKeys = List.generate(9, (_) => GlobalKey());
  final GlobalKey visionKey = GlobalKey();
  final GlobalKey clockKey = GlobalKey();
  final GlobalKey divineKey = GlobalKey();
  final GlobalKey coinsKey = GlobalKey();
  final GlobalKey shareKey = GlobalKey();
  final GlobalKey levelKey = GlobalKey();
}

final tutorialKeysProvider = Provider((ref) => TutorialKeys());
