import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_emploi_app/features/developer_option/activation/developer_options_action.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/biseau_background.dart';
import 'package:pass_emploi_app/widgets/drawables/app_logo.dart';
import 'package:pass_emploi_app/widgets/drawables/cej_wordmark.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:pass_emploi_app/wrappers/package_info_wrapper.dart';

class SplashScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: PackageInfoWrapper.getVersion(),
      builder: (context, snapshot) {
        final appVersion = snapshot.data;
        final page = Scaffold(
          backgroundColor: Brand.isCej() ? AppColors.bgLight : context.bg,
          body: Stack(
            children: [
              if (!Brand.isCej()) BiseauBackground(),
              Center(
                child: Brand.isCej()
                    ? const CejWordmark()
                    // A11y 1.2 : le logo est le seul élément qui nomme l'application sur cet écran.
                    : AppLogo(excludeFromSemantics: false),
              ),
              if (appVersion != null)
                _AppVersion(appVersion, onLightBackground: Brand.isCej()),
            ],
          ),
        );
        if (!Brand.isCej()) return page;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: page,
        );
      },
    );
  }
}

class _AppVersion extends StatelessWidget {
  final String _appVersion;
  final bool onLightBackground;

  const _AppVersion(this._appVersion, {required this.onLightBackground});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onDoubleTap: () {
          context.dispatch(DeveloperOptionsDeleteAllPrefsAction());
          showSnackBarWithSystemError(
            context,
            "Killez - voire supprimer - l'app",
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(Margins.spacing_base),
          child: Text(
            _appVersion,
            style: TextStyles.textBaseBoldWithColor(
              onLightBackground
                  ? AppColors.contentLight
                  : AppColors.contentOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
