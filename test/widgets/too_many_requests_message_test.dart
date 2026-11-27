import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:redux/redux.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  const screenError = "Erreur de l'écran";

  AppState rateLimited() => givenState().copyWith(
    tooManyRequestsState: TooManyRequestsState(
      retryNotBefore: DateTime.now().add(Duration(minutes: 1)),
    ),
  );

  AppState rateLimitOver() => givenState().copyWith(
    tooManyRequestsState: TooManyRequestsState(
      retryNotBefore: DateTime.now().subtract(Duration(seconds: 1)),
    ),
  );

  group('Retry', () {
    testWidgets("affiche l'erreur de l'écran hors limite de débit", (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(rateLimitOver(), Retry(screenError, () {}, small: true)),
      );

      expect(find.text(screenError), findsOneWidget);
      expect(find.text(Strings.tooManyRequestsError), findsNothing);
    });

    testWidgets(
      'affiche le message « trop de requêtes » pendant la limite de débit',
      (tester) async {
        await tester.pumpWidget(
          _app(rateLimited(), Retry(screenError, () {}, small: true)),
        );

        expect(find.text(Strings.tooManyRequestsError), findsOneWidget);
        expect(find.text(screenError), findsNothing);
      },
    );
  });

  group('showSnackBarWithApiError', () {
    testWidgets("affiche l'erreur de l'écran hors limite de débit", (
      tester,
    ) async {
      await tester.pumpWidget(_app(givenState(), _SnackBarButton(screenError)));

      await _showSnackBar(tester);

      expect(find.text(screenError), findsOneWidget);
    });

    testWidgets(
      'affiche le message « trop de requêtes » pendant la limite de débit',
      (tester) async {
        await tester.pumpWidget(
          _app(rateLimited(), _SnackBarButton(screenError)),
        );

        await _showSnackBar(tester);

        expect(find.text(Strings.tooManyRequestsError), findsOneWidget);
        expect(find.text(screenError), findsNothing);
      },
    );
  });
}

class _SnackBarButton extends StatelessWidget {
  final String label;

  const _SnackBarButton(this.label);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showSnackBarWithApiError(context, label),
      child: const Text('show'),
    );
  }
}

Widget _app(AppState state, Widget child) {
  return StoreProvider<AppState>(
    store: Store<AppState>((state, action) => state, initialState: state),
    child: MaterialApp(
      scaffoldMessengerKey: snackBarKey,
      home: Scaffold(body: child),
    ),
  );
}

Future<void> _showSnackBar(WidgetTester tester) async {
  await tester.tap(find.text('show'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}
