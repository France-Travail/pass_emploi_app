import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_actions.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_tracking.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/structures_accompagnement_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mission Locale ou agences France Travail de la ville choisie dans « Être accompagné ».
class StructuresAccompagnementPage extends StatefulWidget {
  const StructuresAccompagnementPage({super.key, required this.request});

  final StructuresAccompagnementRequest request;

  static MaterialPageRoute<void> materialPageRoute(StructuresAccompagnementRequest request) {
    return MaterialPageRoute(builder: (_) => StructuresAccompagnementPage(request: request));
  }

  @override
  State<StructuresAccompagnementPage> createState() => _StructuresAccompagnementPageState();
}

class _StructuresAccompagnementPageState extends State<StructuresAccompagnementPage> {
  EtreAccompagneTrackingEvent? _lastResultEvent;

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: widget.request.type.trackingScreenName,
      child: StoreConnector<AppState, StructuresAccompagnementViewModel>(
        onInit: (store) => store.dispatch(StructuresAccompagnementRequestAction(widget.request)),
        onDispose: (store) => store.dispatch(StructuresAccompagnementResetAction()),
        converter: (store) => StructuresAccompagnementViewModel.create(
          store,
          widget.request,
          platform: PlatformUtils.getPlatform,
        ),
        onInitialBuild: _onViewModel,
        onDidChange: (_, viewModel) => _onViewModel(viewModel),
        distinct: true,
        builder: (context, viewModel) => Scaffold(
          backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
          appBar: const BackAppBar(),
          body: SafeArea(top: false, child: _Body(viewModel)),
        ),
      ),
    );
  }

  // Suivi et annonce une seule fois par résultat (pas à chaque reconstruction).
  void _onViewModel(StructuresAccompagnementViewModel viewModel) {
    final event = viewModel.resultEvent;
    if (event == null || event == _lastResultEvent) return;
    _lastResultEvent = event;
    event.send();
    // A11y 7.5 : le résultat de la recherche, affiché sous le titre, est annoncé.
    final message = switch (viewModel.displayState) {
      DisplayState.CONTENT => viewModel.subtitle,
      DisplayState.EMPTY => viewModel.emptyTitle,
      DisplayState.FAILURE => Strings.etreAccompagneLoadingError,
      DisplayState.LOADING => null,
    };
    if (message != null) A11yUtils.announce(message);
  }
}

class _Body extends StatelessWidget {
  const _Body(this.viewModel);

  final StructuresAccompagnementViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final subtitle = viewModel.subtitle;
    final intro = viewModel.intro;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(DsfrSpacings.s3w, 0, DsfrSpacings.s3w, DsfrSpacings.s4w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageTitle(viewModel.title),
          const SizedBox(height: DsfrSpacings.s2w),
          if (subtitle != null) ...[
            Semantics(
              headingLevel: 2,
              child: Text(subtitle, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
            ),
            const SizedBox(height: DsfrSpacings.s3v),
          ],
          if (intro != null) ...[
            Text(intro, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
            const SizedBox(height: DsfrSpacings.s3v),
          ],
          if (viewModel.withContact3949) ...[
            _Contact3949Card(viewModel.contact3949Uri),
            const SizedBox(height: DsfrSpacings.s3v),
          ],
          ...switch (viewModel.displayState) {
            DisplayState.LOADING => [
              Padding(
                padding: const EdgeInsets.all(DsfrSpacings.s3w),
                child: Center(child: CircularProgressIndicator(semanticsLabel: Strings.etreAccompagneLoadingA11y)),
              ),
            ],
            DisplayState.FAILURE => [Retry(Strings.etreAccompagneLoadingError, viewModel.onRetry, small: true)],
            DisplayState.EMPTY => [_Empty(viewModel)],
            DisplayState.CONTENT => [
              for (final item in viewModel.items) ...[
                _StructureCard(item: item, type: viewModel.type),
                const SizedBox(height: DsfrSpacings.s3v),
              ],
            ],
          },
        ],
      ),
    );
  }
}

class _Contact3949Card extends StatelessWidget {
  const _Contact3949Card(this.uri);

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final titleColor = DsfrColorDecisions.textActionHighBlueFrance(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s3w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(DsfrIcons.devicePhoneLine, size: 24, color: titleColor),
                const SizedBox(width: DsfrSpacings.s1w),
                Expanded(
                  child: Semantics(
                    headingLevel: 3,
                    child: Text(Strings.etreAccompagne3949Title, style: DsfrTextStyle.bodyMdBold(color: titleColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              Strings.etreAccompagne3949Body,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            Text(
              Strings.etreAccompagne3949Horaires,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            DsfrButton(
              label: Strings.etreAccompagneCall(Strings.etreAccompagne3949Numero),
              icon: DsfrIcons.devicePhoneLine,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () {
                const EtreAccompagneTrackingEvent.appel3949().send();
                launchUrl(uri);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StructureCard extends StatelessWidget {
  const _StructureCard({required this.item, required this.type});

  final StructureAccompagnementItem item;
  final StructureAccompagnementType type;

  @override
  Widget build(BuildContext context) {
    final adresse = item.adresse;
    final horairesA11yLabel = item.horairesA11yLabel;
    final callLabel = item.callLabel;
    final callUri = item.callUri;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s3w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: DsfrSpacings.s1w,
          children: [
            Semantics(
              headingLevel: 3,
              child: Text(item.nom, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
            ),
            if (adresse != null)
              _IconLines(
                icon: DsfrIcons.mapMapPin2Line,
                lines: [adresse],
                semanticsLabel: Strings.etreAccompagneAdresseA11y(adresse),
              ),
            // Horaires affichés ligne par ligne, tels que renvoyés par France Travail ; les lecteurs d'écran lisent à la
            // place leur version rédigée en phrases (horairesAlt).
            if (horairesA11yLabel != null)
              _IconLines(icon: DsfrIcons.systemTimeLine, lines: item.horaires, semanticsLabel: horairesA11yLabel),
            if (callLabel != null && callUri != null)
              _NamedButton(
                a11yLabel: item.callA11yLabel ?? callLabel,
                onPressed: () => _call(callUri),
                child: DsfrButton(
                  label: callLabel,
                  icon: DsfrIcons.devicePhoneLine,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.md,
                  onPressed: () => _call(callUri),
                ),
              ),
            _NamedButton(
              a11yLabel: item.itineraireA11yLabel,
              onPressed: _openItineraire,
              child: DsfrButton(
                label: Strings.etreAccompagneItineraire,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.md,
                onPressed: _openItineraire,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ouvre l'application Téléphone avec le numéro, sans appeler.
  void _call(Uri callUri) {
    EtreAccompagneTrackingEvent.appel(type).send();
    launchUrl(callUri);
  }

  void _openItineraire() {
    EtreAccompagneTrackingEvent.itineraire(type).send();
    launchUrl(item.itineraireUri, mode: LaunchMode.externalApplication);
  }
}

class _IconLines extends StatelessWidget {
  const _IconLines({required this.icon, required this.lines, required this.semanticsLabel});

  final IconData icon;
  final List<String> lines;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textDefaultGrey(context);
    final textScale = A11yUtils.textScaleFactor(context);
    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône centrée sur la première ligne de texte (24 de hauteur de ligne).
          Padding(
            padding: EdgeInsets.only(top: 4 * textScale),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final line in lines) Text(line, style: DsfrTextStyle.bodyMd(color: color))],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton dont le nom accessible précise la structure (« Voir l'itinéraire vers Mission Locale de Lille »), pour que
/// les boutons de deux structures restent distincts. Le nom commence par le libellé visible (A11y 6.1).
class _NamedButton extends StatelessWidget {
  const _NamedButton({required this.a11yLabel, required this.onPressed, required this.child});

  final String a11yLabel;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: a11yLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: child,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.viewModel);

  final StructuresAccompagnementViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsfrSpacings.s2w),
        Center(
          child: Image.asset(Drawables.illustrationRechercheEmpty, width: 212, excludeFromSemantics: true),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Semantics(
          headingLevel: 2,
          child: Text(
            viewModel.emptyTitle,
            style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(viewModel.emptyMessage, style: DsfrTextStyle.bodyLg(color: DsfrColorDecisions.textDefaultGrey(context))),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.etreAccompagneModifierRecherche,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
