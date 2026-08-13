import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/pages/postuler_confirmation_page.dart';
import 'package:pass_emploi_app/pages/simple_confirmation_page.dart';
import 'package:pass_emploi_app/presentation/offre_suivie_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';

class OffreSuivieBottomSheet extends StatelessWidget {
  const OffreSuivieBottomSheet({super.key, required this.offreId});
  final String offreId;

  static Future<void> show(BuildContext context, String offreId) async {
    await showPassEmploiBottomSheet<void>(
      context: context,
      builder: (context) => OffreSuivieBottomSheet(offreId: offreId),
    );
  }

  void trackEvent(OffreSuiviTrackingOption event) => PassEmploiMatomoTracker.instance.trackCandidature(
    source: OffreSuiviTrackingSource.bottomSheet,
    event: event,
  );

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OffreSuivieBottomSheetViewModel>(
      converter: (store) => OffreSuivieBottomSheetViewModel.create(store, offreId),
      onInit: (_) => trackEvent(OffreSuiviTrackingOption.affiche),
      builder: (context, viewModel) {
        return _DisposeWrapper(
          onDispose: viewModel.onNotInterested,
          child: FiltresBottomSheet(
            title: Strings.offreSuivieBottomSheetTitle,
            maxHeightFactor: 0.7,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsfrButton(
                  label: Strings.offreSuivieOuiPostule,
                  icon: DsfrIcons.systemCheckboxCircleLine,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.lg,
                  onPressed: () {
                    trackEvent(OffreSuiviTrackingOption.postule);
                    viewModel.onPostule();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(PostulerConfirmationPage.route(offreId));
                  },
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrButton(
                  label: Strings.offreSuiviePasEncore,
                  icon: DsfrIcons.businessBookmarkLine,
                  variant: DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.lg,
                  onPressed: () {
                    trackEvent(OffreSuiviTrackingOption.interesse);
                    viewModel.onInteresse();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(SimpleConfirmationPage.favoris());
                  },
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrButton(
                  label: Strings.offreSuivieNonPasInteresse,
                  icon: DsfrIcons.systemDeleteBinLine,
                  variant: DsfrButtonVariant.tertiary,
                  size: DsfrComponentSize.lg,
                  onPressed: () {
                    trackEvent(OffreSuiviTrackingOption.notInterrested);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DisposeWrapper extends StatefulWidget {
  const _DisposeWrapper({required this.onDispose, required this.child});
  final void Function() onDispose;
  final Widget child;

  @override
  State<_DisposeWrapper> createState() => __DisposeWrapperState();
}

class __DisposeWrapperState extends State<_DisposeWrapper> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
