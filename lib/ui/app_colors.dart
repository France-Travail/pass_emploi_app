import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/brand.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static Color primary = Brand.isBrsa() ? primaryDarken : Color(0xFF3B69D1);
  static Color primaryDarken = Color(0xFF274996);
  static Color primaryLighten = Color(0xFFEEF1F8);
  static Color primaryWithAlpha50 = Color(0x7A3B69D1);

  // Secondary colors
  static Color secondary = Color(0xFF0D7F50);
  static Color secondaryLighten = Color(0xFFE5F6EF);

  // Status colors
  static Color warning = Color(0xFFD31140);
  static Color warningLighten = Color(0xFFFDEAEF);
  static Color success = Color(0xFF033C24);
  static Color successLighten = Color(0xFFE5F6EF);
  static Color alert = Color(0xFFFF975C);
  static Color alertLighten = Color(0xFFFFC6A6);

  // Accent colors
  static Color accent1 = Color(0xFF950EFF);
  static Color accent1Lighten = Color(0xFFF4E5FF);
  static Color accent2 = Color(0xFF4A526D);
  static Color accent2Lighten = Color(0xFFF6F6F6);
  static Color accent3 = Color(0xFF0C7A81);
  static Color accent3Lighten = Color(0xFFDFFDFF);

  // Neutrals colors
  static Color contentColor = Color(0xFF161616);
  static Color disabled = Color(0xFF73758D);

  static Color grey100 = Color(0xFFF1F1F1);
  static Color grey500 = Color(0xFFB2B2B2);
  static Color grey700 = Color(0xFF878787);
  static Color grey800 = Color(0xFF646464);

  // Additional colors
  static Color additional1Lighten = Color(0xFFFFD88D);
  static Color additional1 = Color(0xFFFCBF49);
  static Color additional2Lighten = Color(0xFFDDFFED);
  static Color additional2 = Color(0xFF15616D);
  static Color additional3Lighten = Color(0xFFD2CEF6);
  static Color additional3 = Color(0xFF5149A8);
  static Color additional4Lighten = Color(0xFFDBEDF9);
  static Color additional4 = Color(0xFF2186C7);
  static Color additional5Lighten = Color(0xFFCEF0F1);
  static Color additional5 = Color(0xFF49BBBF);

  static Color favoriteHeartColor = Color(0xFFA44C66);
  static Color switchColor = Color(0xFF34C759);

  // Brands
  static Color poleEmploi = Color(0xFF073A82);
  static Color missionLocale = Color(0xFF942258);

  // Unreferenced colors
  static Color loadingGreyPlaceholder = Color(0xFFE7E7E7);
}
