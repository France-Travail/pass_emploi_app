import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/recherche/bloc_resultat_recherche.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/autocomplete_suggestions_group.dart';
import 'package:redux/redux.dart';

import '../../dsl/app_state_dsl.dart';

class _R extends Equatable {
  final String id;

  const _R(this.id);

  @override
  List<Object?> get props => [id];
}

class _Ping {}

RechercheState _state(RechercheStatus status, {List<_R>? results, bool canLoadMore = false}) {
  return RechercheState<Equatable, Equatable, _R>(
    status: status,
    request: null,
    results: results,
    canLoadMore: canLoadMore,
  );
}

void main() {
  group('BlocResultatRecherche : annonces de statut', () {
    late RechercheState current;
    late Store<AppState> store;
    late List<String> announcements;

    Future<void> setUpWidget(WidgetTester tester) async {
      current = _state(RechercheStatus.nouvelleRecherche);
      announcements = [];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
        message,
      ) async {
        if (message is Map && message['type'] == 'announce') {
          announcements.add((message['data'] as Map)['message'] as String);
        }
        return null;
      });
      store = Store<AppState>((state, action) => state, initialState: givenState().loggedIn());
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: BlocResultatRecherche<_R>(
                  listResultatKey: const Key('list'),
                  rechercheState: (_) => current,
                  favorisState: (_) => FavoriIdsState<_R>.notInitialized(),
                  buildResultItem: (context, item, index, vm) => Text(item.id),
                  analyticsType: 'test',
                  placeHolderTitle: 'placeholder',
                  placeHolderSubtitle: 'sous-titre',
                  emptyTitle: 'Aucun résultat',
                  resultsCountLabel: (count) => '$count offre(s)',
                ),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> transitionTo(WidgetTester tester, RechercheState state) async {
      current = state;
      store.dispatch(_Ping());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Laisse le délai de 100 ms de A11yUtils.announce s'écouler même si un frame d'animation a retardé le timer
      await tester.pump(const Duration(milliseconds: 200));
    }

    testWidgets('annonce chargement, résultats, une seule fois par transition', (tester) async {
      await setUpWidget(tester);

      await transitionTo(tester, _state(RechercheStatus.initialLoading));
      expect(announcements, [Strings.rechercheLoadingAnnouncement]);

      await transitionTo(tester, _state(RechercheStatus.success, results: [const _R('a')], canLoadMore: true));
      expect(announcements, [Strings.rechercheLoadingAnnouncement, '1 offre(s)']);

      // Charger plus : pas de nouvelle annonce
      await transitionTo(
        tester,
        _state(RechercheStatus.success, results: [const _R('a'), const _R('b')], canLoadMore: true),
      );
      expect(announcements.length, 2);
    });

    testWidgets('annonce l’erreur puis le chargement après réessai', (tester) async {
      await setUpWidget(tester);

      await transitionTo(tester, _state(RechercheStatus.initialLoading));
      await transitionTo(tester, _state(RechercheStatus.failure));
      expect(announcements.last, Strings.genericError);

      await transitionTo(tester, _state(RechercheStatus.initialLoading));
      expect(announcements, [
        Strings.rechercheLoadingAnnouncement,
        Strings.genericError,
        Strings.rechercheLoadingAnnouncement,
      ]);
    });

    testWidgets('annonce le titre de l’état vide', (tester) async {
      await setUpWidget(tester);

      await transitionTo(tester, _state(RechercheStatus.initialLoading));
      await transitionTo(tester, _state(RechercheStatus.success, results: const []));
      expect(announcements.last, 'Aucun résultat');
    });

    testWidgets('pas d’annonce sur un simple rebuild', (tester) async {
      await setUpWidget(tester);

      await transitionTo(tester, _state(RechercheStatus.initialLoading));
      await transitionTo(tester, _state(RechercheStatus.initialLoading));
      expect(announcements.length, 1);
    });
  });

  testWidgets('Suggestions : le titre est un titre et chaque suggestion un bouton distinct', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AutocompleteSuggestionsGroup(
            title: Strings.rechercheRecentesTitle,
            children: [AutocompleteSuggestionTile(text: 'Vendeur', onTap: () {})],
          ),
        ),
      ),
    );

    final titre = tester.getSemantics(find.text(Strings.rechercheRecentesTitle));
    expect(titre.label, Strings.rechercheRecentesTitle);
    expect(titre.flagsCollection.isHeader, isTrue);
    expect(titre.flagsCollection.isButton, isFalse);

    final suggestion = tester.getSemantics(find.text('Vendeur'));
    expect(suggestion.label, 'Vendeur');
    expect(suggestion.flagsCollection.isButton, isTrue);
    expect(suggestion.flagsCollection.isHeader, isFalse);

    semantics.dispose();
  });
}
