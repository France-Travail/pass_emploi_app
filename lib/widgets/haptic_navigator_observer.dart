import 'package:flutter/material.dart';
import 'package:gaimon/gaimon.dart';

class HapticNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    Gaimon.soft();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    Gaimon.soft();
  }
}

