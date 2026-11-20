import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_filtres_recherche.dart';
import 'package:pass_emploi_app/models/service_civique/domain.dart';
import 'package:pass_emploi_app/pages/service_civique/service_civique_filtres_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    final store = givenState().initialRechercheServiceCiviqueState().store();
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          home: Scaffold(body: ServiceCiviqueFiltresPage()),
        ),
      ),
    );
  }

  testWidgets('A11y 6.1 : les titres de section sont des titres de niveau 2, comme dans les autres filtres', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(tester.getSemantics(find.text(Strings.startDateFiltreTitle)).headingLevel, 2);
    expect(tester.getSemantics(find.text(Strings.domainFiltreTitle)).headingLevel, 2);
    semantics.dispose();
  });

  testWidgets('A11y 5.1 / 9.1 / 9.6 : la date est un seul bouton, nommé avec la section, désactivé avec l’interrupteur', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel('${Strings.selectDateTooltip}, ${Strings.startDateFiltreTitle}')),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false),
    );
    semantics.dispose();
  });

  testWidgets('A11y 9.1 : une fois l’interrupteur activé, la date choisie est lue avec le nom du champ', (tester) async {
    final semantics = tester.ensureSemantics();
    final store = givenState()
        .successRechercheServiceCiviqueStateWithRequest(
          filtres: ServiceCiviqueFiltresRecherche(distance: null, startDate: DateTime(2026, 12, 1), domain: null),
        )
        .store();
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          home: Scaffold(body: ServiceCiviqueFiltresPage()),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('${Strings.selectDateTooltip}, ${Strings.startDateFiltreTitle}')),
      isSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        value: '01 décembre 2026',
      ),
    );
    semantics.dispose();
  });

  testWidgets('A11y 9.6 : chaque domaine reprend le titre de la section', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final premier = Domaine.values.first;
    expect(find.bySemanticsLabel('${premier.titre}, ${Strings.domainFiltreTitle}'), findsOneWidget);
    semantics.dispose();
  });
}
