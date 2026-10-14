import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:redux/redux.dart';

import '../dsl/app_state_dsl.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';

void main() {
  group("getAnalyticsWidgetName with from and isFavori", () {
    void assertAnalyticsWidgetName(OffrePage from, bool isFavori, String? expected) {
      test("AppPage: $from & isFavori: $isFavori -> $expected", () {
        // Given
        final helper = FavoriHeartAnalyticsHelper();
        // When
        final result = helper.getAnalyticsWidgetName(from, isFavori);
        // Then
        expect(result, expected);
      });
    }

    assertAnalyticsWidgetName(OffrePage.offreFavoris, false, "favoris/list?favori=false");
    assertAnalyticsWidgetName(OffrePage.offreFavoris, true, null); // Cannot add favori from favori page

    assertAnalyticsWidgetName(OffrePage.emploiResults, true, "/solutions/emploi/search_results?favori=true");
    assertAnalyticsWidgetName(OffrePage.emploiResults, false, "/solutions/emploi/search_results?favori=false");
    assertAnalyticsWidgetName(OffrePage.emploiDetails, true, "/solutions/emploi/detail?favori=true");
    assertAnalyticsWidgetName(OffrePage.emploiDetails, false, "/solutions/emploi/detail?favori=false");

    assertAnalyticsWidgetName(OffrePage.alternanceResults, true, "/solutions/alternance/search_results?favori=true");
    assertAnalyticsWidgetName(OffrePage.alternanceResults, false, "/solutions/alternance/search_results?favori=false");
    assertAnalyticsWidgetName(OffrePage.alternanceDetails, true, "/solutions/alternance/detail?favori=true");
    assertAnalyticsWidgetName(OffrePage.alternanceDetails, false, "/solutions/alternance/detail?favori=false");

    assertAnalyticsWidgetName(
      OffrePage.serviceCiviqueResults,
      true,
      "/solutions/service_civique/search_results?favori=true",
    );
    assertAnalyticsWidgetName(
      OffrePage.serviceCiviqueResults,
      false,
      "/solutions/service_civique/search_results?favori=false",
    );
    assertAnalyticsWidgetName(OffrePage.serviceCiviqueDetails, true, "/solutions/service_civique/detail?favori=true");
    assertAnalyticsWidgetName(OffrePage.serviceCiviqueDetails, false, "/solutions/service_civique/detail?favori=false");

    assertAnalyticsWidgetName(OffrePage.immersionResults, true, "/solutions/immersion/search_results?favori=true");
    assertAnalyticsWidgetName(OffrePage.immersionResults, false, "/solutions/immersion/search_results?favori=false");
    assertAnalyticsWidgetName(OffrePage.immersionDetails, true, "/solutions/immersion/detail?favori=true");
    assertAnalyticsWidgetName(OffrePage.immersionDetails, false, "/solutions/immersion/detail?favori=false");
  });

  testWidgets("A11y 5.1 : le bouton restitue le nom de l'offre", (tester) async {
    final semantics = tester.ensureSemantics();
    final store = Store<AppState>((state, _) => state, initialState: givenState());
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: FavorisStateContext<OffreEmploi>(
              selectState: (store) => store.state.offreEmploiFavorisIdsState,
              child: FavoriHeart<OffreEmploi>(
                offreId: "id",
                withBorder: false,
                from: OffrePage.emploiDetails,
                a11yLabel: "Boulanger",
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip("Enregistrer l'offre Boulanger"), findsOneWidget);
    semantics.dispose();
  });
}
