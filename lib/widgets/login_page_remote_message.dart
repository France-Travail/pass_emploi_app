import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.info_rounded, color: AppColors.primary),
              SizedBox(width: Margins.spacing_s),
              Expanded(
                child: Column(
                  children: [
                    Text(loginPageRemoteMessage.title, style: TextStyles.textSBold.copyWith(color: AppColors.primary)),
                    SizedBox(height: Margins.spacing_s),
                    Text(loginPageRemoteMessage.description, style: TextStyles.textSRegular(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
