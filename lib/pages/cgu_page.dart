import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/cgu_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/primary_rounded_bottom_background.dart';
import 'package:pass_emploi_app/widgets/sepline.dart';

class CguPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.cguPage,
      child: StoreConnector<AppState, CguPageViewModel>(
        builder: (context, viewModel) => _Scaffold(
          body: switch (viewModel.displayState) {
            CguNeverAcceptedDisplayState() => SizedBox.shrink(),
            final CguUpdateRequiredDisplayState vm => SizedBox.shrink(),
            null => SizedBox.shrink(),
          },
        ),
        converter: CguPageViewModel.create,
        distinct: true,
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Widget body;

  const _Scaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PrimaryRoundedBottomBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: Margins.spacing_m,
                right: Margins.spacing_m,
                top: Margins.spacing_huge,
                bottom: Margins.spacing_l,
              ),
              child: _Body(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatefulWidget {
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _cguAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CardContainer(
            padding: const EdgeInsets.all(Margins.spacing_m),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Bienvenue sur l’application du CEJ',
                    style: TextStyles.textLBold(color: AppColors.primary),
                  ),
                  SizedBox(height: Margins.spacing_m),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "L’utilisation de notre service est soumise à l’acception préalable de nos ",
                          style: TextStyles.textBaseRegular,
                        ),
                        TextSpan(
                          text: "↗ Conditions Générales d’Utilisation",
                          style: TextStyles.textBaseRegular.copyWith(
                            color: AppColors.contentColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ". Ces conditions définissent ",
                          style: TextStyles.textBaseRegular,
                        ),
                        TextSpan(
                          text: "vos droits et obligations en tant qu'utilisateur ",
                          style: TextStyles.textBaseBold,
                        ),
                        TextSpan(
                          text: "de notre application.",
                          style: TextStyles.textBaseRegular,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Margins.spacing_m),
                  SepLine(
                    Margins.spacing_m,
                    Margins.spacing_m,
                    color: AppColors.grey100,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "J’ai lu et j’accepte les",
                                style: TextStyles.textBaseRegular,
                              ),
                              TextSpan(
                                text: "  ↗ Conditions Générales d’Utilisation",
                                style: TextStyles.textBaseRegular.copyWith(
                                  color: AppColors.contentColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: Margins.spacing_m),
                      Semantics(
                        label: 'TODO',
                        child: Switch(
                          value: _cguAccepted,
                          onChanged: (value) => setState(() => _cguAccepted = value),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Margins.spacing_base),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(AppIcons.error_rounded, color: AppColors.warning),
                      SizedBox(width: Margins.spacing_s),
                      Expanded(
                        child: Text(
                          'Acceptez les Conditions Générales d’Utilisation pour utiliser l’application.',
                          style: TextStyles.textXsRegular(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: Margins.spacing_l),
        SizedBox(
          width: double.infinity,
          child: PrimaryActionButton(
            label: 'Valider',
            onPressed: () {},
          ),
        ),
        SizedBox(height: Margins.spacing_s),
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            backgroundColor: Colors.transparent,
            label: 'Refuser et se déconnecter',
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
