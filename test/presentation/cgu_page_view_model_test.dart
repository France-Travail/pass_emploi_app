import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/cgu/cgu_actions.dart';
import 'package:pass_emploi_app/features/cgu/cgu_state.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';
import 'package:pass_emploi_app/models/cgu.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/cgu_page_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  test('create when CGU never accepted', () {
    // Given
    final store = givenState().withCguNeverAccepted().store();

    // When
    final viewModel = CguPageViewModel.create(store);

    // Then
    expect(viewModel.displayState, CguNeverAcceptedDisplayState());
  });

  test('create when CGU update required', () {
    // Given
    final store = givenState()
        .withCguUpdateRequired(
          Cgu(
            lastUpdate: DateTime(2024, 1, 2),
            changes: ['change 1', 'change 2'],
          ),
        )
        .store();

    // When
    final viewModel = CguPageViewModel.create(store);

    // Then
    expect(
      viewModel.displayState,
      CguUpdateRequiredDisplayState(
        lastUpdateLabel: '02 janvier 2024',
        changes: ['change 1', 'change 2'],
      ),
    );
  });

  group('encart d’information sur le refus', () {
    test('affiché pour un invité', () {
      // Given
      final store = givenState().loggedInUser(loginMode: LoginMode.INVITE).withCguNeverAccepted().store();

      // When
      final viewModel = CguPageViewModel.create(store);

      // Then
      expect(viewModel.withInviteRefusalNotice, isTrue);
    });

    test('masqué pour un jeune Mission Locale ou France Travail', () {
      for (final loginMode in [LoginMode.MILO, LoginMode.POLE_EMPLOI]) {
        // Given
        final store = givenState().loggedInUser(loginMode: loginMode).withCguNeverAccepted().store();

        // When
        final viewModel = CguPageViewModel.create(store);

        // Then
        expect(viewModel.withInviteRefusalNotice, isFalse, reason: loginMode.name);
      }
    });
  });

  group('erreur à l’acceptation', () {
    test('message générique quand l’acceptation des CGU jamais acceptées a échoué', () {
      final store = givenState().copyWith(cguState: CguNeverAcceptedState(acceptFailed: true)).store();

      expect(CguPageViewModel.create(store).acceptErrorMessage, Strings.miscellaneousErrorRetry);
    });

    test('message générique quand l’acceptation des CGU mises à jour a échoué', () {
      final cgu = Cgu(lastUpdate: DateTime(2024), changes: []);
      final store = givenState().copyWith(cguState: CguUpdateRequiredState(cgu, acceptFailed: true)).store();

      expect(CguPageViewModel.create(store).acceptErrorMessage, Strings.miscellaneousErrorRetry);
    });

    test('message « trop de requêtes » pendant la limite de débit', () {
      final store = givenState()
          .copyWith(
            cguState: CguNeverAcceptedState(acceptFailed: true),
            tooManyRequestsState: TooManyRequestsState(retryNotBefore: DateTime.now().add(Duration(minutes: 1))),
          )
          .store();

      expect(CguPageViewModel.create(store).acceptErrorMessage, Strings.tooManyRequestsError);
    });

    test('aucun message sans échec', () {
      final store = givenState().withCguNeverAccepted().store();

      expect(CguPageViewModel.create(store).acceptErrorMessage, isNull);
    });
  });

  test('onAccept should dispatch CguAcceptedAction', () {
    withClock(Clock.fixed(DateTime(2024, 7, 7)), () {
      // Given
      final store = StoreSpy();
      final viewModel = CguPageViewModel.create(store);

      // When
      viewModel.onAccept();

      // Then
      expect(store.dispatchedAction, isA<CguAcceptedAction>());
      expect((store.dispatchedAction as CguAcceptedAction).date, DateTime(2024, 7, 7));
    });
  });

  test('onRefuse should dispatch CguRefusedAction', () {
    // Given
    final store = StoreSpy();
    final viewModel = CguPageViewModel.create(store);

    // When
    viewModel.onRefuse();

    // Then
    expect(store.dispatchedAction, isA<CguRefusedAction>());
  });
}
