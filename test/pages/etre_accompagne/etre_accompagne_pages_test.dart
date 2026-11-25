import 'dart:async';

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
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

const _lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');
const _paris14 = QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75014');
const _vire = QuestionnaireCommune(code: '14762', nom: 'Vire Normandie', codePostal: '14500');
const _campagnolles = QuestionnaireCommune(code: '14127', nom: 'Campagnolles', codePostal: '14500');

/// Communes de l'API géo, sans réseau.
class _FakeCommunesRepository extends CommunesRepository {
  /// Réponse retenue jusqu'à ce que le test la libère (API géo lente).
  Completer<void>? gate;
  int calls = 0;

  @override
  Future<List<QuestionnaireCommune>?> communesDuCodePostal(String codePostal) async {
    calls++;
    await gate?.future;
    return switch (codePostal) {
      '59000' => [_lille],
      '75014' => [_paris14],
      '14500' => [_campagnolles, _vire],
      '99999' => null,
      _ => [],
    };
  }
}

EtreAccompagnePage _etreAccompagnePage() => EtreAccompagnePage(communesRepository: _FakeCommunesRepository());

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

/// Choisit [structure] si besoin, puis touche « Voir les structures ».
Future<void> _submit(WidgetTester tester, String? structure) async {
  if (structure != null) {
    await tester.ensureVisible(find.text(structure));
    await tester.tap(find.text(structure));
    await tester.pump();
  }
  await tester.ensureVisible(find.text(Strings.etreAccompagneSubmit));
  await tester.tap(find.text(Strings.etreAccompagneSubmit));
  await tester.pump();
  // Recherche des communes, puis ouverture de la liste des structures, ou défilement jusqu'à l'erreur (animation qui
  // démarre à la frame suivante, et pendant laquelle la page ignore les appuis).
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 500));
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
    testWidgets('code postal pré-rempli, aucune structure choisie, « Voir les structures » désactivé', (tester) async {
      await _pump(tester, _state(habitation: _lille), _etreAccompagnePage());

      expect(find.widgetWithText(TextField, '59000'), findsOneWidget);
      final submit = tester.widget<DsfrButton>(find.widgetWithText(DsfrButton, Strings.etreAccompagneSubmit));
      expect(submit.onPressed, isNull);

      await tester.tap(find.text(Strings.etreAccompagneMissionLocale));
      await tester.pump();

      final enabled = tester.widget<DsfrButton>(find.widgetWithText(DsfrButton, Strings.etreAccompagneSubmit));
      expect(enabled.onPressed, isNotNull);
    });

    testWidgets('A11y : chaque choix annonce son nom, la question et son état', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _state(habitation: _lille), _etreAccompagnePage());
      await tester.tap(find.text(Strings.etreAccompagneFranceTravail));
      await tester.pump();

      final franceTravail = find.byType(DsfrRadioRichButton<StructureAccompagnementType>).last;
      final data = tester.getSemantics(franceTravail).getSemanticsData();
      expect(data.label, startsWith(Strings.etreAccompagneFranceTravail));
      expect(data.label, contains(Strings.etreAccompagneStructureTitle));
      expect(tester.getSemantics(franceTravail), isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true));
      handle.dispose();
    });

    testWidgets('code postal incomplet : erreur affichée et lue avec le champ', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _state(), _etreAccompagnePage());

      await tester.enterText(find.byType(TextField), '5900');
      await _submit(tester, Strings.etreAccompagneMissionLocale);

      expect(find.text(Strings.etreAccompagneErrorCodePostalFormat), findsOneWidget);
      expect(
        _mergedLabel(tester, find.byType(TextField)),
        contains(Strings.etreAccompagneErrorA11y(Strings.etreAccompagneErrorCodePostalFormat)),
      );
      expect(find.byType(StructuresAccompagnementPage), findsNothing);
      handle.dispose();
    });

    testWidgets('le champ n’accepte que 5 chiffres', (tester) async {
      await _pump(tester, _state(), _etreAccompagnePage());

      await tester.enterText(find.byType(TextField), 'Paris 750141');
      await tester.pump();

      expect(find.widgetWithText(TextField, '75014'), findsOneWidget);
    });

    testWidgets('Paris 75014 : pas d’arrondissement à préciser, Paris est cherché avec ce code postal', (tester) async {
      await _pump(tester, _state(), _etreAccompagnePage());

      await tester.enterText(find.byType(TextField), '75014');
      await tester.pump();
      await _submit(tester, Strings.etreAccompagneMissionLocale);

      expect(find.text(Strings.etreAccompagneCommuneLabel), findsNothing);
      final page = tester.widget<StructuresAccompagnementPage>(find.byType(StructuresAccompagnementPage));
      expect(page.request.commune, _paris14);
      expect(page.request.origine, StructuresAccompagnementCommuneOrigine.saisie);
    });

    testWidgets('API géo lente : chargement sous le bouton désactivé, une seule recherche, puis la liste', (
      tester,
    ) async {
      final repository = _FakeCommunesRepository()..gate = Completer<void>();
      await _pump(tester, _state(), EtreAccompagnePage(communesRepository: repository));

      await tester.enterText(find.byType(TextField), '75014');
      await tester.pump();
      await tester.tap(find.text(Strings.etreAccompagneMissionLocale));
      await tester.pump();
      await tester.ensureVisible(find.text(Strings.etreAccompagneSubmit));
      await tester.tap(find.text(Strings.etreAccompagneSubmit));
      await tester.pump();

      expect(find.text(Strings.etreAccompagneCodePostalChecking), findsOneWidget);
      final button = tester.widget<DsfrButton>(find.widgetWithText(DsfrButton, Strings.etreAccompagneSubmit));
      expect(button.onPressed, isNull);
      expect(find.byType(StructuresAccompagnementPage), findsNothing);

      repository.gate!.complete();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // La recherche lancée au 5e chiffre est reprise, pas relancée.
      expect(repository.calls, 1);
      expect(find.byType(StructuresAccompagnementPage), findsOneWidget);
    });

    testWidgets('API géo injoignable : erreur sous le champ, chargement retiré', (tester) async {
      await _pump(tester, _state(), _etreAccompagnePage());

      await tester.enterText(find.byType(TextField), '99999');
      await tester.pump();
      await _submit(tester, Strings.etreAccompagneFranceTravail);

      expect(find.text(Strings.etreAccompagneErrorCodePostalVerification), findsOneWidget);
      expect(find.text(Strings.etreAccompagneCodePostalChecking), findsNothing);
      expect(find.byType(StructuresAccompagnementPage), findsNothing);
    });

    testWidgets('code postal inconnu : erreur sous le champ', (tester) async {
      await _pump(tester, _state(), _etreAccompagnePage());

      await tester.enterText(find.byType(TextField), '75000');
      await tester.pump();
      await _submit(tester, Strings.etreAccompagneFranceTravail);

      expect(find.text(Strings.etreAccompagneErrorCodePostalInconnu), findsOneWidget);
      expect(find.byType(StructuresAccompagnementPage), findsNothing);
    });

    testWidgets('code postal de plusieurs communes : la commune est demandée', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _state(), _etreAccompagnePage());

      await tester.enterText(find.byType(TextField), '14500');
      await tester.pump();

      expect(find.text(Strings.etreAccompagneCommuneLabel), findsOneWidget);
      expect(find.text('Campagnolles'), findsOneWidget);
      expect(find.text('Vire Normandie'), findsOneWidget);

      await _submit(tester, Strings.etreAccompagneMissionLocale);

      expect(find.text(Strings.etreAccompagneErrorCommuneChoice), findsOneWidget);
      // A11y 9.6 : chaque commune reprend la question et l'erreur.
      final campagnolles = find.byType(DsfrRadioButton<String>).first;
      final label = tester.getSemantics(campagnolles).getSemanticsData().label;
      expect(label, startsWith('Campagnolles'));
      expect(
        label,
        contains(
          '${Strings.etreAccompagneCommuneLabel}, '
          '${Strings.etreAccompagneErrorA11y(Strings.etreAccompagneErrorCommuneChoice)}',
        ),
      );

      await tester.tap(find.text('Campagnolles'));
      await tester.pump();

      expect(tester.getSemantics(campagnolles), isSemantics(isInMutuallyExclusiveGroup: true, isChecked: true));
      expect(find.text(Strings.etreAccompagneErrorCommuneChoice), findsNothing);

      await _submit(tester, null);

      final page = tester.widget<StructuresAccompagnementPage>(find.byType(StructuresAccompagnementPage));
      expect(page.request.commune, _campagnolles);
      handle.dispose();
    });

    testWidgets('commune du questionnaire parmi plusieurs : déjà choisie', (tester) async {
      await _pump(tester, _state(habitation: _vire), _etreAccompagnePage());

      expect(find.widgetWithText(TextField, '14500'), findsOneWidget);
      final vire = tester.widget<DsfrRadioButton<String>>(
        find.widgetWithText(DsfrRadioButton<String>, 'Vire Normandie'),
      );
      expect(vire.groupValue, _vire.code);
    });

    for (final size in [const Size(320, 640), const Size(740, 360)]) {
      testWidgets('texte à 200 % ($size) : rien n’est coupé', (tester) async {
        _setSize(tester, size);
        await _pump(tester, _state(habitation: _vire), _etreAccompagnePage(), textScale: 2);

        expect(find.text('Vire Normandie'), findsOneWidget);

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
