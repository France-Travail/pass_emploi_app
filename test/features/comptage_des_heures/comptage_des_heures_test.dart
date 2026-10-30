import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/auto_inscription/auto_inscription_actions.dart';
import 'package:pass_emploi_app/features/comptage_des_heures/comptage_des_heures_actions.dart';
import 'package:pass_emploi_app/features/comptage_des_heures/comptage_des_heures_state.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_actions.dart';
import 'package:pass_emploi_app/features/user_action/create/user_action_create_actions.dart';
import 'package:pass_emploi_app/models/date/interval.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('ComptageDesHeures', () {
    final sut = StoreSut();
    final repository = MockComptageDesHeuresRepository();

    group("when requesting", () {
      sut.whenDispatchingAction(() => ComptageDesHeuresRequestAction());

      test('should load then succeed when request succeeds', () {
        when(() => repository.get(userId: any(named: "userId"))).thenAnswer((_) async => mockComptageDesHeures());

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.comptageDesHeuresRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldSucceed()]);
      });

      test('should not load when user is not a Milo', () {
        sut.givenStore = givenState() //
            .loggedInPoleEmploiUser()
            .store((f) => {f.comptageDesHeuresRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([]);
      });

      test('should load then fail when request fails', () {
        when(() => repository.get(userId: any(named: "userId"))).thenAnswer((_) async => null);

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.comptageDesHeuresRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldFail()]);
      });

      test('should not emit new state if comptage des heures is the same', () {
        when(() => repository.get(userId: any(named: "userId"))).thenAnswer((_) async => mockComptageDesHeures());

        sut.givenStore = givenState() //
            .loggedInUser()
            .withComptageDesHeuresSuccess(comptageDesHeures: mockComptageDesHeures())
            .store((f) => {f.comptageDesHeuresRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([]);
      });
    });

    group("when current period of mon suivi is loaded", () {
      final monSuiviAvecComptage = mockMonSuivi(peutVoirLeComptageDesHeures: true);
      final interval = Interval(DateTime(2024, 1, 29), DateTime(2024, 3, 3));

      group("and user can see comptage des heures", () {
        sut.whenDispatchingAction(() => MonSuiviSuccessAction(MonSuiviPeriod.current, interval, monSuiviAvecComptage));

        test('should load comptage des heures', () {
          when(() => repository.get(userId: any(named: "userId"))).thenAnswer((_) async => mockComptageDesHeures());

          sut.givenStore = givenState() //
              .loggedInMiloUser()
              .store((f) => {f.comptageDesHeuresRepository = repository});

          sut.thenExpectChangingStatesThroughOrder([_shouldSucceed()]);
        });

        test('should load comptage des heures again after a failure', () {
          when(() => repository.get(userId: any(named: "userId"))).thenAnswer((_) async => mockComptageDesHeures());

          sut.givenStore = givenState() //
              .loggedInMiloUser()
              .withComptageDesHeuresFailure()
              .store((f) => {f.comptageDesHeuresRepository = repository});

          sut.thenExpectChangingStatesThroughOrder([_shouldSucceed()]);
        });
      });

      test('should not load comptage des heures again once loaded', () async {
        final repository = MockComptageDesHeuresRepository();
        final store = givenState() //
            .loggedInMiloUser()
            .withComptageDesHeuresSuccess(comptageDesHeures: mockComptageDesHeures())
            .store((f) => {f.comptageDesHeuresRepository = repository});

        await store.dispatch(MonSuiviSuccessAction(MonSuiviPeriod.current, interval, monSuiviAvecComptage));

        verifyNever(() => repository.get(userId: any(named: "userId")));
      });

      test('should not load comptage des heures when user cannot see it', () async {
        final repository = MockComptageDesHeuresRepository();
        final store = givenState() //
            .loggedInMiloUser()
            .store((f) => {f.comptageDesHeuresRepository = repository});

        await store.dispatch(MonSuiviSuccessAction(MonSuiviPeriod.current, interval, mockMonSuivi()));

        verifyNever(() => repository.get(userId: any(named: "userId")));
      });

      test('should not load comptage des heures when another period is loaded', () async {
        final repository = MockComptageDesHeuresRepository();
        final store = givenState() //
            .loggedInMiloUser()
            .monSuivi(interval: interval, monSuivi: monSuiviAvecComptage)
            .store((f) => {f.comptageDesHeuresRepository = repository});

        await store.dispatch(MonSuiviSuccessAction(MonSuiviPeriod.next, interval, monSuiviAvecComptage));

        verifyNever(() => repository.get(userId: any(named: "userId")));
      });
    });

    group("when creating action", () {
      sut.whenDispatchingAction(() => UserActionCreateSuccessAction('any'));

      test('should increment heures en cours de calcul when user action create success', () {
        sut.givenStore = givenState() //
            .loggedInUser()
            .withComptageDesHeuresSuccess(comptageDesHeures: mockComptageDesHeures())
            .store((f) => {f.comptageDesHeuresRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldIncrementHeuresEnCoursDeCalcul()]);
      });
    });

    group("when auto-inscription success", () {
      sut.whenDispatchingAction(() => AutoInscriptionSuccessAction());

      test('should increment heures en cours de calcul when user action create success', () {
        sut.givenStore = givenState() //
            .loggedInUser()
            .withComptageDesHeuresSuccess(comptageDesHeures: mockComptageDesHeures())
            .store((f) => {f.comptageDesHeuresRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldIncrementHeuresEnCoursDeCalcul()]);
      });
    });
  });
}

Matcher _shouldFail() => StateIs<ComptageDesHeuresFailureState>((state) => state.comptageDesHeuresState);

Matcher _shouldSucceed() {
  return StateIs<ComptageDesHeuresSuccessState>(
    (state) => state.comptageDesHeuresState,
    (state) {
      expect(
        state.comptageDesHeures,
        mockComptageDesHeures(),
      );
    },
  );
}

Matcher _shouldIncrementHeuresEnCoursDeCalcul() {
  return StateIs<ComptageDesHeuresSuccessState>(
    (state) => state.comptageDesHeuresState,
    (state) {
      expect(state.heuresEnCoursDeCalcul, 1);
    },
  );
}
