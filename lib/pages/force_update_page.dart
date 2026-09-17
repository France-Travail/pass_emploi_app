import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/presentation/force_update_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/drawables/app_logo.dart';
import 'package:pass_emploi_app/widgets/dsfr/bloc_marque.dart';

class ForceUpdatePage extends StatelessWidget {
  final Flavor _flavor;

  ForceUpdatePage(this._flavor);

  @override
  Widget build(BuildContext context) {
    final platform = PlatformUtils.getPlatform;
    final brand = Brand.brand;
    final viewModel = ForceUpdateViewModel.create(brand, _flavor, platform);
    return MaterialApp(
      title: Strings.appName,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      home: Builder(
        builder: (context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
            child: Tracker(
              tracking: AnalyticsScreenNames.forceUpdate,
              child: Scaffold(
                backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
                appBar: AppBar(
                  toolbarHeight: 56,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
                  title: Semantics(
                    header: true,
                    child: Text(
                      Strings.updateTitle,
                      style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(DsfrSpacings.s2w),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: BlocMarque(),
                      ),
                      const Expanded(child: AppLogo()),
                      Text(
                        viewModel.label,
                        style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textDefaultGrey(context)),
                        textAlign: TextAlign.center,
                      ),
                      if (viewModel.withCallToAction) ...[
                        const SizedBox(height: DsfrSpacings.s3w),
                        Semantics(
                          link: true,
                          child: SizedBox(
                            width: double.infinity,
                            child: DsfrButton(
                              label: Strings.updateButton,
                              variant: DsfrButtonVariant.primary,
                              size: DsfrComponentSize.lg,
                              icon: DsfrIcons.systemExternalLinkLine,
                              onPressed: () => launchExternalUrl(viewModel.storeUrl),
                            ),
                          ),
                        ),
                      ],
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
