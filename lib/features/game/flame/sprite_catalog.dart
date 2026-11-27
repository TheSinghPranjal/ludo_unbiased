import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// Light or dark art.
enum BoardMode {
  /// Light variants.
  light,

  /// Dark variants.
  dark,
}

/// Loads the board's sprites for both modes from `assets/images/`, so the
/// appearance can switch live without reloading the game.
class SpriteCatalog {
  /// Creates a catalog backed by [images].
  SpriteCatalog(this.images);

  /// Flame image cache.
  final Images images;

  final Map<String, Sprite> _sprites = {};

  /// Resolution folder per asset group. Small pieces use 3x so they stay
  /// sharp on tablets; yards use 2x; the flat background uses 1x.
  static String _folder(String id) {
    if (id == 'board_bg') return '';
    if (id.startsWith('board_yard')) return '2.0x/';
    return '3.0x/';
  }

  static String _group(String id) => switch (id.split('_').first) {
    'board' => 'board',
    'token' => 'tokens',
    'dice' => 'dice',
    'fx' => 'fx',
    _ => throw ArgumentError.value(id, 'id', 'unknown sprite group'),
  };

  static bool _hasModes(String id) => !id.startsWith('fx_');

  /// Asset path for [id] in [mode], relative to `assets/images/`.
  static String path(String id, BoardMode mode) {
    final file = _hasModes(id) ? '${id}_${mode.name}' : id;
    return '${_group(id)}/${_folder(id)}$file.png';
  }

  /// Every sprite the board uses.
  static List<String> get ids => [
    'board_bg',
    'board_cell',
    'board_cell_safe_star',
    'board_centre_home',
    for (final c in PlayerColor.values) ...[
      'board_cell_start_${c.name}',
      'board_home_column_${c.name}',
      'board_yard_${c.name}',
      'board_arrow_${c.name}',
      for (final s in ['idle', 'movable', 'selected', 'hop', 'ghost'])
        'token_${c.name}_$s',
    ],
    'token_shadow',
    'token_stack_badge_2',
    'token_stack_badge_3',
    'token_stack_badge_4',
    for (var k = 1; k <= 6; k++) 'fx_capture_puff_0$k',
    'fx_sparkle',
  ];

  /// Loads every sprite in both modes.
  Future<void> load() async {
    final paths = {
      for (final id in ids)
        for (final m in BoardMode.values) path(id, m),
    };
    await images.loadAll(paths.toList());
    for (final p in paths) {
      _sprites[p] = Sprite(images.fromCache(p));
    }
  }

  /// The sprite for [id] in [mode].
  Sprite get(String id, BoardMode mode) => _sprites[path(id, mode)]!;
}
