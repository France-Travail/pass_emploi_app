import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class OffreNotFoundPage extends StatelessWidget {
  const OffreNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.offreNotFound,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: SecondaryAppBar(title: Strings.offreNotFoundTitle, backgroundColor: Colors.white),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: SizedBox(height: 200, width: 200, child: Image.asset(Drawables.notFound))),
                  SizedBox(height: Margins.spacing_xl),
                  Text(Strings.offreNotFoundBodyTitle, textAlign: TextAlign.center, style: TextStyles.textMBold),
                  SizedBox(height: Margins.spacing_m),
                  Text(
                    Strings.offreNotFoundBodySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyles.textSRegular(),
                  ),
                  SizedBox(height: Margins.spacing_m),
                  PrimaryActionButton(label: Strings.close, onPressed: () => Navigator.pop(context)),
                  SizedBox(height: Margins.spacing_xx_huge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
