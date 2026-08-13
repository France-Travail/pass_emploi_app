import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/rendezvous/details/rendezvous_details_actions.dart';
import 'package:pass_emploi_app/features/session_milo_details/session_milo_details_actions.dart';
import 'package:pass_emploi_app/pages/auto_desinscription_page.dart';
import 'package:pass_emploi_app/pages/auto_inscription_page.dart';
import 'package:pass_emploi_app/pages/chat/chat_partage_bottom_sheet.dart';
import 'package:pass_emploi_app/pages/chat/chat_partage_event_page.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_details_view_model.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/text_with_clickable_links.dart';
import 'package:redux/redux.dart';

class RendezvousDetailsPage extends StatefulWidget {
  final String _rendezvousId;
  final RendezvousStateSource _source;
  final RendezvousDetailsViewModel Function(Store<AppState>) _converter;
  static final _platform = PlatformUtils.getPlatform;

  RendezvousDetailsPage._(this._rendezvousId, this._source, this._converter)
    : super();

  static Future<void> show(
    BuildContext context,
    RendezvousStateSource source,
    String rendezvousId,
  ) {
    return showDsfrBottomSheet(
      context: context,
      name: AnalyticsScreenNames.rendezvousDetails,
      builder: (context) => RendezvousDetailsPage._(
        rendezvousId,
        source,
        (store) => RendezvousDetailsViewModel.create(
          store: store,
          source: source,
          rdvId: rendezvousId,
          platform: _platform,
        ),
      ),
    );
  }

  @override
  State<RendezvousDetailsPage> createState() => _RendezvousDetailsPageState();
}

class _RendezvousDetailsPageState extends State<RendezvousDetailsPage> {
  bool _hasBeenTracked = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RendezvousDetailsViewModel>(
      onInit: _onInit,
      converter: widget._converter,
      builder: _sheet,
      onDispose: (store) {
        widget._source == RendezvousStateSource.noSource
            ? store.dispatch(RendezvousDetailsResetAction())
            : {};
        widget._source == RendezvousStateSource.sessionMiloDetails
            ? store.dispatch(SessionMiloDetailsResetAction())
            : {};
      },
      distinct: true,
    );
  }

  dynamic _onInit(Store<AppState> store) {
    return switch (widget._source) {
      RendezvousStateSource.sessionMiloDetails => store.dispatch(
        SessionMiloDetailsRequestAction(widget._rendezvousId),
      ),
      RendezvousStateSource.noSource => store.dispatch(
        RendezvousDetailsRequestAction(widget._rendezvousId),
      ),
      _ => {},
    };
  }

  Widget _sheet(BuildContext context, RendezvousDetailsViewModel viewModel) {
    _trackPageOnRendezvousRetrievalFromState(viewModel);
    return DsfrBottomSheet(
      actions: _actions(context, viewModel),
      child: _body(context, viewModel),
    );
  }

  Widget? _actions(BuildContext context, RendezvousDetailsViewModel viewModel) {
    if (viewModel.displayState != DisplayState.CONTENT) return null;
    return switch (viewModel.rdvCta) {
      null => null,
      final RendezVousAutoInscription rendezvousCta => _AutoInscriptionButton(
        rendezvousCta,
      ),
      final RendezVousAnnulerInscription rendezvousCta =>
        _AnnulerInscriptionButton(
          rendezvousCta,
          widget._source,
          widget._rendezvousId,
        ),
      final RendezVousShareToConseillerDemandeInscription rendezvousCta =>
        _DemandeInscriptionButton(rendezvousCta),
      final RendezVousShareToConseiller rendezvousCta => _ShareButton(
        rendezvousCta,
      ),
    };
  }

  Widget _body(BuildContext context, RendezvousDetailsViewModel viewModel) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _content(context, viewModel),
      DisplayState.LOADING => const Center(child: CircularProgressIndicator()),
      _ => Retry(Strings.rendezVousDetailsError, () => viewModel.onRetry()),
    };
  }

  Widget _content(BuildContext context, RendezvousDetailsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.assetImage != null) ...[
          ExcludeSemantics(
            child: _CardIllustration(imagePath: viewModel.assetImage),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        if (viewModel.withDateDerniereMiseAJour != null) ...[
          DsfrAlert(
            type: DsfrAlertType.info,
            description: DsfrAlertDescriptionText(
              viewModel.withDateDerniereMiseAJour!,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            DsfrCategoryTag.evenement(
              label: viewModel.tag,
              typeCode: viewModel.typeCode,
            ),
            if (viewModel.isInscrit)
              DsfrCategoryTag.secondary(
                label: Strings.eventVousEtesDejaInscrit,
                icon: DsfrIcons.systemCheckboxCircleFill,
              ),
            if (viewModel.isComplet) DsfrStatusBadge.complet(),
            if (viewModel.isAnnule) DsfrStatusBadge.canceled(),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        _Header(viewModel),
        if (viewModel.withModalityPart) _Modality(viewModel),
        if (viewModel.withDescriptionPart) _DescriptionPart(viewModel),
        _Separator(),
        if (viewModel.withAnimateur != null) ...[
          _AnimateurPart(viewModel.withAnimateur!),
          _Separator(),
        ],
        _ConseillerPart(viewModel),
        if (viewModel.withIfAbsentPart) _InformIfAbsent(),
      ],
    );
  }

  void _trackPageOnRendezvousRetrievalFromState(
    RendezvousDetailsViewModel viewModel,
  ) {
    if (!_hasBeenTracked && viewModel.trackingPageName != null) {
      PassEmploiMatomoTracker.instance.trackScreen(viewModel.trackingPageName!);
      _hasBeenTracked = true;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.viewModel);

  final RendezvousDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.title != null)
          Semantics(
            header: true,
            child: Text(
              viewModel.title!,
              style: DsfrTextStyle.headline5(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
            ),
          ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrDetailIconLine(
          icon: DsfrIcons.businessCalendarEventLine,
          text: viewModel.date,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrDetailIconLine(
          icon: DsfrIcons.systemTimeLine,
          text: viewModel.hourAndDuration,
          semanticsLabel: viewModel.hourAndDuration
              .toTimeAndDurationForScreenReaders(),
        ),
        if (viewModel.nombreDePlacesRestantes != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrDetailIconLine(
            icon: DsfrIcons.userUserLine,
            text: viewModel.nombreDePlacesRestantes!,
          ),
        ],
        if (viewModel.address != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrDetailIconLine(
            icon: DsfrIcons.mapMapPin2Line,
            text: viewModel.address!,
          ),
        ],
      ],
    );
  }
}

class _Modality extends StatelessWidget {
  const _Modality(this.viewModel);

  final RendezvousDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    _trackVisioButtonDisplay();
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.modality != null)
            Padding(
              padding: const EdgeInsets.only(
                top: DsfrSpacings.s1w,
                bottom: DsfrSpacings.s1v,
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: viewModel.modality!,
                      style: DsfrTextStyle.bodyMdBold(
                        color: DsfrColorDecisions.textTitleGrey(context),
                      ),
                    ),
                    if (viewModel.conseiller != null) ...[
                      TextSpan(
                        text: Strings.withConseiller,
                        style: DsfrTextStyle.bodyMd(
                          color: DsfrColorDecisions.textTitleGrey(context),
                        ),
                      ),
                      TextSpan(
                        text: viewModel.conseiller!,
                        style: DsfrTextStyle.bodyMdBold(
                          color: DsfrColorDecisions.textTitleGrey(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (viewModel.createur != null)
            Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
              child: _Createur(viewModel.createur!),
            ),
          if (_withInactiveVisioButton())
            Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
              child: DsfrButton(
                label: Strings.seeVisio,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.md,
              ),
            ),
          if (_withActiveVisioButton())
            Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
              child: DsfrButton(
                label: Strings.seeVisio,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.md,
                onPressed: () {
                  _trackVisioButtonClick();
                  launchExternalUrl(viewModel.visioRedirectUrl!);
                },
              ),
            ),
          if (viewModel.organism != null)
            Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
              child: Text(
                viewModel.organism!,
                style: DsfrTextStyle.bodyMdBold(
                  color: DsfrColorDecisions.textTitleGrey(context),
                ),
              ),
            ),
          if (viewModel.addressRedirectUri != null)
            Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
              child: DsfrLink(
                label: Strings.seeItinerary,
                icon: DsfrIcons.systemExternalLinkLine,
                onTap: () =>
                    launchExternalUrl(viewModel.addressRedirectUri!.toString()),
              ),
            ),
          if (viewModel.phone != null)
            Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
              child: Text(
                viewModel.phone!,
                style: DsfrTextStyle.bodyMd(
                  color: DsfrColorDecisions.textDefaultGrey(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _withActiveVisioButton() =>
      viewModel.visioButtonState == VisioButtonState.ACTIVE;

  bool _withInactiveVisioButton() =>
      viewModel.visioButtonState == VisioButtonState.INACTIVE;

  void _trackVisioButtonDisplay() {
    if (_withActiveVisioButton()) {
      PassEmploiMatomoTracker.instance.trackEvent(
        eventCategory: AnalyticsEventNames.rendezvousVisioCategory,
        action: AnalyticsEventNames.rendezvousVisioDisplayAction,
      );
    }
  }

  void _trackVisioButtonClick() {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.rendezvousVisioCategory,
      action: AnalyticsEventNames.rendezvousVisioClickAction,
    );
  }
}

class _DescriptionPart extends StatelessWidget {
  const _DescriptionPart(this.viewModel);

  final RendezvousDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Separator(),
        if (viewModel.theme != null)
          Text(
            viewModel.theme!,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        if (viewModel.description != null)
          Padding(
            padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
            child: TextWithClickableLinks(
              viewModel.description!,
              style: DsfrTextStyle.bodyMd(
                color: DsfrColorDecisions.textDefaultGrey(context),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimateurPart extends StatelessWidget {
  final String withAnimateur;

  const _AnimateurPart(this.withAnimateur);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.withAnimateurTitle,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
          child: TextWithClickableLinks(
            withAnimateur,
            style: DsfrTextStyle.bodyMd(
              color: DsfrColorDecisions.textDefaultGrey(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConseillerPart extends StatelessWidget {
  final RendezvousDetailsViewModel viewModel;

  const _ConseillerPart(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.withConseillerPresencePart)
          Text(
            viewModel.conseillerPresenceLabel,
            style: DsfrTextStyle.bodyMdBold(
              color: viewModel.conseillerPresenceColor,
            ),
          ),
        if (viewModel.dateLimiteAnnulation != null) ...[
          if (viewModel.withConseillerPresencePart)
            const SizedBox(height: DsfrSpacings.s2w),
          Text(
            viewModel.dateLimiteAnnulation!,
            style: DsfrTextStyle.bodyMd(
              color: DsfrColorDecisions.textMentionGrey(context),
            ),
          ),
        ],
        if (_withSepLine()) _Separator(),
        if (viewModel.commentTitle != null)
          Semantics(
            header: true,
            child: Text(
              viewModel.commentTitle!,
              style: DsfrTextStyle.bodyMdBold(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
            ),
          ),
        if (viewModel.comment != null)
          Padding(
            padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
            child: TextWithClickableLinks(
              viewModel.comment!,
              style: DsfrTextStyle.bodyMd(
                color: DsfrColorDecisions.textDefaultGrey(context),
              ),
            ),
          ),
        if (_withEndSepLine()) _Separator(),
      ],
    );
  }

  bool _withSepLine() =>
      (viewModel.withConseillerPresencePart ||
          viewModel.dateLimiteAnnulation != null) &&
      viewModel.comment != null;

  bool _withEndSepLine() =>
      viewModel.withConseillerPresencePart ||
      viewModel.commentTitle != null ||
      viewModel.comment != null ||
      viewModel.dateLimiteAnnulation != null;
}

class _InformIfAbsent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.cannotGoToRendezvous,
            style: DsfrTextStyle.headline6(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          Strings.shouldInformConseiller,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
      ],
    );
  }
}

class _Createur extends StatelessWidget {
  final String label;

  const _Createur(this.label);

  @override
  Widget build(BuildContext context) {
    return DsfrAlert(
      type: DsfrAlertType.info,
      description: DsfrAlertDescriptionText(label),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final RendezVousShareToConseiller share;

  const _ShareButton(this.share);

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: share.label,
      variant: DsfrButtonVariant.primary,
      size: DsfrComponentSize.md,
      onPressed: () =>
          ChatPartageBottomSheet.show(context, share.chatPartageSource),
    );
  }
}

class _DemandeInscriptionButton extends StatelessWidget {
  final RendezVousShareToConseillerDemandeInscription share;

  const _DemandeInscriptionButton(this.share);

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: share.label,
      variant: DsfrButtonVariant.primary,
      size: DsfrComponentSize.md,
      onPressed: () {
        share.onPressed?.call();
        Navigator.of(context).push(ChatPartageEventPage.route()).then((value) {
          if (value == true && context.mounted) {
            Navigator.of(context).pop();
          }
        });
      },
    );
  }
}

class _AutoInscriptionButton extends StatelessWidget {
  final RendezVousAutoInscription share;

  const _AutoInscriptionButton(this.share);

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: share.label,
      variant: DsfrButtonVariant.primary,
      size: DsfrComponentSize.md,
      onPressed: () {
        share.onPressed?.call();
        Navigator.of(context).push(AutoInscriptionPage.route()).then((value) {
          if (value == true && context.mounted) {
            Navigator.of(context).pop();
          }
        });
      },
    );
  }
}

class _AnnulerInscriptionButton extends StatelessWidget {
  final RendezVousAnnulerInscription rendezvousCta;
  final RendezvousStateSource source;
  final String rdvId;

  const _AnnulerInscriptionButton(this.rendezvousCta, this.source, this.rdvId);

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: rendezvousCta.label,
      variant: DsfrButtonVariant.secondary,
      size: DsfrComponentSize.md,
      onPressed: () {
        rendezvousCta.onPressed?.call();
        Navigator.of(context)
            .push(
              DesinscriptionPage.route(
                source: source,
                rdvId: rdvId,
              ),
            )
            .then((value) {
              if (value == true && context.mounted) {
                Navigator.of(context).pop();
              }
            });
      },
    );
  }
}

class _CardIllustration extends StatelessWidget {
  final String? imagePath;

  const _CardIllustration({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(DsfrSpacings.s1v)),
        child: Image.asset("assets/${imagePath!}", fit: BoxFit.fitWidth),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
      child: Divider(
        height: 1,
        color: DsfrColorDecisions.borderDefaultGrey(context),
      ),
    );
  }
}
