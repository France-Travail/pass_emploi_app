import 'package:flutter/widgets.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';

class LoginPageRemoteMessageCard extends StatelessWidget {
  const LoginPageRemoteMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, LoginPageRemoteMessage?>(
      converter: (store) => store.state.featureFlipState.featureFlip.loginPageMessage,
      builder: (context, loginPageRemoteMessage) {
        if (loginPageRemoteMessage == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: Margins.spacing_m),
          child: RemoteMessageWidget(remoteMessage: loginPageRemoteMessage),
        );
      },
    );
  }
}

class RemoteMessageWidget extends StatelessWidget {
  final RemoteMessage remoteMessage;

  const RemoteMessageWidget({required this.remoteMessage});

  @override
  Widget build(BuildContext context) {
    return DsfrAlert(
      type: DsfrAlertType.info,
      title: remoteMessage.title,
      description: DsfrAlertDescriptionText(remoteMessage.description),
    );
  }
}
