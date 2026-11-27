import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/evenement_emploi/evenement_emploi_details.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/pages/evenement_emploi/evenement_emploi_details_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/evenement_emploi/evenement_emploi_details_repository.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/dio_mock.dart';
import '../../doubles/fixtures.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, AppState state) async {
    final store = state.store((factory) {
      factory.evenementEmploiDetailsRepository = _EvenementEmploiDetailsRepositoryStub();
    });
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          home: EvenementEmploiDetailsPage(eventId: 'id'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (profil, state) in [
    ("invité", givenState().loggedInUser(loginMode: LoginMode.INVITE)),
    (
      "jeune France Travail demandeur d'emploi sans conseiller",
      givenState().loggedInUser(loginMode: LoginMode.POLE_EMPLOI, accompagnement: Accompagnement.ftDemandeurDEmploi),
    ),
    (
      "jeune France Travail espace candidat sans conseiller",
      givenState().loggedInUser(loginMode: LoginMode.POLE_EMPLOI, accompagnement: Accompagnement.ftEspaceCandidat),
    ),
  ]) {
    testWidgets('$profil, sans messagerie : la fiche ne propose pas de partager l’événement au conseiller', (
      tester,
    ) async {
      await pumpPage(tester, state);

      expect(find.text(Strings.eventEmploiDetailsInscription), findsOneWidget);
      expect(find.text(Strings.eventEmploiDetailsPartagerConseiller), findsNothing);
    });
  }

  testWidgets('jeune accompagné : le bouton ouvre le partage de l’événement au conseiller', (tester) async {
    await pumpPage(tester, givenState().loggedInMiloUser());

    await tester.tap(find.text(Strings.eventEmploiDetailsPartagerConseiller));
    await tester.pumpAndSettle();

    expect(find.text(Strings.partageEvenementEmploiNavTitle), findsOneWidget);
    expect(find.text(Strings.partagerAuConseiller), findsOneWidget);
  });
}

class _EvenementEmploiDetailsRepositoryStub extends EvenementEmploiDetailsRepository {
  _EvenementEmploiDetailsRepositoryStub() : super(DioMock());

  @override
  Future<EvenementEmploiDetails?> get(String idEvenement) async => mockEvenementEmploiDetails();
}
