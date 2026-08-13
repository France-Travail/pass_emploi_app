import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class OffreNotFoundPage extends StatelessWidget {
  const OffreNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.offreNotFound,
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        appBar: AppBar(
          toolbarHeight: PrimaryAppBar.toolBarHeight,
          titleSpacing: DsfrSpacings.s2w,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
          iconTheme: IconThemeData(color: DsfrColorDecisions.textTitleGrey(context)),
          title: Semantics(
            header: true,
            child: Tooltip(
              message: Strings.offreNotFoundTitle,
              excludeFromSemantics: true,
              child: Text(
                Strings.offreNotFoundTitle,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        Drawables.illustrationCompass,
                        width: 160,
                        height: 160,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const SizedBox(height: DsfrSpacings.s3w),
                    Text(
                      Strings.offreNotFoundBodyTitle,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      Strings.offreNotFoundBodySubtitle,
                      textAlign: TextAlign.center,
                      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                    const SizedBox(height: DsfrSpacings.s3w),
                    DsfrButton(
                      label: Strings.close,
                      variant: DsfrButtonVariant.primary,
                      size: DsfrComponentSize.lg,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: DsfrSpacings.s4w),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
