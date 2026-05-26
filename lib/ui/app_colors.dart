import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/brand.dart';

class AppColors {
  AppColors._();

  // Background colors
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF262626);

  // Primary colors
  static final Color primary = Brand.isPassEmploi() ? primaryDarken : primaryCej;
  static const Color primaryCej = Color(0xFF3B69D1);
  static const Color primaryDarken = Color(0xFF274996);
  static const Color primaryDarkenStrong = Color(0xFF172B5A);
  static const Color primaryLighten = Color(0xFFEEF1F8);
  static const Color transparent = Color(0x00000000);

  // Status colors
  static const Color warning = Color(0xFFD31140);
  static const Color warningLighten = Color(0xFFFDEAEF);
  static const Color success = Color(0xFF0D7F50);
  static const Color successDarken = Color(0xFF033C24);
  static const Color successLighten = Color(0xFFE5F6EF);
  static const Color alert = Color(0xFFFF975C);
  static const Color alertLighten = Color(0xFFFFC6A6);

  // Accent colors
  static const Color accent1 = Color(0xFF950EFF);
  static const Color accent1Lighten = Color(0xFFF4E5FF);
  static const Color accent2 = Color(0xFF4A526D);
  static const Color accent2Lighten = Color(0xFFF6F6F6);
  static const Color accent3 = Color(0xFF0C7A81);
  static const Color accent3Lighten = Color(0xFFDFFDFF);

  // Neutrals colors
  static const Color contentLight = Color(0xFF161616);
  static const Color contentDark = Color(0xFFF1F1F1);
  static const Color contentOnPrimary = Color(0xFFFFFFFF);
  static const Color disabled = Color(0xFF73758D);

  static const Color grey100Light = Color(0xFFF1F1F1);
  static const Color grey500Light = Color(0xFFB3B3B3);
  static const Color grey700Light = Color(0xFF878787);
  static const Color grey800Light = Color(0xFF646464);

  static const Color grey100Dark = Color(0xFF161616);
  static const Color grey500Dark = Color(0xFF4D4D4D);
  static const Color grey700Dark = Color(0xFF737373);
  static const Color grey800Dark = Color(0xFF999999);

  // Additional colors
  static const Color additional1Lighten = Color(0xFFFFD88D);
  static const Color additional1 = Color(0xFFFCBF49);
  static const Color additional2Lighten = Color(0xFFDDFFED);
  static const Color additional2 = Color(0xFF15616D);
  static const Color additional3Lighten = Color(0xFFD2CEF6);
  static const Color additional3 = Color(0xFF5149A8);
  static const Color additional4Lighten = Color(0xFFDBEDF9);
  static const Color additional4 = Color(0xFF2186C7);
  static const Color additional5Lighten = Color(0xFFCEF0F1);
  static const Color additional5 = Color(0xFF49BBBF);
  static const Color additional6 = Color(0xFFBC7CEB);

  // Gradients
  static List<Color> gradientPrimary = Brand.isPassEmploi()
      ? [
          primaryDarkenStrong,
          primaryDarken,
        ]
      : [
          Color(0xFF3B69D1),
          Color(0xFF1E366B),
        ];

  // Solution gradients
  static List<Color> gradientOffre = [
    Color(0xFF274996),
    Color(0xFF3B69D1),
  ];
  static List<Color> gradientAlternance = [
    Color(0xFF172B5A),
    Color(0xFF2186C7),
  ];
  static List<Color> gradientImmersion = [
    Color(0xFF5149A8),
    Color(0xFF603CBC),
    Color(0xFF950EFF),
  ];
  static List<Color> gradientServiceCivique = [
    Color(0xFF15616D),
    Color(0xFF0C7A81),
  ];

  static List<Color> gradientSecondary = [
    primary,
    accent1,
  ];

  static List<Color> gradientTertiary = [
    accent1,
    Color(0xFF0C1730),
  ];
}

extension AppColorsContext on BuildContext {
  Color get bg => isDarkTheme ? AppColors.bgDark : AppColors.bgLight;
  Color get content => isDarkTheme ? AppColors.contentDark : AppColors.contentLight;
  Color get grey100 => isDarkTheme ? AppColors.grey100Dark : AppColors.grey100Light;
  Color get grey500 => isDarkTheme ? AppColors.grey500Dark : AppColors.grey500Light;
  Color get grey700 => isDarkTheme ? AppColors.grey700Dark : AppColors.grey700Light;
  Color get grey800 => isDarkTheme ? AppColors.grey800Dark : AppColors.grey800Light;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}

class AppColorsSpecifics {
  static Color acceuilBgColor(BuildContext context) {
    if (context.isDarkTheme) {
      return context.grey100;
    }
    return Brand.isCej() ? AppColors.primary : AppColors.primaryDarkenStrong;
  }

  static List<Color> acceuilBgGradient(BuildContext context) {
    if (context.isDarkTheme) {
      return [context.grey100, context.grey100];
    }
    return AppColors.gradientPrimary;
  }

  static Color primaryButtonForegroundColor(BuildContext context) {
    return context.isDarkTheme ? AppColors.primaryDarken : AppColors.contentOnPrimary;
  }

  static Color primaryButtonBackgroundColor(BuildContext context) {
    return context.isDarkTheme ? AppColors.primaryLighten : AppColors.primary;
  }

  static Color profileButtonForegroundColor(BuildContext context) {
    if (context.isDarkTheme) {
      return AppColors.primaryDarken;
    }
    return Brand.isCej() ? AppColors.contentOnPrimary : AppColors.primary;
  }

  static Color profileButtonBackgroundColor(BuildContext context) {
    if (context.isDarkTheme) {
      return AppColors.primaryLighten;
    }
    return Brand.isCej() ? AppColors.primary : context.grey100;
  }
}
