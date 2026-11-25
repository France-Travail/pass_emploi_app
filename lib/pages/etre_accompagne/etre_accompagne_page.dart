import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/pages/etre_accompagne/structures_accompagnement_page.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_form_change_notifier.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/group_label_semantics.dart';
import 'package:pass_emploi_app/widgets/buttons/clear_field_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

/// Invité : trouver la Mission Locale ou les agences France Travail de sa ville.
class EtreAccompagnePage extends StatefulWidget {
  const EtreAccompagnePage({super.key});

  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (_) => const EtreAccompagnePage());
  }

  @override
  State<EtreAccompagnePage> createState() => _EtreAccompagnePageState();
}

class _EtreAccompagnePageState extends State<EtreAccompagnePage> {
  final _communesRepository = CommunesRepository();
  late final EtreAccompagneFormChangeNotifier _form;
  late final TextEditingController _controller;
  List<QuestionnaireCommune> _suggestions = [];
  int? _focusedSuggestion;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Ville pré-remplie avec la commune d'habitation du questionnaire, qui n'est jamais modifiée ici.
    final questionnaireState = StoreProvider.of<AppState>(context, listen: false).state.onboardingQuestionnaireState;
    final habitation = questionnaireState is OnboardingQuestionnaireSuccessState
        ? questionnaireState.answers.habitation
        : null;
    _form = EtreAccompagneFormChangeNotifier(initialCommune: habitation);
    _controller = TextEditingController(text: _form.query);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.etreAccompagne,
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        appBar: const BackAppBar(),
        body: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: _form,
            builder: (context, _) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DsfrSpacings.s3w, 0, DsfrSpacings.s3w, DsfrSpacings.s4w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageTitle(Strings.etreAccompagneTitle),
                  const SizedBox(height: DsfrSpacings.s2w),
                  Semantics(
                    headingLevel: 2,
                    child: Text(
                      Strings.etreAccompagneSubtitle,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  _villeField(context),
                  ..._suggestionsList(context),
                  const SizedBox(height: DsfrSpacings.s2w),
                  DsfrButton(
                    label: Strings.etreAccompagneGeolocate,
                    variant: DsfrButtonVariant.secondary,
                    size: DsfrComponentSize.lg,
                    icon: DsfrIcons.mapMapPin2Line,
                    onPressed: _form.isGeolocating ? null : _geolocate,
                  ),
                  if (_form.geolocationFailed) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      Strings.etreAccompagneGeolocateError,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultError(context)),
                    ),
                  ],
                  const SizedBox(height: DsfrSpacings.s3w),
                  Semantics(
                    headingLevel: 2,
                    child: Text(
                      Strings.etreAccompagneStructureTitle,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  _structureRadio(
                    type: StructureAccompagnementType.missionLocale,
                    title: Strings.etreAccompagneMissionLocale,
                    logo: Drawables.missionLocaleLogoTitle,
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  _structureRadio(
                    type: StructureAccompagnementType.franceTravail,
                    title: Strings.etreAccompagneFranceTravail,
                    logo: Drawables.franceTravailLogoTitle,
                  ),
                  const SizedBox(height: DsfrSpacings.s4w),
                  DsfrButton(
                    label: Strings.etreAccompagneSubmit,
                    variant: DsfrButtonVariant.primary,
                    size: DsfrComponentSize.lg,
                    onPressed: _form.canSubmit ? _submit : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _villeField(BuildContext context) {
    final error = _form.error;
    final hasClearButton = _controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A11y 5.1 : le bouton d'effacement est posé par-dessus le champ, hors du nœud fusionné « étiquette + champ ».
        Stack(
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Strings.etreAccompagneVilleLabel,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
                  ),
                  Text(
                    Strings.etreAccompagneVilleHint,
                    style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  DsfrInputHeadless(
                    controller: _controller,
                    onChanged: _onQueryChanged,
                    // A11y 9.12 : nature de la saisie (commune).
                    keyboardType: TextInputType.streetAddress,
                    autofillHints: const [AutofillHints.addressCity],
                    inputBorderColor: error != null ? DsfrColorDecisions.borderPlainError(context) : null,
                    // Texte agrandi : le champ grandit avec le texte au lieu de le rogner.
                    inputConstraints: const BoxConstraints(minHeight: DsfrSpacings.s6w),
                    // Réserve la place du bouton d'effacement.
                    suffixIcon: hasClearButton ? const SizedBox.square(dimension: 40) : null,
                  ),
                  // A11y 11.10 : l'erreur affichée sous le champ est lue avec lui, après sa valeur. Nœud sans taille,
                  // à part (container) pour être fusionné après le champ, comme dans GroupLabelSemantics.
                  if (error != null)
                    Semantics(
                      container: true,
                      label: Strings.etreAccompagneErrorA11y(error),
                      child: const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
            if (hasClearButton)
              Positioned(
                right: DsfrSpacings.s1v,
                bottom: DsfrSpacings.s1v,
                child: ClearFieldButton(
                  tooltip: Strings.a11yClearField(Strings.etreAccompagneVilleLabel),
                  onPressed: _clearQuery,
                ),
              ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(DsfrIcons.systemErrorWarningFill, size: 16, color: DsfrColorDecisions.textDefaultError(context)),
                const SizedBox(width: DsfrSpacings.s1v),
                Expanded(
                  child: Text(
                    error,
                    style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textDefaultError(context)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _suggestionsList(BuildContext context) {
    if (_suggestions.isEmpty) return [];
    return [
      const SizedBox(height: DsfrSpacings.s1w),
      for (final (index, commune) in _suggestions.indexed)
        DsfrFocusWidget(
          isFocused: _focusedSuggestion == index,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material.
            focusColor: DsfrColorDecisions.backgroundTransparent(context),
            onFocusChange: (focused) => setState(() {
              if (focused) {
                _focusedSuggestion = index;
              } else if (_focusedSuggestion == index) {
                _focusedSuggestion = null;
              }
            }),
            title: Text(
              commune.displayLabel,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            onTap: () => _selectCommune(commune, StructuresAccompagnementCommuneOrigine.saisie),
          ),
        ),
    ];
  }

  Widget _structureRadio({required StructureAccompagnementType type, required String title, required String logo}) {
    // A11y 9.6 : chaque choix reprend la question, affichée en titre.
    return GroupLabelSemantics(
      groupLabel: Strings.etreAccompagneStructureTitle,
      child: DsfrRadioRichButton<StructureAccompagnementType>(
        title: title,
        value: type,
        groupValue: _form.type,
        size: DsfrComponentSize.md,
        isExpanded: true,
        // Le logo reprend le nom affiché : il est décoratif.
        trailingIcon: Image.asset(logo, width: 56, height: 56, excludeFromSemantics: true),
        onChanged: (value) {
          if (value != null) _form.selectType(value);
        },
      ),
    );
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _suggestions = []);
    _form.updateQuery('');
  }

  void _onQueryChanged(String value) {
    _form.updateQuery(value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await _communesRepository.search(value, oneEntryPerCodePostal: true);
      // Réponse d'une saisie dépassée, ou commune déjà choisie entre-temps.
      if (!mounted || _controller.text != value || _form.commune != null) return;
      setState(() {
        _suggestions = results;
        _focusedSuggestion = null;
      });
      // A11y 5.4 : la liste apparaît sous le champ, son arrivée est annoncée.
      if (results.isNotEmpty) A11yUtils.announce(Strings.etreAccompagneCommunesA11y(results.length));
    });
  }

  void _selectCommune(QuestionnaireCommune commune, StructuresAccompagnementCommuneOrigine origine) {
    _debounce?.cancel();
    setState(() {
      _suggestions = [];
      _focusedSuggestion = null;
    });
    _controller.text = commune.displayLabel;
    _form.selectCommune(commune, origine);
    A11yUtils.announce(Strings.etreAccompagneCommuneSelectedA11y(commune.displayLabel));
  }

  void _submit() {
    final request = _form.submit();
    final error = _form.error;
    if (request == null) {
      // A11y 11.10 : l'erreur, affichée sous le champ, est aussi annoncée.
      if (error != null) A11yUtils.announce(Strings.etreAccompagneErrorA11y(error));
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(StructuresAccompagnementPage.materialPageRoute(request));
  }

  // Seule la commune trouvée part vers l'API géo de l'État : la position n'est jamais envoyée au serveur pass emploi.
  Future<void> _geolocate() async {
    _form.startGeolocation();
    final commune = await _findCommuneAroundMe();
    if (!mounted) return;
    if (commune == null) {
      _form.endGeolocation(failed: true);
      A11yUtils.announce(Strings.etreAccompagneGeolocateError);
      return;
    }
    _form.endGeolocation(failed: false);
    _selectCommune(commune, StructuresAccompagnementCommuneOrigine.geolocalisation);
  }

  Future<QuestionnaireCommune?> _findCommuneAroundMe() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
      final position = await Geolocator.getCurrentPosition();
      return await _communesRepository.findByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        preferArrondissement: true,
      );
    } catch (_) {
      return null;
    }
  }
}
