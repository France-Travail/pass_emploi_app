import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/offre_emploi_details.dart';
import 'package:pass_emploi_app/pages/offre_emploi/offre_emploi_details_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/offre_emploi/offre_emploi_details_repository.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/dio_mock.dart';
import '../../doubles/fixtures.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, AppState state) async {
    final store = state.store((factory) {
      factory.detailedOfferRepository = _OffreEmploiDetailsRepositoryStub();
    });
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          onGenerateRoute: (_) => OffreEmploiDetailsPage.materialPageRoute('123TZKB', fromAlternance: false),
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
    testWidgets('$profil, sans messagerie : la fiche ne propose pas de partager l’offre au conseiller', (
      tester,
    ) async {
      await pumpPage(tester, state);

      expect(find.text(Strings.postulerButtonTitle), findsOneWidget);
      expect(find.text(Strings.partagerOffreConseiller), findsNothing);
    });
  }

  testWidgets('jeune accompagné : le bouton ouvre le partage de l’offre au conseiller', (tester) async {
    await pumpPage(tester, givenState().loggedInMiloUser());

    await tester.tap(find.text(Strings.partagerOffreConseiller));
    await tester.pumpAndSettle();

    expect(find.text(Strings.partageOffreNavTitle), findsOneWidget);
    expect(find.text(Strings.partagerOffreEmploi), findsOneWidget);
  });
}

class _OffreEmploiDetailsRepositoryStub extends OffreEmploiDetailsRepository {
  _OffreEmploiDetailsRepositoryStub() : super(DioMock());

  @override
  Future<OffreDetailsResponse<OffreEmploiDetails>> getOffreEmploiDetails({required String offreId}) async {
    return OffreDetailsResponse(isGenericFailure: false, isOffreNotFound: false, details: mockOffreEmploiDetails());
  }
}
