import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Domain code must stay pure Dart (ARCHITECTURE.md §2).
const domainDirs = [
  'lib/core/constants',
  'lib/core/utils',
  'lib/features/game/models',
  'lib/features/game/engine',
  'lib/features/game/rules',
  'lib/features/ai',
];
const domainFiles = ['lib/features/game/services/dice_service.dart'];

const forbidden = [
  'package:flutter/',
  'package:flame',
  'package:flutter_riverpod',
  'package:riverpod',
  'dart:io',
  'dart:ui',
];

Iterable<File> dartFiles() sync* {
  for (final d in domainDirs) {
    final dir = Directory(d);
    if (!dir.existsSync()) continue;
    yield* dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.contains('.g.dart'));
  }
  for (final f in domainFiles) {
    yield File(f);
  }
}

void main() {
  test('domain code imports no Flutter, Flame, Riverpod or dart:io', () {
    final offenders = <String>[];
    for (final f in dartFiles()) {
      for (final line in f.readAsLinesSync()) {
        final l = line.trim();
        if (!l.startsWith('import ') && !l.startsWith('export ')) continue;
        if (forbidden.any(l.contains)) offenders.add('${f.path}: $l');
        final presentation = RegExp('/(flame|widgets|screens|controllers)/');
        if (presentation.hasMatch(l)) offenders.add('${f.path}: $l');
      }
    }
    expect(offenders, isEmpty);
  });
}
