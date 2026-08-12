import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/create_demarche_success_page.dart';
import 'package:pass_emploi_app/pages/offre_emploi/offre_emploi_details_page.dart';
import 'package:pass_emploi_app/presentation/offre_suivie_form_viewmodel.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/create_user_action_confirmation_offre_suivi_page.dart';

class OffreSuivieForm extends StatelessWidget {
  const OffreSuivieForm({
    super.key,
    required this.offreId,
    required this.showOffreDetails,
    required this.trackingSource,
    required this.showPrimaryBackground,
  });

  final bool showOffreDetails;
  final bool showPrimaryBackground;
  final String offreId;
  final OffreSuiviTrackingSource trackingSource;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OffreSuivieFormViewmodel>(
      converter: (store) => OffreSuivieFormViewmodel.create(store, offreId, showOffreDetails),
      onInit: (store) => PassEmploiMatomoTracker.instance.trackCandidature(
        source: trackingSource,
        event: OffreSuiviTrackingOption.affiche,
      ),
      distinct: true,
      builder: (context, viewModel) {
        return SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: showPrimaryBackground
                  ? DsfrColorDecisions.borderOpenBlueFrance(context)
                  : DsfrColorDecisions.backgroundContrastGrey(context),
              borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DsfrSpacings.s2w),
              child: AnimatedSwitcher(
                duration: AnimationDurations.fast,
                child: viewModel.showConfirmation
                    ? _Confirmation(viewModel)
                    : _Content(viewModel, offreId, trackingSource),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation(this.viewModel);
  final OffreSuivieFormViewmodel viewModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              DsfrIcons.systemCheckboxCircleLine,
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              Strings.merciPourVotreReponse,
              textAlign: TextAlign.center,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            if (viewModel.onCreateActionOrDemarche != null) ...[
              if (viewModel.confirmationMessage != null) ...[
                const SizedBox(height: DsfrSpacings.s1w),
                Text(
                  viewModel.confirmationMessage!,
                  textAlign: TextAlign.center,
                  style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                ),
              ],
              const SizedBox(height: DsfrSpacings.s2w),
              SizedBox(
                width: double.infinity,
                child: DsfrButton(
                  label: viewModel.onCreateActionOrDemarcheLabel,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.md,
                  onPressed: () {
                    viewModel.onCreateActionOrDemarche?.call();
                    viewModel.onHideForever();
                    if (viewModel.useDemarche) {
                      PassEmploiMatomoTracker.instance.trackEvent(
                        eventCategory: AnalyticsEventNames.createDemarcheEventCategory,
                        action: AnalyticsEventNames.createDemarcheFromOffreSuiviAction,
                      );
                      Navigator.of(context).push(CreateDemarcheSuccessPage.route(CreateDemarcheSource.fromReferentiel));
                    } else {
                      PassEmploiMatomoTracker.instance.trackEvent(
                        eventCategory: AnalyticsEventNames.createActionEventCategory,
                        action: AnalyticsEventNames.createActionResultFromOffreSuiviAction,
                      );
                      Navigator.of(context).push(CreateUserActionConfirmationOffreSuiviPage.route());
                    }
                  },
                ),
              ),
            ],
            if (viewModel.onNextOffer != null) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              SizedBox(
                width: double.infinity,
                child: DsfrButton(
                  label: Strings.seeNextOffer,
                  variant: DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.md,
                  onPressed: viewModel.onNextOffer,
                ),
              ),
            ],
          ],
        ),
        Positioned(
          top: -DsfrSpacings.s1w,
          right: -DsfrSpacings.s1w,
          child: DsfrButton(
            icon: DsfrIcons.systemCloseLine,
            iconSemanticLabel: Strings.close,
            variant: DsfrButtonVariant.tertiaryWithoutBorder,
            size: DsfrComponentSize.sm,
            onPressed: viewModel.onHideForever,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.viewModel, this.offreId, this.trackingSource);
  final OffreSuivieFormViewmodel viewModel;
  final String offreId;
  final OffreSuiviTrackingSource trackingSource;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.dateConsultation != null) ...[
          Text(
            viewModel.dateConsultation!,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
        ],
        if (viewModel.offreLien != null) ...[
          _OffreLien(offreId: offreId, fromAlternance: viewModel.fromAlternance, offreLien: viewModel.offreLien!),
          const SizedBox(height: DsfrSpacings.s1w),
        ],
        Text(
          Strings.ouEnEtesVous,
          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        _Options(viewModel, trackingSource),
      ],
    );
  }
}

class _OffreLien extends StatelessWidget {
  const _OffreLien({required this.offreId, required this.fromAlternance, required this.offreLien});
  final String offreId;
  final String offreLien;
  final bool fromAlternance;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: DsfrLink(
        label: offreLien,
        onTap: () => Navigator.of(context).push(
          OffreEmploiDetailsPage.materialPageRoute(offreId, fromAlternance: fromAlternance),
        ),
      ),
    );
  }
}

enum _OffreSuivieStatus { applied, interested, notInterested, notYetPostuled }

class _Options extends StatefulWidget {
  const _Options(this.viewModel, this.trackingSource);
  final OffreSuivieFormViewmodel viewModel;
  final OffreSuiviTrackingSource trackingSource;

  @override
  State<_Options> createState() => _OptionsState();
}

class _OptionsState extends State<_Options> {
  void trackEvent(OffreSuiviTrackingOption event) =>
      PassEmploiMatomoTracker.instance.trackCandidature(source: widget.trackingSource, event: event);

  _OffreSuivieStatus? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsfrRadioButton<_OffreSuivieStatus>(
                label: Strings.jaiPostule,
                value: _OffreSuivieStatus.applied,
                groupValue: _selectedValue,
                size: DsfrComponentSize.md,
                onChanged: (status) {
                  if (status == null) return;
                  trackEvent(OffreSuiviTrackingOption.postule);
                  selectValue(status);
                  widget.viewModel.onPostule();
                },
              ),
              if (widget.viewModel.onInteresse != null) ...[
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrRadioButton<_OffreSuivieStatus>(
                  label: Strings.caMinteresse,
                  value: _OffreSuivieStatus.interested,
                  groupValue: _selectedValue,
                  size: DsfrComponentSize.md,
                  onChanged: (status) {
                    if (status == null) return;
                    trackEvent(OffreSuiviTrackingOption.interesse);
                    selectValue(status);
                    widget.viewModel.onInteresse?.call();
                  },
                ),
              ],
              if (widget.viewModel.onNotYetPostuled != null) ...[
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrRadioButton<_OffreSuivieStatus>(
                  label: Strings.notYetPostuled,
                  value: _OffreSuivieStatus.notYetPostuled,
                  groupValue: _selectedValue,
                  size: DsfrComponentSize.md,
                  onChanged: (status) {
                    if (status == null) return;
                    trackEvent(OffreSuiviTrackingOption.interesse);
                    selectValue(status);
                    widget.viewModel.onNotYetPostuled?.call();
                  },
                ),
              ],
              const SizedBox(height: DsfrSpacings.s1w),
              DsfrRadioButton<_OffreSuivieStatus>(
                label: Strings.caNeMinteressePas,
                value: _OffreSuivieStatus.notInterested,
                groupValue: _selectedValue,
                size: DsfrComponentSize.md,
                onChanged: (status) {
                  if (status == null) return;
                  trackEvent(OffreSuiviTrackingOption.notInterrested);
                  selectValue(status);
                  widget.viewModel.onNotInterested();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectValue(_OffreSuivieStatus value) {
    setState(() {
      _selectedValue = value;
    });
  }
}
