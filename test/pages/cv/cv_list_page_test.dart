import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/pages/cv/cv_list_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  Future<void> pumpCvList(WidgetTester tester, {required bool insideBottomSheet}) async {
    final store = StoreSpy.withState(givenState().loggedInPoleEmploiUser().withCvSuccess());
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CvList(insideBottomSheet: insideBottomSheet)),
          ),
        ),
      ),
    );
  }

  testWidgets('page CV : le texte parle de préparer ses candidatures', (tester) async {
    await pumpCvList(tester, insideBottomSheet: false);

    expect(find.text(Strings.cvListPageSubtitle), findsOneWidget);
    expect(find.text(Strings.postulerSubtitle), findsNothing);
  });

  testWidgets('postuler à une offre : le texte parle de préparer sa candidature', (tester) async {
    await pumpCvList(tester, insideBottomSheet: true);

    expect(find.text(Strings.postulerSubtitle), findsOneWidget);
    expect(find.text(Strings.cvListPageSubtitle), findsNothing);
  });

  testWidgets('chaque CV a un bouton Consulter avec une icône œil', (tester) async {
    await pumpCvList(tester, insideBottomSheet: false);

    expect(find.text(Strings.cvConsultButton), findsNWidgets(2));
    expect(find.byIcon(DsfrIcons.systemEyeLine), findsNWidgets(2));
    expect(find.byIcon(DsfrIcons.systemDownloadLine), findsNothing);
  });
}
