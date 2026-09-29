import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/pages/alerte_page.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:redux/redux.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  testWidgets('Snackbar d’erreur des offres suivies : message et bouton de fermeture sont des nœuds distincts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    // Given
    final initialState = givenState().loggedIn();
    final store = _replaceStateStore(initialState);
    await tester.pumpWidget(
      _app(
        store,
        Scaffold(
          body: FavorisStateContext<OffreEmploi>(
            selectState: (_) => FavoriIdsState<OffreEmploi>.notInitialized(),
            child: FavoriHeart<OffreEmploi>(offreId: 'offre-id', withBorder: false, from: OffrePage.emploiResults),
          ),
        ),
      ),
    );

    // When
    store.dispatch(initialState.copyWith(favoriUpdateState: FavoriUpdateState({'offre-id': FavoriUpdateStatus.ERROR})));
    await _showSnackBar(tester);

    // Then
    _expectCloseButton(tester, Strings.closeInformationMessage);
    _expectTextNode(tester, Strings.error);
    _expectTextNode(tester, Strings.favoriUpdateError);

    semantics.dispose();
  });

  testWidgets('Snackbar de succès des alertes : message, lien et bouton de fermeture sont des nœuds distincts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    // Given
    final initialState = givenState().loggedIn().notInitTraiterSuggestionRecherche();
    final store = _replaceStateStore(initialState);
    await tester.pumpWidget(_app(store, AlertePage()));

    // When
    store.dispatch(initialState.succeedAccepterSuggestionRecherche());
    await _showSnackBar(tester);

    // Then
    _expectCloseButton(tester, 'Fermer');
    _expectTextNode(tester, Strings.suggestionRechercheAjoutee);
    _expectTextNode(tester, Strings.suggestionRechercheAjouteeDescription);

    final linkFinder = find.bySemanticsLabel(RegExp(Strings.voirResultatsSuggestion));
    expect(linkFinder, findsOneWidget);
    final link = tester.getSemantics(linkFinder);
    expect(link, containsSemantics(isLink: true, hasTapAction: true));
    expect(link.label, isNot(contains(Strings.suggestionRechercheAjouteeDescription)));
    expect(link.label, isNot(contains('Fermer')));
    expect(_hasLiveRegionAncestor(link), isTrue);

    semantics.dispose();
  });
}

Store<AppState> _replaceStateStore(AppState initialState) {
  return Store<AppState>((state, action) => action is AppState ? action : state, initialState: initialState);
}

Widget _app(Store<AppState> store, Widget home) {
  return StoreProvider<AppState>(
    store: store,
    child: MaterialApp(scaffoldMessengerKey: snackBarKey, home: home),
  );
}

Future<void> _showSnackBar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void _expectCloseButton(WidgetTester tester, String label) {
  final finder = find.bySemanticsLabel(label);
  expect(finder, findsOneWidget);
  final node = tester.getSemantics(finder);
  expect(node.label, label);
  expect(node, containsSemantics(isButton: true, hasTapAction: true));
  expect(node.rect.size, const Size(48, 48));
  expect(_hasLiveRegionAncestor(node), isTrue);
}

void _expectTextNode(WidgetTester tester, String text) {
  final finder = find.bySemanticsLabel(text);
  expect(finder, findsOneWidget);
  final node = tester.getSemantics(finder);
  expect(node, containsSemantics(isButton: false, hasTapAction: false));
  expect(_hasLiveRegionAncestor(node), isTrue);
}

bool _hasLiveRegionAncestor(SemanticsNode node) {
  SemanticsNode? current = node;
  while (current != null) {
    if (current.getSemanticsData().flagsCollection.isLiveRegion) return true;
    current = current.parent;
  }
  return false;
}
