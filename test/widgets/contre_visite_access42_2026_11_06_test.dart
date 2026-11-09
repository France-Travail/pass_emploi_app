import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_birthdate_step.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/alerte_card.dart';
import 'package:pass_emploi_app/widgets/cards/data_card.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_accessible_toggle_switch.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:pass_emploi_app/widgets/slider/distance_slider.dart';
import 'package:pass_emploi_app/widgets/tag_group.dart';
import 'package:redux/redux.dart';

import '../dsl/app_state_dsl.dart';

/// Correctifs de la contre-visite Access42 du 06/11/2026 (version 5.1.4).
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }

  testWidgets('Point 2, A11y 8.1 : « (H/F) » est explicité dans le nom du bouton étoile (E13)', (tester) async {
    final store = Store<AppState>((state, _) => state, initialState: givenState());
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: FavorisStateContext<OffreEmploi>(
              selectState: (store) => store.state.offreEmploiFavorisIdsState,
              child: DataCard<OffreEmploi>(
                titre: 'Technicien CVC (H/F)',
                sousTitre: 'Entreprise',
                lieu: 'Nantes',
                id: 'id',
                from: OffrePage.emploiResults,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byTooltip("Enregistrer l'offre Technicien CVC ${Strings.a11yHommesEtFemmes} Entreprise"),
      findsOneWidget,
    );
  });

  group('Point 3, A11y 5.1 et 5.2 : interrupteurs actifs et atteignables au clavier sur iOS', () {
    testWidgets('l’interrupteur est actif, basculé et se bascule par l’action « toucher »', (tester) async {
      final semantics = tester.ensureSemantics();
      var value = false;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => DsfrAccessibleToggleSwitch(
            semanticsLabel: 'Préfixe',
            label: 'Débutant accepté',
            value: value,
            status: value ? 'Oui' : 'Non',
            onChanged: (newValue) => setState(() => value = newValue),
          ),
        ),
      );

      final finder = find.bySemanticsLabel(RegExp('Débutant accepté'));
      expect(
        tester.getSemantics(finder),
        isSemantics(
          label: 'Préfixe\nDébutant accepté\nNon',
          hasEnabledState: true,
          isEnabled: true,
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );

      tester.semantics.tap(find.semantics.byLabel(RegExp('Débutant accepté')));
      await tester.pump();

      expect(value, isTrue);
      expect(tester.getSemantics(finder), isSemantics(isToggled: true, isEnabled: true));
      semantics.dispose();
    });

    testWidgets('l’interrupteur désactivé reste annoncé désactivé, sans action', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(
        tester,
        DsfrAccessibleToggleSwitch(label: 'Partager mes offres suivies', value: true, enabled: false, onChanged: (_) {}),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Partager mes offres suivies')),
        isSemantics(hasEnabledState: true, isEnabled: false, hasToggledState: true, isToggled: true, hasTapAction: false),
      );
      semantics.dispose();
    });

    testWidgets('les étiquettes de filtre (« Modalités d’accès ») sont actives', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(
        tester,
        TagGroup<String>(
          title: 'Modalités d’accès',
          options: [CheckboxValueViewModel(label: 'À distance', value: 'distance', isInitiallyChecked: false)],
          onSelectedOptionsUpdated: (_) {},
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('À distance')),
        isSemantics(hasEnabledState: true, isEnabled: true, hasCheckedState: true, isChecked: false, hasTapAction: true),
      );
      semantics.dispose();
    });
  });

  testWidgets('Point 4, A11y 5.2 : l’action « toucher » du curseur lui donne le focus clavier (iOS)', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, DistanceSlider(initialDistanceValue: 20, onValueChange: (_) {}));

    final finder = find.bySemanticsLabel(Strings.searchRadius);
    expect(
      tester.getSemantics(finder),
      isSemantics(
        isSlider: true,
        value: Strings.searchRadiusA11yValue(20),
        hasTapAction: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    bool sliderHasFocus() {
      final focused = FocusManager.instance.primaryFocus?.context;
      if (focused == null) return false;
      return find
          .ancestor(of: find.byElementPredicate((element) => element == focused), matching: find.byType(Slider))
          .evaluate()
          .isNotEmpty;
    }

    expect(sliderHasFocus(), isFalse);

    tester.semantics.tap(find.semantics.byLabel(Strings.searchRadius));
    await tester.pump();

    expect(sliderHasFocus(), isTrue);
    semantics.dispose();
  });

  group('Point 5, A11y 9.12 : nature des champs de date de naissance (E08)', () {
    Future<List<TextInputType?>> keyboardTypes(WidgetTester tester) async {
      final form = OnboardingQuestionnaireFormChangeNotifier(
        loadAnswers: () async => const OnboardingQuestionnaireAnswers(),
        saveAnswers: (_) async {},
      );
      await pump(tester, SingleChildScrollView(child: OnboardingQuestionnaireBirthdateStep(form: form)));
      return tester.widgetList<EditableText>(find.byType(EditableText)).map((field) => field.keyboardType).toList();
    }

    testWidgets('Android : jour, mois et année sont de type date', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final types = await keyboardTypes(tester);
      debugDefaultTargetPlatformOverride = null;

      expect(types, List.filled(3, TextInputType.datetime));
    });

    testWidgets('iOS : le pavé numérique est conservé (pas de type « date de naissance » dans Flutter)', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final types = await keyboardTypes(tester);
      debugDefaultTargetPlatformOverride = null;

      expect(types, List.filled(3, TextInputType.number));
    });
  });

  testWidgets('Point 6, A11y 10.2 : une action à libellé long se lit case, lien, corbeille (E01)', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const action = ActionPlanAction(
      id: 'a',
      label: 'Je fais le point sur mes compétences professionnelles et personnelles',
      kind: ActionPlanActionKind.link,
      url: 'https://diagoriente.beta.gouv.fr',
      serviceName: 'Diagoriente Compétences',
    );
    await pump(
      tester,
      Column(
        children: [
          InviteActionPlanActionTile(action: action, onToggleDone: () {}, onDelete: () {}),
          InviteActionPlanActionTile(
            action: const ActionPlanAction(id: 'b', label: 'Action suivante', kind: ActionPlanActionKind.advice),
            onToggleDone: () {},
            onDelete: () {},
          ),
        ],
      ),
    );

    expect(_labelsInTraversalOrder(tester), [
      action.label,
      'Diagoriente Compétences',
      Strings.inviteAccueilDeleteActionA11y(action.label),
      'Action suivante',
      Strings.inviteAccueilDeleteActionA11y('Action suivante'),
    ]);
    semantics.dispose();
  });

  testWidgets('Point 7, A11y 5.1 : chaque bouton de suppression nomme son alerte (E12)', (tester) async {
    await pump(
      tester,
      Column(
        children: [
          for (final lieu in ['Nantes', 'Paris'])
            AlerteCardContent(
              title: 'Emploi',
              subtitle: lieu,
              onDelete: () {},
              onTap: () {},
              trackingSource: AlerteCardTrackingSource.alertes,
            ),
        ],
      ),
    );

    expect(find.byTooltip('Supprimer l’alerte Emploi, Nantes'), findsOneWidget);
    expect(find.byTooltip('Supprimer l’alerte Emploi, Paris'), findsOneWidget);
    expect(find.byTooltip(Strings.alerteDeleteMessageTitle), findsNothing);
  });
}

/// Libellés (ou infobulles) des éléments activables, dans l'ordre de lecture des lecteurs d'écran.
List<String> _labelsInTraversalOrder(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    if (data.hasAction(SemanticsAction.tap)) {
      labels.add(data.label.isNotEmpty ? data.label : data.tooltip);
    }
    for (final child in node.debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder)) {
      visit(child);
    }
  }

  visit(tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
  return labels;
}
