import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pass_emploi_app/models/feature_flip.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_tag.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

class IaFtCard extends StatelessWidget {
  const IaFtCard({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AbTestingIaFt>(
        converter: (store) => store.state.featureFlipState.featureFlip.abTestingIaFt,
        builder: (context, abTestingIaFt) {
          return Semantics(
            button: true,
            child: CardContainer(
              onTap: onPressed,
              gradient: LinearGradient(
                colors: AppColors.gradientSecondary,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: ExcludeSemantics(
                      child: SvgPicture.asset(Drawables.iaFtIllustration),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardTag(
                        backgroundColor: Colors.white,
                        text: Strings.newFeature,
                        contentColor: AppColors.primaryDarken,
                        icon: AppIcons.bolt_outlined,
                      ),
                      SizedBox(height: Margins.spacing_s),
                      Text(
                          abTestingIaFt == AbTestingIaFt.versionA
                              ? Strings.topDemarchesTitle
                              : Strings.topDemarchesTitleB,
                          style: TextStyles.textBaseBold.copyWith(color: Colors.white)),
                      if (abTestingIaFt == AbTestingIaFt.versionA) ...[
                        SizedBox(height: Margins.spacing_s),
                        Text(Strings.topDemarchesSubtitle,
                            style: TextStyles.textSRegular().copyWith(color: Colors.white)),
                      ],
                      SizedBox(height: Margins.spacing_s),
                      _FakeTextField(),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

class _FakeTextField extends StatelessWidget {
  const _FakeTextField();

  @override
  Widget build(BuildContext context) {
    final contentColor = AppColors.grey800;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Margins.spacing_base, vertical: Margins.spacing_s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimens.radius_base),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              Strings.topDemarchesHint,
              style: TextStyles.textSRegular(color: contentColor),
            ),
          ),
          Container(
            padding: EdgeInsets.all(Margins.spacing_xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey700, width: 2),
            ),
            child: Icon(Icons.mic_rounded, color: AppColors.grey700),
          ),
        ],
      ),
    );
  }
}
