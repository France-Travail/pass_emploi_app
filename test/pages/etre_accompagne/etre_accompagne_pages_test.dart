import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_conseiller_tile.dart';
import 'package:pass_emploi_app/pages/etre_accompagne/etre_accompagne_page.dart';
import 'package:pass_emploi_app/pages/etre_accompagne/structures_accompagnement_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

const _lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');
const _paris = QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75001');

const _franceTravailRequest = StructuresAccompagnementRequest(
  type: StructureAccompagnementType.franceTravail,
  commune: _lille,
  origine: StructuresAccompagnementCommuneOrigine.saisie,
);

const _agences = [
  StructureAccompagnement(
    nom: 'Agence France Travail Lille Grand Sud',
    adresse: StructureAccompagnementAdresse(ligne: '1 rue Jean Walter', codePostal: '59000', ville: 'Lille'),
    telephone: '39-49',
    horaires: ['Lun–mer · 8h30 – 12h30, 12h30 – 16h30 sur RDV', 'Jeu · 8h30 – 12h30'],
    horairesAlt:
        'Lundi à mercredi ouvert de 8h30 à 12h30 en accès libre et de 12h30 à 16h30 sur rendez-vous, '
        'et jeudi ouvert de 8h30 à 12h30.',
  ),
  StructureAccompagnement(
    nom: 'Agence France Travail Lille Vaucanson',
    adresse: StructureAccompagnementAdresse(ligne: '21 Rue Vaucanson', codePostal: '59800', ville: 'Lille'),
    telephone: '39-49',
    horaires: ['Lun–ven · 9h – 17h'],
  ),
];

AppState _state({QuestionnaireCommune? habitation, StructuresAccompagnementState? structures}) {
  return givenState(configuration())
      .loggedInUser(loginMode: LoginMode.INVITE)
      .withOnboardingQuestionnaire(finished: true, answers: OnboardingQuestionnaireAnswers(habitation: habitation))
      .copyWith(structuresAccompagnementState: structures);
}

Future<void> _pump(WidgetTester tester, AppState state, Widget page, {double textScale = 1}) async {
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: StoreSpy.withState(state),
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: page,
      ),
    ),
  );
  // Laisse passer la minuterie de mise au point du titre (AutoFocusA11y).
  await tester.pump(const Duration(seconds: 1));
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

String _mergedLabel(WidgetTester tester, Finder finder) => tester.getSemantics(finder).getSemanticsData().label;

void main() {
  group('Tuile de l’accueil', () {
    testWidgets('A11y : lue en une fois, comme un bouton', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: InviteConseillerTile())));

      final data = tester.getSemantics(find.byType(InviteConseillerTile)).getSemanticsData();
      expect(data.label, '${Strings.inviteAccueilConseillerTitle}, ${Strings.inviteAccueilConseillerBody}');
      expect(data.flagsCollection.isButton, isTrue);
      handle.dispose();
    });
  });

  group('Être accompagné', () {
    testWidgets('ville pré-remplie, aucune structure choisie, « Voir les structures » désactivé', (tester) async {
      await _pump(tester, _state(habitation: _lille), const EtreAccompagnePage());

      expect(find.widgetWithText(TextField, 'Lille (59000)'), findsOneWidget);
      final submit = tester.widget<DsfrButton>(find.widgetWithText(DsfrButton, Strings.etreAccompagneSubmit));
      expect(submit.onPressed, isNull);

      await tester.tap(find.text(Strings.etreAccompagneMissionLocale));
      await tester.pump();

      final enabled = tester.widget<DsfrButton>(find.widgetWithText(DsfrButton, Strings.etreAccompagneSubmit));
      expect(enabled.onPressed, isNotNull);
    });

    testWidgets('A11y : chaque choix annonce son nom, la question et son état', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _state(habitation: _lille), const EtreAccompagnePage());
      await tester.tap(find.text(Strings.etreAccompagneFranceTravail));
      await tester.pump();

      final franceTravail = find.byType(DsfrRadioRichButton<StructureAccompagnementType>).last;
      final data = tester.getSemantics(franceTravail).getSemanticsData();
      expect(data.label, startsWith(Strings.etreAccompagneFranceTravail));
      expect(data.label, contains(Strings.etreAccompagneStructureTitle));
      expect(tester.getSemantics(franceTravail), isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true));
      handle.dispose();
    });

    testWidgets('texte saisi sans choisir dans la liste : erreur affichée et lue avec le champ', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _state(), const EtreAccompagnePage());

      await tester.enterText(find.byType(TextField), 'Lille');
      await tester.tap(find.text(Strings.etreAccompagneMissionLocale));
      await tester.pump();
      await tester.ensureVisible(find.text(Strings.etreAccompagneSubmit));
      await tester.tap(find.text(Strings.etreAccompagneSubmit));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(Strings.etreAccompagneErrorCommune), findsOneWidget);
      expect(
        _mergedLabel(tester, find.byType(TextField)),
        contains(Strings.etreAccompagneErrorA11y(Strings.etreAccompagneErrorCommune)),
      );
      handle.dispose();
    });

    testWidgets('ville entière (Paris) : « Précise ton arrondissement. », rien ne s’ouvre', (tester) async {
      await _pump(tester, _state(habitation: _paris), const EtreAccompagnePage());

      await tester.tap(find.text(Strings.etreAccompagneMissionLocale));
      await tester.pump();
      await tester.ensureVisible(find.text(Strings.etreAccompagneSubmit));
      await tester.tap(find.text(Strings.etreAccompagneSubmit));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(Strings.etreAccompagneErrorArrondissement), findsOneWidget);
      expect(find.byType(StructuresAccompagnementPage), findsNothing);
    });

    for (final size in [const Size(320, 640), const Size(740, 360)]) {
      testWidgets('texte à 200 % ($size) : rien n’est coupé', (tester) async {
        _setSize(tester, size);
        await _pump(tester, _state(habitation: _lille), const EtreAccompagnePage(), textScale: 2);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Liste France Travail', () {
    final successState = _state(structures: StructuresAccompagnementSuccessState(_franceTravailRequest, _agences));

    testWidgets('3949, agences, horaires ligne par ligne', (tester) async {
      await _pump(tester, successState, const StructuresAccompagnementPage(request: _franceTravailRequest));

      expect(find.text('2 structures près de Lille'), findsOneWidget);
      expect(find.text('Appelle le 3949'), findsOneWidget);
      expect(find.text('Lun–mer · 8h30 – 12h30, 12h30 – 16h30 sur RDV'), findsOneWidget);
      expect(find.text('Jeu · 8h30 – 12h30'), findsOneWidget);
      expect(find.text(Strings.etreAccompagneItineraire), findsNWidgets(2));
      expect(find.text('Appelle le 39-49'), findsNothing);
    });

    testWidgets('A11y : boutons d’itinéraire nommés d’après leur structure', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, successState, const StructuresAccompagnementPage(request: _franceTravailRequest));

      for (final agence in _agences) {
        final itineraire = find.bySemanticsLabel('Voir l’itinéraire vers ${agence.nom}');
        expect(itineraire, findsOneWidget, reason: agence.nom);
        expect(tester.getSemantics(itineraire).getSemanticsData().flagsCollection.isButton, isTrue);
      }
      handle.dispose();
    });

    testWidgets('A11y : les horaires sont lus dans leur version rédigée (horairesAlt), en un seul nœud', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, successState, const StructuresAccompagnementPage(request: _franceTravailRequest));

      final horaires = find.bySemanticsLabel('Horaires : ${_agences.first.horairesAlt}');
      expect(horaires, findsOneWidget);
      // Les lignes affichées ne sont pas lues en plus.
      expect(find.bySemanticsLabel(RegExp('Lun–mer')), findsNothing);
      // Sans horairesAlt, les lignes affichées restent lues.
      expect(find.bySemanticsLabel('Horaires : Lun–ven · 9h – 17h'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('échec : message d’erreur et « Réessayer », le 3949 reste visible', (tester) async {
      await _pump(
        tester,
        _state(structures: StructuresAccompagnementFailureState(_franceTravailRequest)),
        const StructuresAccompagnementPage(request: _franceTravailRequest),
      );

      expect(find.text(Strings.etreAccompagneLoadingError), findsOneWidget);
      expect(find.text(Strings.retry), findsOneWidget);
      expect(find.text('Appelle le 3949'), findsOneWidget);
    });

    for (final size in [const Size(320, 640), const Size(740, 360)]) {
      testWidgets('texte à 200 % ($size) : rien n’est coupé', (tester) async {
        _setSize(tester, size);
        await _pump(
          tester,
          successState,
          const StructuresAccompagnementPage(request: _franceTravailRequest),
          textScale: 2,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
