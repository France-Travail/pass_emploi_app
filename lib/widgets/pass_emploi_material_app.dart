import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pass_emploi_app/ui/theme.dart';

class PassEmploiMaterialApp extends MaterialApp {
  PassEmploiMaterialApp({
    super.key,
    super.navigatorKey,
    super.scaffoldMessengerKey,
    super.home,
    super.routes,
    super.initialRoute,
    super.onGenerateRoute,
    super.onGenerateInitialRoutes,
    super.onUnknownRoute,
    super.navigatorObservers,
    super.title,
    super.onGenerateTitle,
    super.color,
    super.highContrastTheme,
    super.highContrastDarkTheme,
    super.themeMode,
    super.locale,
    super.localeListResolutionCallback,
    super.localeResolutionCallback,
    super.debugShowMaterialGrid,
    super.showPerformanceOverlay,
    super.checkerboardRasterCacheImages,
    super.checkerboardOffscreenLayers,
    super.showSemanticsDebugger,
    super.debugShowCheckedModeBanner,
    super.shortcuts,
    super.actions,
    super.restorationScopeId,
    super.scrollBehavior,
    super.useInheritedMediaQuery,
    Widget Function(BuildContext, Widget?)? builder,
  }) : super(
         builder: (context, child) {
           final wrappedChild = _wrapWithAndroidSystemInsets(child);
           return builder?.call(context, wrappedChild) ?? wrappedChild;
         },
         theme: PassEmploiTheme.data,
         darkTheme: PassEmploiTheme.darkData,
         localizationsDelegates: [
           GlobalMaterialLocalizations.delegate,
           GlobalWidgetsLocalizations.delegate,
           GlobalCupertinoLocalizations.delegate,
         ],
         supportedLocales: [
           Locale('en'),
           Locale('fr'),
         ],
       );

  // UI fix: Android 15+ (targetSdk 35+) renders apps edge-to-edge by default.
  static Widget _wrapWithAndroidSystemInsets(Widget? child) {
    final content = child ?? const SizedBox.shrink();
    if (defaultTargetPlatform != TargetPlatform.android) {
      return content;
    }
    return SafeArea(
      top: false,
      child: content,
    );
  }
}
