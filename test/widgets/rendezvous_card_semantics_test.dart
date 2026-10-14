import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/rendezvous.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_card_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/cards/rendezvous_card.dart';
import 'package:redux/redux.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  Future<String> pumpAndGetLabel(WidgetTester tester, RendezvousCardViewModel viewModel) async {
    final store = Store<AppState>((state, _) => state, initialState: givenState());
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(body: RendezvousCard(converter: (_) => viewModel, onTap: () {})),
        ),
      ),
    );
    return tester.getSemantics(find.byType(RendezvousCard)).label;
  }

  testWidgets('A11y 8.1 : la carte restitue le statut d’inscription et les places restantes', (tester) async {
    final semantics = tester.ensureSemantics();

    final label = await pumpAndGetLabel(tester, _viewModel(InscriptionStatus.inscrit, placesRestantes: '2 places restantes'));

    expect(label, contains(Strings.eventVousEtesDejaInscrit));
    expect(label, contains('2 places restantes'));
    semantics.dispose();
  });

  testWidgets('A11y 8.1 : la carte restitue « Complet » et « Annulé »', (tester) async {
    final semantics = tester.ensureSemantics();

    final label = await pumpAndGetLabel(tester, _viewModel(InscriptionStatus.full, isAnnule: true));

    expect(label, contains(Strings.eventComplet));
    expect(label, contains(Strings.rendezvousCardAnnule));
    semantics.dispose();
  });

  testWidgets('sans inscription affichée, la carte n’ajoute pas de statut', (tester) async {
    final semantics = tester.ensureSemantics();

    final label = await pumpAndGetLabel(tester, _viewModel(InscriptionStatus.hidden));

    expect(label, 'Atelier. Mon premier CV. 01 janvier 2023. Paris');
    semantics.dispose();
  });
}

RendezvousCardViewModel _viewModel(InscriptionStatus status, {bool isAnnule = false, String? placesRestantes}) {
  return RendezvousCardViewModel(
    id: 'id',
    tag: 'Atelier',
    typeCode: RendezvousTypeCode.ATELIER,
    date: '01 janvier 2023',
    hourAndDuration: '',
    inscriptionStatus: status,
    isAnnule: isAnnule,
    title: 'Mon premier CV',
    description: null,
    place: 'Paris',
    nombreDePlacesRestantes: placesRestantes,
    emoji: null,
    emojiBackground: null,
  );
}
