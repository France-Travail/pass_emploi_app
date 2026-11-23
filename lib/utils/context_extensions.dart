import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';
import 'package:pass_emploi_app/features/tracking/tracking_evenement_engagement_action.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

extension EvenementEngagementExtension on BuildContext {
  void trackEvenementEngagement(EvenementEngagement evenementEngagement) {
    dispatch(TrackingEvenementEngagementAction(evenementEngagement));
  }
}

extension StoreExtension on BuildContext {
  void dispatch(dynamic action) => StoreProvider.of<AppState>(this).dispatch(action);

  /// Message d'erreur d'un appel à l'API : pendant une limite de débit (429), le message dédié le remplace.
  String apiErrorMessage(String message) {
    final tooManyRequests = StoreProvider.of<AppState>(this, listen: false).state.isTooManyRequests();
    return tooManyRequests ? Strings.tooManyRequestsError : message;
  }
}

extension NavigatorExtension on NavigatorState {
  void popAll() => popUntil((route) => route.settings.name == Navigator.defaultRouteName);
}
