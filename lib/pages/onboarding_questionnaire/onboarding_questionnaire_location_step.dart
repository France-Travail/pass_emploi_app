import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_tracker.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';

class OnboardingQuestionnaireLocationStep extends StatefulWidget {
  const OnboardingQuestionnaireLocationStep({
    super.key,
    required this.form,
    required this.communesRepository,
    required this.isHabitation,
  });

  final OnboardingQuestionnaireFormChangeNotifier form;
  final CommunesRepository communesRepository;
  final bool isHabitation;

  @override
  State<OnboardingQuestionnaireLocationStep> createState() =>
      _OnboardingQuestionnaireLocationStepState();
}

class _OnboardingQuestionnaireLocationStepState
    extends State<OnboardingQuestionnaireLocationStep> {
  List<QuestionnaireCommune> _suggestions = [];
  int? _focusedSuggestion;
  Timer? _debounce;
  late final TextEditingController _controller;

  OnboardingQuestionnaireFormChangeNotifier get form => widget.form;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentQuery);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(
    covariant OnboardingQuestionnaireLocationStep oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHabitation != widget.isHabitation) {
      _controller.text = _currentQuery;
      setState(() => _suggestions = []);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  String get _currentQuery =>
      widget.isHabitation ? form.draftHabitationQuery : form.draftVilleQuery;

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final label = widget.isHabitation
        ? Strings.onboardingQuestionnaireHabitationLabel
        : Strings.onboardingQuestionnaireVilleLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.isHabitation
              ? Strings.onboardingQuestionnaireHabitationSubtitle
              : Strings.onboardingQuestionnaireVilleSubtitle,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: Margins.spacing_base),
        MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: DsfrTextStyle.bodyMd(
                  color: DsfrColorDecisions.textLabelGrey(context),
                ),
              ),
              const SizedBox(height: DsfrSpacings.s1w),
              // A11y 5.1 : fusionné au champ, le bouton d'effacement le faisait passer pour un bouton.
              // Il reste visible et atteignable au clavier ; pour le lecteur d'écran, il devient une action du champ.
              Semantics(
                identifier: label,
                customSemanticsActions: _controller.text.isNotEmpty
                    ? {CustomSemanticsAction(label: Strings.clear): _clearQuery}
                    : null,
                child: DsfrInputHeadless(
                  key: ValueKey(widget.isHabitation ? 'habitation' : 'ville'),
                  controller: _controller,
                  onChanged: _onQueryChanged,
                  // A11y 9.12 : la commune d'habitation peut être proposée par le téléphone.
                  autofillHints: widget.isHabitation
                      ? const [AutofillHints.addressCity]
                      : null,
                  suffixIcon: _controller.text.isNotEmpty
                      ? ExcludeSemantics(
                          child: IconButton(
                            tooltip: Strings.clear,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              DsfrIcons.systemCloseLine,
                              size: 16,
                              color: DsfrColorDecisions.textDefaultGrey(
                                context,
                              ),
                            ),
                            onPressed: _clearQuery,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: Margins.spacing_s),
          ..._suggestions.indexed.map(
            (entry) => DsfrFocusWidget(
              isFocused: _focusedSuggestion == entry.$1,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material.
                focusColor: DsfrColorDecisions.backgroundTransparent(context),
                onFocusChange: (focused) => setState(() {
                  if (focused) {
                    _focusedSuggestion = entry.$1;
                  } else if (_focusedSuggestion == entry.$1) {
                    _focusedSuggestion = null;
                  }
                }),
                title: Text(
                  entry.$2.displayLabel,
                  style: DsfrTextStyle.bodyMd(
                    color: DsfrColorDecisions.textTitleGrey(context),
                  ),
                ),
                onTap: () => _onCommuneSelected(entry.$2),
              ),
            ),
          ),
        ],
        if (!widget.isHabitation) ...[
          const SizedBox(height: Margins.spacing_base),
          Text(
            Strings.onboardingQuestionnaireVilleOr,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ],
        const SizedBox(height: Margins.spacing_base),
        DsfrButton(
          label: Strings.onboardingQuestionnaireGeolocate,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          icon: DsfrIcons.mapMapPin2Line,
          onPressed: form.isGeolocating ? null : _geolocate,
        ),
        if (form.geolocationError != null) ...[
          const SizedBox(height: Margins.spacing_s),
          Text(
            form.geolocationError!,
            style: DsfrTextStyle.bodySm(
              color: DsfrColorDecisions.textDefaultError(context),
            ),
          ),
        ],
        if (!widget.isHabitation) ...[
          const SizedBox(height: Margins.spacing_l),
          // A11y : le Slider du DSFR restitue sa valeur en pourcentage ; on expose un seul composant
          // ajustable avec libellé, valeur en kilomètres et bornes min/max.
          Semantics(
            container: true,
            slider: true,
            label: Strings.onboardingQuestionnaireRayonLabel,
            value: Strings.searchRadiusA11yValue(form.draftRayonKm),
            increasedValue: Strings.searchRadiusA11yValue(
              _nextRayon(form.draftRayonKm, 1),
            ),
            decreasedValue: Strings.searchRadiusA11yValue(
              _nextRayon(form.draftRayonKm, -1),
            ),
            hint: Strings.searchRadiusA11yHint(_rayonMin, _rayonMax),
            onIncrease: form.draftRayonKm < _rayonMax
                ? () => form.updateRayon(
                    _nextRayon(form.draftRayonKm, 1).toDouble(),
                  )
                : null,
            onDecrease: form.draftRayonKm > _rayonMin
                ? () => form.updateRayon(
                    _nextRayon(form.draftRayonKm, -1).toDouble(),
                  )
                : null,
            excludeSemantics: true,
            child: DsfrSlider(
              label: Strings.onboardingQuestionnaireRayonLabel,
              description: Strings.onboardingQuestionnaireRayonDescription(
                form.draftRayonKm,
              ),
              value: form.draftRayonKm.toDouble(),
              min: _rayonMin.toDouble(),
              max: _rayonMax.toDouble(),
              divisions: 9,
              size: DsfrComponentSize.md,
              valueLabelBuilder: (value) =>
                  Strings.onboardingQuestionnaireRayonValue(value.round()),
              showMinMaxLabels: true,
              onChanged: form.updateRayon,
            ),
          ),
        ],
      ],
    );
  }

  static const int _rayonMin = 10;
  static const int _rayonMax = 100;
  static const int _rayonStep = 10;

  int _nextRayon(int current, int direction) =>
      (current + direction * _rayonStep).clamp(_rayonMin, _rayonMax);

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _suggestions = []);
    if (widget.isHabitation) {
      form.updateHabitationQuery('');
    } else {
      form.updateVilleQuery('');
    }
  }

  void _onQueryChanged(String value) {
    if (widget.isHabitation) {
      form.updateHabitationQuery(value);
    } else {
      form.updateVilleQuery(value);
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await widget.communesRepository.search(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _focusedSuggestion = null;
      });
      // A11y 5.4 : la liste apparaît sous le champ, son arrivée est annoncée.
      if (results.isNotEmpty)
        A11yUtils.announce(
          Strings.onboardingQuestionnaireCommunesA11y(results.length),
        );
    });
  }

  // A11y 5.3 : choisir une commune la sélectionne seulement ; on passe à la suite avec « Continuer ».
  void _onCommuneSelected(QuestionnaireCommune commune) {
    setState(() {
      _suggestions = [];
      _focusedSuggestion = null;
    });
    _controller.text = commune.displayLabel;
    if (widget.isHabitation) {
      form.selectHabitation(commune);
    } else {
      form.selectVilleRecherche(commune);
    }
    A11yUtils.announce(
      Strings.onboardingQuestionnaireCommuneSelectedA11y(commune.displayLabel),
    );
  }

  // A11y 5.4 : l'erreur de géolocalisation s'affiche sous le bouton et est annoncée.
  void _failGeolocation(OnboardingQuestionnaireGeolocationFailure failure) {
    form.failGeolocation(failure);
    A11yUtils.announce(Strings.onboardingQuestionnaireGeolocateError);
  }

  Future<void> _geolocate() async {
    form.startGeolocation();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _failGeolocation(
          OnboardingQuestionnaireGeolocationFailure.serviceDesactive,
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _failGeolocation(
          OnboardingQuestionnaireGeolocationFailure.permissionRefusee,
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final commune = await widget.communesRepository.findByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (commune == null) {
        _failGeolocation(
          OnboardingQuestionnaireGeolocationFailure.aucuneCommune,
        );
        return;
      }
      setState(() => _suggestions = []);
      _controller.text = commune.displayLabel;
      if (widget.isHabitation) {
        form.selectHabitation(commune);
      } else {
        form.selectVilleRecherche(commune);
      }
      form.succeedGeolocation();
      A11yUtils.announce(
        Strings.onboardingQuestionnaireCommuneSelectedA11y(
          commune.displayLabel,
        ),
      );
    } catch (_) {
      _failGeolocation(
        OnboardingQuestionnaireGeolocationFailure.positionIntrouvable,
      );
    }
  }
}
