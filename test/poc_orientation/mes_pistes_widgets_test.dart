import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/explorer_metiers_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/piste_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  final fiche = RomeFicheMetier.fromJson(
    jsonDecode(File('assets/mode_demo/poc_orientation_fiche_metier.json').readAsStringSync()),
  );

  setUp(() {
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

  testWidgets('en démo, la page « Explorer les métiers » ne saute pas sur la fiche du métier imposé', (tester) async {
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: StoreSpy.withState(givenState().loggedInPoleEmploiUser().withDemoMode()),
        child: const MaterialApp(home: ExplorerMetiersPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FicheMetierPage), findsNothing);
    expect(find.text('Boulanger / Boulangère'), findsOneWidget);
  });
}
