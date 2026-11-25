import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Invité : trouver la Mission Locale ou les agences France Travail de son code postal.
class EtreAccompagnePage extends StatefulWidget {
  const EtreAccompagnePage({super.key, this.communesRepository});

  /// Remplaçable dans les tests ; sinon l'API géo de l'État.
  final CommunesRepository? communesRepository;

  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (_) => const EtreAccompagnePage());
  }

  @override
  State<EtreAccompagnePage> createState() => _EtreAccompagnePageState();
}

class _EtreAccompagnePageState extends State<EtreAccompagnePage> {
  late final CommunesRepository _communesRepository;
  late final EtreAccompagneFormChangeNotifier _form;
  late final TextEditingController _controller;
  final _codePostalKey = GlobalKey();
  final _communeChoiceKey = GlobalKey();
  bool _isSubmitting = false;

  // « Voir les structures » attend les communes du code postal, que l'API géo met parfois une dizaine de secondes à
  // renvoyer : le bouton est désactivé et un chargement s'affiche dessous.
  bool _isCheckingCodePostal = false;

  // Recherche lancée au 5e chiffre, reprise par « Voir les structures » plutôt que d'en lancer une autre.
  Future<void>? _communesLookup;
  String? _communesLookupCodePostal;

  @override
  void initState() {
    super.initState();
    _communesRepository = widget.communesRepository ?? CommunesRepository();
    // Code postal pré-rempli avec celui de la commune d'habitation du questionnaire, qui n'est jamais modifiée ici.
    final questionnaireState = StoreProvider.of<AppState>(context, listen: false).state.onboardingQuestionnaireState;
    final habitation = questionnaireState is OnboardingQuestionnaireSuccessState
        ? questionnaireState.answers.habitation
        : null;
    _form = EtreAccompagneFormChangeNotifier(initialCommune: habitation);
    _controller = TextEditingController(text: _form.codePostal);
    // Si ce code postal couvre plusieurs communes, la liste s'affiche, celle du questionnaire choisie.
    if (_form.needsCommunes) unawaited(_lookupCommunes(_form.codePostal));
  }

  @override
  void dispose() {
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
                  _codePostalField(context),
                  ..._communeChoice(context),
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
                    onPressed: _form.canSubmit && !_isCheckingCodePostal ? _submit : null,
                  ),
                  if (_isCheckingCodePostal) ...[const SizedBox(height: DsfrSpacings.s2w), const _CheckingCodePostal()],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _codePostalField(BuildContext context) {
    final error = _form.codePostalError;
    final hasClearButton = _controller.text.isNotEmpty;
    return Column(
      key: _codePostalKey,
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
                    Strings.etreAccompagneCodePostalLabel,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
                  ),
                  // A11y 11.10 : format attendu indiqué avant la saisie.
                  Text(
                    Strings.etreAccompagneCodePostalHint,
                    style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  DsfrInputHeadless(
                    controller: _controller,
                    onChanged: _onCodePostalChanged,
                    // A11y 9.12 : nature de la saisie (code postal).
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.postalCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
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
                  tooltip: Strings.a11yClearField(Strings.etreAccompagneCodePostalLabel),
                  onPressed: _clearCodePostal,
                ),
              ),
          ],
        ),
        if (error != null) ...[const SizedBox(height: DsfrSpacings.s1w), _ErrorText(error)],
      ],
    );
  }

  // Seulement quand le code postal couvre plusieurs communes (14500 : Campagnolles, Vire Normandie).
  List<Widget> _communeChoice(BuildContext context) {
    final communes = _form.communes;
    if (!_form.showCommuneChoice || communes == null) return [];
    final error = _form.communeError;
    // A11y 9.6 : chaque choix reprend la question, et l'erreur quand il y en a une.
    final groupLabel = error == null
        ? Strings.etreAccompagneCommuneLabel
        : '${Strings.etreAccompagneCommuneLabel}, ${Strings.etreAccompagneErrorA11y(error)}';
    return [
      const SizedBox(height: DsfrSpacings.s2w),
      ExcludeSemantics(
        key: _communeChoiceKey,
        child: Text(
          Strings.etreAccompagneCommuneLabel,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
        ),
      ),
      for (final commune in communes)
        Padding(
          padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
          child: GroupLabelSemantics(
            groupLabel: groupLabel,
            child: DsfrRadioButton<String>(
              label: commune.nom,
              value: commune.code,
              groupValue: _form.commune?.code,
              size: DsfrComponentSize.md,
              onChanged: (_) => _form.selectCommune(commune),
            ),
          ),
        ),
      if (error != null) ...[const SizedBox(height: DsfrSpacings.s1w), _ErrorText(error)],
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

  void _clearCodePostal() {
    _controller.clear();
    _form.updateCodePostal('');
  }

  void _onCodePostalChanged(String value) {
    _form.updateCodePostal(value);
    if (_form.needsCommunes) unawaited(_lookupCommunes(value, announceChoice: true));
  }

  Future<void> _lookupCommunes(String codePostal, {bool announceChoice = false}) {
    final pending = _communesLookup;
    if (pending != null && _communesLookupCodePostal == codePostal) return pending;
    final lookup = _fetchCommunes(codePostal, announceChoice: announceChoice);
    _communesLookup = lookup;
    _communesLookupCodePostal = codePostal;
    return lookup.whenComplete(() {
      if (!identical(_communesLookup, lookup)) return;
      _communesLookup = null;
      _communesLookupCodePostal = null;
    });
  }

  /// [announceChoice] : A11y 5.4, l'apparition de la liste des communes sous le champ est annoncée.
  Future<void> _fetchCommunes(String codePostal, {required bool announceChoice}) async {
    final communes = await _communesRepository.communesDuCodePostal(codePostal);
    if (!mounted) return;
    final wasShown = _form.showCommuneChoice;
    _form.setCommunes(codePostal, communes);
    // Pendant « Voir les structures », c'est l'erreur « Choisis ta commune. » qui est annoncée.
    if (announceChoice && !_isCheckingCodePostal && !wasShown && _form.showCommuneChoice) {
      A11yUtils.announce(Strings.etreAccompagneCommunesA11y(_form.communes!.length));
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    _isSubmitting = true;
    try {
      // Communes pas encore connues (API géo lente, ou injoignable jusque-là) : elles sont attendues d'abord.
      if (_form.type != null && _form.needsCommunes) {
        setState(() => _isCheckingCodePostal = true);
        A11yUtils.announce(Strings.etreAccompagneCodePostalChecking);
        await _lookupCommunes(_form.codePostal);
        if (!mounted) return;
        setState(() => _isCheckingCodePostal = false);
      }
      final request = _form.submit();
      if (request == null) {
        // A11y 11.10 : l'erreur, affichée sous le champ ou sous les communes, est aussi annoncée.
        final error = _form.codePostalError ?? _form.communeError;
        if (error != null) {
          A11yUtils.announce(Strings.etreAccompagneErrorA11y(error));
          _revealError(_form.codePostalError != null ? _codePostalKey : _communeChoiceKey);
        }
        return;
      }
      FocusScope.of(context).unfocus();
      await Navigator.of(context).push(StructuresAccompagnementPage.materialPageRoute(request));
    } finally {
      _isSubmitting = false;
    }
  }

  // Clavier ouvert, l'erreur peut être hors de l'écran, au-dessus du bouton : la page remonte jusqu'à elle.
  void _revealError(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = key.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  // Seule la commune trouvée part vers l'API géo de l'État : la position n'est jamais envoyée au serveur pass emploi.
  Future<void> _geolocate() async {
    _form.startGeolocation();
    final commune = await _findCommuneAroundMe();
    if (!mounted) return;
    // Paris, Lyon ou Marseille sans arrondissement : il manquerait le bon code postal.
    if (commune == null || commune.codePostal == null || commune.isCommuneAvecArrondissements) {
      _form.endGeolocation(failed: true);
      A11yUtils.announce(Strings.etreAccompagneGeolocateError);
      return;
    }
    _form.endGeolocation(failed: false);
    _form.applyGeolocatedCommune(commune);
    _controller.text = _form.codePostal;
    A11yUtils.announce(Strings.etreAccompagneGeolocatedA11y(_form.codePostal, commune.nomCourt));
    // La commune géolocalisée reste choisie si le code postal en couvre plusieurs.
    unawaited(_lookupCommunes(_form.codePostal));
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

/// Erreur affichée sous le champ ou sous les communes. Elle est lue avec eux : exclue ici pour ne pas l'être deux fois.
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.error);

  final String error;

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textDefaultError(context);
    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(DsfrIcons.systemErrorWarningFill, size: 16, color: color),
          const SizedBox(width: DsfrSpacings.s1v),
          Expanded(
            child: Text(error, style: DsfrTextStyle.bodyXs(color: color)),
          ),
        ],
      ),
    );
  }
}

/// Chargement sous « Voir les structures », le temps de vérifier le code postal. Annoncé au moment de l'appui.
class _CheckingCodePostal extends StatelessWidget {
  const _CheckingCodePostal();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: DsfrSpacings.s3w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
          ),
        ),
        const SizedBox(width: DsfrSpacings.s1w),
        Flexible(
          child: Text(
            Strings.etreAccompagneCodePostalChecking,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
        ),
      ],
    );
  }
}
