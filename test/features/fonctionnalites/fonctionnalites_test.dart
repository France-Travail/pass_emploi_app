import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_actions.dart';
import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_state.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/push_notification/register/register_push_notification_token_actions.dart';
import 'package:pass_emploi_app/models/fonctionnalite.dart';
import 'package:pass_emploi_app/models/login_mode.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('Fonctionnalites', () {
    final sut = StoreSut();

    group("when requesting", () {
      sut.whenDispatchingAction(() => FonctionnalitesRequestAction());

      test('should load then succeed when request succeeds', () {
        final repository = MockFonctionnalitesRepository();
        when(() => repository.get(any())).thenAnswer((_) async => {Fonctionnalite.planAction});

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .store((f) => {f.fonctionnalitesRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceedWithPlanAction()]);
      });

      test('should load then fail when request fails, so the app stays closed', () {
        final repository = MockFonctionnalitesRepository();
        when(() => repository.get(any())).thenAnswer((_) async => null);

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .store((f) => {f.fonctionnalitesRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFail()]);
      });

      test('should not call repository when user is not logged in', () async {
        final repository = MockFonctionnalitesRepository();
        sut.givenStore = givenState().store((f) => {f.fonctionnalitesRepository = repository});

        await sut.thenExpectNothing();

        verifyNever(() => repository.get(any()));
      });
    });

    group("when logging in", () {
      sut.whenDispatchingAction(() => LoginSuccessAction(mockUser(id: 'userId', loginMode: LoginMode.MILO)));

      test('should load then succeed', () {
        final repository = MockFonctionnalitesRepository();
        when(() => repository.get('userId')).thenAnswer((_) async => {Fonctionnalite.planAction});

        sut.givenStore = givenState().store((f) => {f.fonctionnalitesRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceedWithPlanAction()]);
      });
    });

    group("when app comes back to foreground", () {
      sut.whenDispatchingAction(() => ConfigureApplicationOnForegroundAction());

      test('should pick up a fonctionnalite newly activated on the back', () {
        final repository = MockFonctionnalitesRepository();
        when(() => repository.get(any())).thenAnswer((_) async => {Fonctionnalite.planAction});

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .withoutFonctionnalites()
                .store((f) => {f.fonctionnalitesRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldSucceedWithPlanAction()]);
      });

      test('should not go through loading, so the jeune is not sent back to the splash screen', () {
        final repository = MockFonctionnalitesRepository();
        when(() => repository.get(any())).thenAnswer((_) async => {Fonctionnalite.planAction});

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .withoutFonctionnalites()
                .store((f) => {f.fonctionnalitesRepository = repository});

        sut.thenExpectNever(_shouldLoad());
      });

      test('should not call repository when user is not logged in', () async {
        final repository = MockFonctionnalitesRepository();
        sut.givenStore = givenState().store((f) => {f.fonctionnalitesRepository = repository});

        await sut.thenExpectNothing();

        verifyNever(() => repository.get(any()));
      });
    });
  });
}

Matcher _shouldLoad() => StateIs<FonctionnalitesLoadingState>((state) => state.fonctionnalitesState);

Matcher _shouldFail() => StateIs<FonctionnalitesFailureState>((state) => state.fonctionnalitesState);

Matcher _shouldSucceedWithPlanAction() {
  return StateMatch((state) => state.fonctionnalitesState.actives.contains(Fonctionnalite.planAction));
}
