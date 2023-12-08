import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/brand.dart';

class AppColors {
  AppColors._();

  static const Color _inspectedReplacementColor = Color(0xFFFF4081);

  // Primary colors
  static Color primary() => Brand.isBrsa()
      ? _color(InternalAppColors.primaryDarken) //
      : _color(InternalAppColors.primary);

  static Color primaryDarken() => _color(InternalAppColors.primaryDarken);

  static Color primaryLighten() => _color(InternalAppColors.primaryLighten);

  static Color primaryWithAlpha50() => _color(InternalAppColors.primaryWithAlpha50);

  // Secondary colors
  static Color secondary() => _color(InternalAppColors.secondary);

  static Color secondaryLighten() => _color(InternalAppColors.secondaryLighten);

  // Status colors
  static Color warning() => _color(InternalAppColors.warning);

  static Color warningLighten() => _color(InternalAppColors.warningLighten);

  static Color success() => _color(InternalAppColors.success);

  static Color successLighten() => _color(InternalAppColors.successLighten);

  static Color alert() => _color(InternalAppColors.alert);

  static Color alertLighten() => _color(InternalAppColors.alertLighten);

  // Accent colors
  static Color accent1() => _color(InternalAppColors.accent1);

  static Color accent1Lighten() => _color(InternalAppColors.accent1Lighten);

  static Color accent2() => _color(InternalAppColors.accent2);

  static Color accent2Lighten() => _color(InternalAppColors.accent2Lighten);

  static Color accent3() => _color(InternalAppColors.accent3);

  static Color accent3Lighten() => _color(InternalAppColors.accent3Lighten);

  // Content colors
  static Color contentColor() => _color(InternalAppColors.contentColor);

  static Color disabled() => _color(InternalAppColors.disabled);

  static Color grey100() => _color(InternalAppColors.grey100);

  static Color grey500() => _color(InternalAppColors.grey500);

  static Color grey700() => _color(InternalAppColors.grey700);

  static Color grey800() => _color(InternalAppColors.grey800);

  // Additional colors
  static Color additional1Lighten() => _color(InternalAppColors.additional1Lighten);

  static Color additional12() => _color(InternalAppColors.additional1);

  static Color additional2Lighten() => _color(InternalAppColors.additional2Lighten);

  static Color additional22() => _color(InternalAppColors.additional2);

  static Color additional3Lighten() => _color(InternalAppColors.additional3Lighten);

  static Color additional32() => _color(InternalAppColors.additional3);

  static Color additional4Lighten() => _color(InternalAppColors.additional4Lighten);

  static Color additional42() => _color(InternalAppColors.additional4);

  static Color additional5Lighten() => _color(InternalAppColors.additional5Lighten);

  static Color additional52() => _color(InternalAppColors.additional5);

  static Color favoriteHeartColor() => _color(InternalAppColors.favoriteHeartColor);

  static Color switchColor() => _color(InternalAppColors.switchColor);

  // Brands
  static Color poleEmploi() => _color(InternalAppColors.poleEmploi);

  static Color missionLocale() => _color(InternalAppColors.missionLocale);

  // Unreferenced colors
  static Color loadingGreyPlaceholder() => _color(InternalAppColors.loadingGreyPlaceholder);

  static Color _color(InternalAppColors color) {
    return !InternalAppColors.inspectedColors.contains(color) ? color.color : _inspectedReplacementColor;
  }
}

enum InternalAppColors {
  // Primary colors
  primary(Color(0xFF3B69D1)),
  primaryDarken(Color(0xFF274996)),
  primaryLighten(Color(0xFFEEF1F8)),
  primaryWithAlpha50(Color(0x7A3B69D1)),
  // Secondary colors
  secondary(Color(0xFF0D7F50)),
  secondaryLighten(Color(0xFFE5F6EF)),
  // Status colors
  warning(Color(0xFFD31140)),
  warningLighten(Color(0xFFFDEAEF)),
  success(Color(0xFF033C24)),
  successLighten(Color(0xFFE5F6EF)),
  alert(Color(0xFFFF975C)),
  alertLighten(Color(0xFFFFC6A6)),
  // Accent colors
  accent1(Color(0xFF950EFF)),
  accent1Lighten(Color(0xFFF4E5FF)),
  accent2(Color(0xFF4A526D)),
  accent2Lighten(Color(0xFFF6F6F6)),
  accent3(Color(0xFF0C7A81)),
  accent3Lighten(Color(0xFFDFFDFF)),
  // Content colors
  contentColor(Color(0xFF161616)),
  disabled(Color(0xFF73758D)),
  grey100(Color(0xFFF1F1F1)),
  grey500(Color(0xFFB2B2B2)),
  grey700(Color(0xFF878787)),
  grey800(Color(0xFF646464)),
  // Additional colors
  additional1Lighten(Color(0xFFFFD88D)),
  additional1(Color(0xFFFCBF49)),
  additional2Lighten(Color(0xFFDDFFED)),
  additional2(Color(0xFF15616D)),
  additional3Lighten(Color(0xFFD2CEF6)),
  additional3(Color(0xFF5149A8)),
  additional4Lighten(Color(0xFFDBEDF9)),
  additional4(Color(0xFF2186C7)),
  additional5Lighten(Color(0xFFCEF0F1)),
  additional5(Color(0xFF49BBBF)),
  favoriteHeartColor(Color(0xFFA44C66)),
  switchColor(Color(0xFF34C759)),
  // Brands
  poleEmploi(Color(0xFF073A82)),
  missionLocale(Color(0xFF942258)),
  // Unreferenced colors
  loadingGreyPlaceholder(Color(0xFFE7E7E7));

  final Color color;

  const InternalAppColors(this.color);

  static final List<InternalAppColors> inspectedColors = [];
}
