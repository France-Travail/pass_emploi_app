import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart' hide DsfrNotice;
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_app_bar.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_notice.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';

class OnboardingQuestionnaireUnderAgePage extends StatelessWidget {
  const OnboardingQuestionnaireUnderAgePage({super.key});

  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (_) => const OnboardingQuestionnaireUnderAgePage());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
            appBar: OnboardingQuestionnaireAppBar(onBack: () => Navigator.of(context).pop()),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Margins.spacing_base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Illustration décorative : l'émoji ne suit pas la taille du texte pour rester dans sa tuile.
                    Center(
                      child: ExcludeSemantics(
                        child: MediaQuery.withNoTextScaling(
                          child: const EmojiTile(
                            emoji: '⏳',
                            backgroundColor: DsfrColors.blueCumulus950,
                            size: 96,
                            emojiSize: 46,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Margins.spacing_m),
                    AutoFocusA11y(
                      child: Semantics(
                        header: true,
                        child: Text(
                          Strings.onboardingQuestionnaireUnderAgeTitle,
                          textAlign: TextAlign.center,
                          style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
                        ),
                      ),
                    ),
                    const SizedBox(height: Margins.spacing_s),
                    Text(
                      Strings.onboardingQuestionnaireUnderAgeDescription,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                    const SizedBox(height: Margins.spacing_m),
                    DsfrNotice(
                      titre: Strings.onboardingQuestionnaireUnderAgeNoticeTitle,
                      description: Strings.onboardingQuestionnaireUnderAgeNoticeDescription,
                    ),
                    const SizedBox(height: Margins.spacing_xl),
                    DsfrButton(
                      label: Strings.understood,
                      variant: DsfrButtonVariant.primary,
                      size: DsfrComponentSize.lg,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
