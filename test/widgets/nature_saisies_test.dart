import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/analytics/ignore_tracking_context_provider.dart';
import 'package:pass_emploi_app/pages/immersion/immersion_contact_form_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/location_autocomplete.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/debounce_text_form_field.dart';
import 'package:redux/redux.dart';

import '../doubles/fixtures.dart';
import '../dsl/app_state_dsl.dart';

/// A11y 9.12 (RAAM) : la nature des saisies est identifiée par la plateforme : `keyboardType` donne l'inputType
/// Android, `autofillHints` le textContentType iOS et l'indice de remplissage automatique Android.
void main() {
  group('Formulaire de contact Immersion', () {
    Future<void> pumpForm(WidgetTester tester) async {
      final store = Store<AppState>(
        (state, _) => state,
        initialState: givenState().loggedInMiloUser().withImmersionDetailsSuccess(
          immersionDetails: mockImmersionDetails(),
        ),
      );
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(home: ImmersionContactFormPage()),
        ),
      );
    }

    Finder field(String label) => find.descendant(
      of: find.byWidgetPredicate((widget) => widget is DsfrInput && widget.label == label, skipOffstage: false),
      matching: find.byType(EditableText, skipOffstage: false),
    );

    String mandatory(String label) => '* $label';
    String optional(String label) => '$label ${Strings.immersitionContactFormOptionalSuffix}';

    final expectations = <String, (TextInputType, List<String>)>{
      mandatory(Strings.immersitionContactFormSurnameHint): (TextInputType.name, [AutofillHints.givenName]),
      mandatory(Strings.immersitionContactFormNameHint): (TextInputType.name, [AutofillHints.familyName]),
      mandatory(Strings.immersitionContactFormEmailHint): (TextInputType.emailAddress, [AutofillHints.email]),
      mandatory(Strings.immersitionContactFormPhoneHint): (TextInputType.phone, [AutofillHints.telephoneNumber]),
      optional(Strings.immersitionContactFormLinkedinLabel): (TextInputType.url, [AutofillHints.url]),
    };

    for (final MapEntry(key: label, value: (keyboardType, autofillHints)) in expectations.entries) {
      testWidgets('« $label » : type ${keyboardType.toJson()['name']}, remplissage $autofillHints', (tester) async {
        await pumpForm(tester);

        final editable = tester.widget<EditableText>(field(label));
        expect(editable.keyboardType, keyboardType);
        expect(editable.autofillHints, autofillHints);
      });
    }

    testWidgets('les champs personnels appartiennent au même groupe de remplissage automatique', (tester) async {
      await pumpForm(tester);

      final groups = expectations.keys
          .map((label) => AutofillGroup.maybeOf(tester.element(field(label))))
          .toSet();
      expect(groups, hasLength(1));
      expect(groups.single, isNotNull);
    });
  });

  group('Saisies plein écran des recherches', () {
    testWidgets('métier et mots clés : texte libre, pas « nom de personne »', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DebounceTextFormField(heroTag: 'tag', initialValue: null, label: 'Métier')),
        ),
      );

      expect(tester.widget<EditableText>(find.byType(EditableText)).keyboardType, TextInputType.text);
    });

    testWidgets('localisation : type adresse', (tester) async {
      final store = Store<AppState>((state, _) => state, initialState: givenState().loggedIn());
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            home: Builder(
              builder: (context) => IgnoreTrackingContext(
                nonTrackingContext: context,
                child: Scaffold(
                  body: LocationAutocomplete(title: 'Localisation', onLocationSelected: (_) {}),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(
        find.descendant(of: find.byType(DebounceTextFormField), matching: find.byType(EditableText)),
      );
      expect(editable.keyboardType, TextInputType.streetAddress);
    });
  });
}
