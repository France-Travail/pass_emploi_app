import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/explorer_metiers_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/tri_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/trouver_des_idees_page.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/piste_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

const _boulanger = RomeMetierResume(code: 'D1102', libelle: 'Boulanger / Boulangère');
const _infirmier = RomeMetierResume(code: 'J1506', libelle: 'Infirmier / Infirmière');

void main() {
  final fiche = RomeFicheMetier.fromJson(
    jsonDecode(File('assets/mode_demo/poc_orientation_fiche_metier.json').readAsStringSync()),
  );

  setUp(() {
    // rootBundle garde ses lectures d'un test à l'autre : on repart d'un cache vide.
    rootBundle.clear();
    MesPistes.instance.reinitialiser();
    MesPistes.instance.demarrerDemo();
  });

  Future<void> afficher(WidgetTester tester, Widget enfant) async {
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: StoreSpy.withState(givenState().loggedInPoleEmploiUser().withDemoMode()),
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: enfant)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> ouvrir(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: StoreSpy.withState(givenState().loggedInPoleEmploiUser().withDemoMode()),
        child: MaterialApp(home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Avis sur un métier', () {
    testWidgets('« Ça me tente » ajoute le métier aux pistes, un second appui l’en retire', (tester) async {
      await afficher(tester, AvisSurLeMetier(fiche: fiche));

      await tester.tap(find.text('Ça me tente'));
      await tester.pumpAndSettle();
      expect(MesPistes.instance.value.piste(fiche.code)?.avis, AvisMetier.meTente);
      expect(find.text('Il est dans tes pistes. Suis les étapes plus bas pour avancer.'), findsOneWidget);

      await tester.tap(find.text('Ça me tente'));
      await tester.pumpAndSettle();
      expect(MesPistes.instance.value.piste(fiche.code), isNull);
    });

    testWidgets('« Pas pour moi » demande les raisons, puis met le métier de côté', (tester) async {
      await afficher(tester, AvisSurLeMetier(fiche: fiche));

      await tester.tap(find.text('Pas pour moi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Le salaire'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mettre de côté'));
      await tester.pumpAndSettle();

      final piste = MesPistes.instance.value.piste(fiche.code)!;
      expect(piste.avis, AvisMetier.pasPourMoi);
      expect(piste.raisons, {RaisonPasPourMoi.salaire});
      expect(find.text('Tu l’as mis de côté : le salaire.'), findsOneWidget);
    });

    testWidgets('« Annuler » ne met pas le métier de côté', (tester) async {
      await afficher(tester, AvisSurLeMetier(fiche: fiche));

      await tester.tap(find.text('Pas pour moi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(MesPistes.instance.value.piste(fiche.code), isNull);
    });
  });

  group('L’accueil en 3 temps', () {
    testWidgets('sans rien à trier ni piste, il propose de trouver des idées, le test en premier', (tester) async {
      await ouvrir(tester, const ExplorerMetiersPage());

      expect(find.bySemanticsLabel('Étape 1 sur 3 : Idées, en cours'), findsOneWidget);
      expect(find.text('Trouver des idées'), findsOneWidget);
      expect(find.text('Faire le test'), findsOneWidget);
      expect(find.text('Les métiers qui te tentent arriveront ici.'), findsOneWidget);
    });

    testWidgets('quand des métiers attendent, il propose de faire le tri', (tester) async {
      MesPistes.instance.ajouterAuTri(SourceAjout.test, [_boulanger, _infirmier], 'Réaliste et Social');

      await ouvrir(tester, const ExplorerMetiersPage());

      expect(find.bySemanticsLabel('Étape 2 sur 3 : Tri, en cours'), findsOneWidget);
      expect(find.text('2 métiers pour toi, tirés de ton test.'), findsOneWidget);
      expect(find.text('Commencer le tri'), findsOneWidget);
    });

    testWidgets('avec une piste, il met en avant sa prochaine étape et annonce ses métiers voisins', (tester) async {
      MesPistes.instance.meTente(_boulanger);

      await ouvrir(tester, const ExplorerMetiersPage());

      expect(find.bySemanticsLabel('Étape 3 sur 3 : Avancer, en cours'), findsOneWidget);
      expect(find.text('Ta prochaine étape'), findsOneWidget);
      expect(find.text('Voir le métier en vidéo'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Mes pistes (1)'), 300);
      expect(find.bySemanticsLabel(RegExp(r'^\d+ nouveaux métiers à trier, voisins de Boulanger$')), findsOneWidget);
    });

    testWidgets('des métiers venus d’ailleurs que les voisins sont simplement « à trier »', (tester) async {
      MesPistes.instance.ajouterAuTri(SourceAjout.test, [_infirmier], 'Social');
      MesPistes.instance.meTente(_boulanger);

      await ouvrir(tester, const ExplorerMetiersPage());

      await tester.scrollUntilVisible(find.text('Mes pistes (1)'), 300);
      expect(find.bySemanticsLabel(RegExp(r'^\d+ métiers à trier$')), findsOneWidget);
    });
  });

  group('Le tri', () {
    testWidgets('un métier à la fois, puis le bilan', (tester) async {
      MesPistes.instance.ajouterAuTri(SourceAjout.test, [_boulanger, _infirmier], 'Réaliste et Social');
      await ouvrir(tester, const TriPage());

      expect(find.text('1 sur 2'), findsOneWidget);
      expect(find.text('D’après ton test : tu es plutôt Réaliste et Social'), findsOneWidget);
      await tester.tap(find.text('Ça me tente'));
      await tester.pumpAndSettle();
      expect(find.text('2 sur 2'), findsOneWidget);

      await tester.tap(find.text('Pas pour moi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mettre de côté'));
      await tester.pumpAndSettle();

      expect(MesPistes.instance.value.piste('D1102')?.avis, AvisMetier.meTente);
      expect(MesPistes.instance.value.piste('J1506')?.avis, AvisMetier.pasPourMoi);
      expect(find.text('Tri terminé'), findsOneWidget);
      expect(find.text('1 métier te tente'), findsOneWidget);
      expect(find.text('1 mis de côté. Tu peux changer d’avis quand tu veux.'), findsOneWidget);
    });

    testWidgets('glisser à droite, c’est « Ça me tente » ; à gauche puis « Annuler », la carte revient', (tester) async {
      MesPistes.instance.ajouterAuTri(SourceAjout.test, [_boulanger, _infirmier], 'Réaliste et Social');
      await ouvrir(tester, const TriPage());

      await tester.drag(find.byType(Dismissible), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(MesPistes.instance.value.piste('D1102')?.avis, AvisMetier.meTente);

      await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Annuler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Qu’est-ce qui ne te convient pas ?'), findsNothing);
      expect(MesPistes.instance.value.piste('J1506'), isNull);
      expect(find.text('2 sur 2'), findsOneWidget);
    });

    testWidgets('sans rien à trier, il renvoie vers les idées', (tester) async {
      await ouvrir(tester, const TriPage());

      expect(find.text('Rien à trier pour l’instant'), findsOneWidget);
    });
  });

  testWidgets('en démo, « Trouver des idées » ne saute pas sur la fiche du métier imposé', (tester) async {
    await ouvrir(tester, const TrouverDesIdeesPage());

    expect(find.byType(FicheMetierPage), findsNothing);
    expect(find.text('Boulanger / Boulangère'), findsOneWidget);
  });
}
