import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_checkbox_rich.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_accessible_toggle_switch.dart';
import 'package:pass_emploi_app/widgets/tag_group.dart';

/// A11y 5.5 : avant Android 16, TalkBack n'annonce le nouvel état d'une case ou d'un interrupteur qu'à la réception de
/// l'évènement « clic » (`tap`) envoyé par le nœud activé. Ces choix fournissent leur action « toucher » via
/// `Semantics` : ils doivent envoyer cet évènement eux-mêmes.
void main() {
  /// Évènements `tap` envoyés au moteur, par identifiant de nœud.
  List<int> captureTaps(WidgetTester tester) {
    final taps = <int>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (message) async {
      final map = message as Map;
      if (map['type'] == 'tap') taps.add(map['nodeId'] as int);
      return null;
    });
    addTearDown(() => messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));
    return taps;
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ListView(children: [child]))));
  }

  /// Active le nœud du widget [finder] comme le ferait le lecteur d'écran (action « toucher »).
  Future<void> activer(WidgetTester tester, Finder finder, List<int> taps) async {
    final noeud = tester.getSemantics(finder);
    tester.semantics.tap(find.semantics.byPredicate((node) => node.id == noeud.id));
    await tester.pump();
    expect(taps, [noeud.id], reason: 'évènement « clic » envoyé par le nœud activé');
  }

  testWidgets('étiquette de filtre (TagGroup)', (tester) async {
    final semantics = tester.ensureSemantics();
    final taps = captureTaps(tester);
    await pump(
      tester,
      TagGroup<String>(
        title: 'Modalités d’accès',
        options: [CheckboxValueViewModel(label: 'À distance', value: 'distance', isInitiallyChecked: false)],
        onSelectedOptionsUpdated: (_) {},
      ),
    );

    await activer(tester, find.byType(DsfrTag), taps);
    expect(
      tester.getSemantics(find.bySemanticsLabel('À distance, Modalités d’accès')),
      isSemantics(hasCheckedState: true, isChecked: true),
    );
    semantics.dispose();
  });

  testWidgets('interrupteur (DsfrAccessibleToggleSwitch)', (tester) async {
    final semantics = tester.ensureSemantics();
    final taps = captureTaps(tester);
    var value = false;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => DsfrAccessibleToggleSwitch(
          semanticsLabel: 'Activer l’affichage des offres à partir d’une date',
          label: 'Dès le',
          value: value,
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    );

    await activer(tester, find.byType(DsfrAccessibleToggleSwitch), taps);
    expect(value, isTrue);
    semantics.dispose();
  });

  testWidgets('case à cocher du questionnaire (OnboardingQuestionnaireCheckboxRich)', (tester) async {
    final semantics = tester.ensureSemantics();
    final taps = captureTaps(tester);
    await pump(
      tester,
      OnboardingQuestionnaireCheckboxRich(
        label: 'Trouver un emploi',
        value: false,
        size: DsfrComponentSize.md,
        onChanged: (_) {},
      ),
    );

    await activer(tester, find.byType(OnboardingQuestionnaireCheckboxRich), taps);
    semantics.dispose();
  });
}
