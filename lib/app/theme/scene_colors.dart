import 'package:flutter/material.dart';

/// Colours for the Game screen's scene: the painted backdrop, the board
/// frame and the glossy HUD. Widgets read them through `context.scene`.
@immutable
class SceneColors extends ThemeExtension<SceneColors> {
  /// Creates the colours.
  const SceneColors({
    required this.skyTop,
    required this.skyBottom,
    required this.cloud,
    required this.starlight,
    required this.hillFar,
    required this.hillNear,
    required this.groundTop,
    required this.groundBottom,
    required this.plaza,
    required this.plazaEdge,
    required this.goldLight,
    required this.goldDark,
    required this.buttonTop,
    required this.buttonBottom,
    required this.sideTop,
    required this.sideBottom,
    required this.onButton,
    required this.disabledTop,
    required this.disabledBottom,
    required this.pill,
    required this.onPill,
    required this.banner,
    required this.onBanner,
    required this.hud,
    required this.onHud,
    required this.titleStroke,
    required this.titleFill,
    required this.titleFill2,
    required this.shadow,
    required this.ctaTop,
    required this.ctaBottom,
    required this.onCta,
    required this.ctaIcon,
    required this.ghost,
    required this.onGhost,
  });

  /// Daytime scene.
  static const light = SceneColors(
    skyTop: Color(0xFF2F8FE8),
    skyBottom: Color(0xFFA9DBFF),
    cloud: Color(0xFFFFFFFF),
    starlight: Color(0x00FFFFFF),
    hillFar: Color(0xFF7CC46A),
    hillNear: Color(0xFF4FA845),
    groundTop: Color(0xFF8ACB63),
    groundBottom: Color(0xFF5FA845),
    plaza: Color(0xFFE6DCCB),
    plazaEdge: Color(0xFFC9BBA2),
    goldLight: Color(0xFFFFE08A),
    goldDark: Color(0xFFE0A22E),
    buttonTop: Color(0xFF3C8DFF),
    buttonBottom: Color(0xFF1453C8),
    sideTop: Color(0xFF7A7CFF),
    sideBottom: Color(0xFF3E3FC4),
    onButton: Color(0xFFFFFFFF),
    disabledTop: Color(0xFF9AA6BD),
    disabledBottom: Color(0xFF6C7892),
    pill: Color(0xFFFFFFFF),
    onPill: Color(0xFF1B1E28),
    banner: Color(0xFFFFF6D6),
    onBanner: Color(0xFF3A2A00),
    hud: Color(0xCC17336B),
    onHud: Color(0xFFFFFFFF),
    titleStroke: Color(0xFF15306E),
    titleFill: Color(0xFFFFD23F),
    titleFill2: Color(0xFFFFFFFF),
    shadow: Color(0x55141828),
    ctaTop: Color(0xFFFFC93C),
    ctaBottom: Color(0xFFFF9A1F),
    onCta: Color(0xFF15306E),
    ctaIcon: Color(0xFFE53228),
    ghost: Color(0xD9FFFFFF),
    onGhost: Color(0xFF1453C8),
  );

  /// Night scene.
  static const dark = SceneColors(
    skyTop: Color(0xFF0B1433),
    skyBottom: Color(0xFF2A3A6E),
    cloud: Color(0xFF3B4A7A),
    starlight: Color(0xCCFFFFFF),
    hillFar: Color(0xFF1F3D3A),
    hillNear: Color(0xFF173029),
    groundTop: Color(0xFF22423A),
    groundBottom: Color(0xFF142822),
    plaza: Color(0xFF3A3F52),
    plazaEdge: Color(0xFF2A2E3E),
    goldLight: Color(0xFFF2CF70),
    goldDark: Color(0xFFB57E1E),
    buttonTop: Color(0xFF4A90F0),
    buttonBottom: Color(0xFF1C4FB0),
    sideTop: Color(0xFF6E70E8),
    sideBottom: Color(0xFF34359E),
    onButton: Color(0xFFFFFFFF),
    disabledTop: Color(0xFF4E566B),
    disabledBottom: Color(0xFF353B4D),
    pill: Color(0xFF1D2030),
    onPill: Color(0xFFF2F3F7),
    banner: Color(0xFF262A3C),
    onBanner: Color(0xFFFFE7A3),
    hud: Color(0xCC0B1433),
    onHud: Color(0xFFFFFFFF),
    titleStroke: Color(0xFF0B1433),
    titleFill: Color(0xFFFFD23F),
    titleFill2: Color(0xFFF2F3F7),
    shadow: Color(0x88000000),
    ctaTop: Color(0xFFF2B53A),
    ctaBottom: Color(0xFFD9791A),
    onCta: Color(0xFF15306E),
    ctaIcon: Color(0xFFD93B33),
    ghost: Color(0xD91D2030),
    onGhost: Color(0xFF8FB8F5),
  );

  /// Sky gradient, top.
  final Color skyTop;

  /// Sky gradient, horizon.
  final Color skyBottom;

  /// Clouds.
  final Color cloud;

  /// Stars; transparent by day.
  final Color starlight;

  /// Distant hills.
  final Color hillFar;

  /// Near hills and bushes.
  final Color hillNear;

  /// Ground gradient, top.
  final Color groundTop;

  /// Ground gradient, bottom.
  final Color groundBottom;

  /// Stone plaza under the Roll button.
  final Color plaza;

  /// Plaza rim.
  final Color plazaEdge;

  /// Gold rims, highlight.
  final Color goldLight;

  /// Gold rims, shade.
  final Color goldDark;

  /// Primary glossy button, top.
  final Color buttonTop;

  /// Primary glossy button, bottom.
  final Color buttonBottom;

  /// Side buttons, top.
  final Color sideTop;

  /// Side buttons, bottom.
  final Color sideBottom;

  /// Icons and text on buttons.
  final Color onButton;

  /// Disabled button, top.
  final Color disabledTop;

  /// Disabled button, bottom.
  final Color disabledBottom;

  /// Player pills.
  final Color pill;

  /// Text on [pill].
  final Color onPill;

  /// Turn banner.
  final Color banner;

  /// Text on [banner].
  final Color onBanner;

  /// Timer chip.
  final Color hud;

  /// Text on [hud].
  final Color onHud;

  /// Title outline.
  final Color titleStroke;

  /// Title first word.
  final Color titleFill;

  /// Title second word.
  final Color titleFill2;

  /// Drop shadows.
  final Color shadow;

  /// Continue button, top.
  final Color ctaTop;

  /// Continue button, bottom.
  final Color ctaBottom;

  /// Text on the Continue button.
  final Color onCta;

  /// Play triangle on the Continue button.
  final Color ctaIcon;

  /// Outlined button fill.
  final Color ghost;

  /// Text and outline of the outlined button.
  final Color onGhost;

  @override
  SceneColors copyWith() => this;

  @override
  SceneColors lerp(SceneColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SceneColors(
      skyTop: l(skyTop, other.skyTop),
      skyBottom: l(skyBottom, other.skyBottom),
      cloud: l(cloud, other.cloud),
      starlight: l(starlight, other.starlight),
      hillFar: l(hillFar, other.hillFar),
      hillNear: l(hillNear, other.hillNear),
      groundTop: l(groundTop, other.groundTop),
      groundBottom: l(groundBottom, other.groundBottom),
      plaza: l(plaza, other.plaza),
      plazaEdge: l(plazaEdge, other.plazaEdge),
      goldLight: l(goldLight, other.goldLight),
      goldDark: l(goldDark, other.goldDark),
      buttonTop: l(buttonTop, other.buttonTop),
      buttonBottom: l(buttonBottom, other.buttonBottom),
      sideTop: l(sideTop, other.sideTop),
      sideBottom: l(sideBottom, other.sideBottom),
      onButton: l(onButton, other.onButton),
      disabledTop: l(disabledTop, other.disabledTop),
      disabledBottom: l(disabledBottom, other.disabledBottom),
      pill: l(pill, other.pill),
      onPill: l(onPill, other.onPill),
      banner: l(banner, other.banner),
      onBanner: l(onBanner, other.onBanner),
      hud: l(hud, other.hud),
      onHud: l(onHud, other.onHud),
      titleStroke: l(titleStroke, other.titleStroke),
      titleFill: l(titleFill, other.titleFill),
      titleFill2: l(titleFill2, other.titleFill2),
      shadow: l(shadow, other.shadow),
      ctaTop: l(ctaTop, other.ctaTop),
      ctaBottom: l(ctaBottom, other.ctaBottom),
      onCta: l(onCta, other.onCta),
      ctaIcon: l(ctaIcon, other.ctaIcon),
      ghost: l(ghost, other.ghost),
      onGhost: l(onGhost, other.onGhost),
    );
  }
}
