import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/evenement_emploi/details/evenement_emploi_details_state.dart';
import 'package:pass_emploi_app/pages/chat/chat_partage_bottom_sheet.dart';
import 'package:pass_emploi_app/presentation/chat/chat_partage_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/fixtures.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  Future<void> pumpEtOuvrirLePartage(WidgetTester tester) async {
    final store = givenState()
        .loggedInMiloUser()
        .copyWith(evenementEmploiDetailsState: EvenementEmploiDetailsSuccessState(mockEvenementEmploiDetails()))
        .store();
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ChatPartageBottomSheet.show(context, ChatPartageEvenementEmploiSource()),
                child: const Text('Ouvrir le partage'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir le partage'));
    await tester.pumpAndSettle();
  }

  // Le vrai ChatRepository échoue en lisant la conversation : aucune app Firebase n'existe dans les tests.
  testWidgets('un partage qui échoue affiche l’erreur et permet de réessayer', (tester) async {
    await pumpEtOuvrirLePartage(tester);

    await tester.tap(find.text(Strings.partagerAuConseiller));
    await tester.pumpAndSettle();

    expect(find.text(Strings.miscellaneousErrorRetry), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(Strings.partagerAuConseiller), findsOneWidget);
  });
}
