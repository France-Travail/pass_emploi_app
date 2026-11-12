import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/cgu/cgu_actions.dart';
import 'package:pass_emploi_app/features/cgu/cgu_state.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/cgu.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/repositories/cgu/cgu_repository.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('CGU', () {
    final sut = StoreSut();
    late MockCguRepository cguRepository;
    late MockRemoteConfigRepository remoteConfigRepository;

    setUp(() {
      cguRepository = MockCguRepository();
      remoteConfigRepository = MockRemoteConfigRepository();
    });

    group("on logged in", () {
      sut.whenDispatchingAction(() => LoginSuccessAction(mockUser(id: 'id-bénéficiaire')));

      test('should not accept CGU when already accepted', () {
        final signature = CguSignature(DateTime(2025));
        final cgu = Cgu(lastUpdate: DateTime(2024), changes: []);

        when(() => cguRepository.get('id-bénéficiaire', isInvite: false)).thenAnswer((_) async => signature);
        when(() => remoteConfigRepository.getCgu()).thenReturn(cgu);

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {
                  f.cguRepository = cguRepository,
                  f.remoteConfigRepository = remoteConfigRepository,
                });

        sut.thenExpectChangingStatesThroughOrder([_shouldNotAcceptCgu()]);
      });

      test('should accept CGU when available but never accepted', () {
        final signature = CguSignature(null);
        final cgu = Cgu(lastUpdate: DateTime(2024), changes: []);

        when(() => cguRepository.get('id-bénéficiaire', isInvite: false)).thenAnswer((_) async => signature);
        when(() => remoteConfigRepository.getCgu()).thenReturn(cgu);

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {
                  f.cguRepository = cguRepository,
                  f.remoteConfigRepository = remoteConfigRepository,
                });

        sut.thenExpectChangingStatesThroughOrder([_shouldAcceptCgu()]);
      });

      test('should accept CGU when updated since accepted', () {
        final signature = CguSignature(DateTime(2023));
        final cgu = Cgu(lastUpdate: DateTime(2024), changes: []);

        when(() => cguRepository.get('id-bénéficiaire', isInvite: false)).thenAnswer((_) async => signature);
        when(() => remoteConfigRepository.getCgu()).thenReturn(cgu);

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {
                  f.cguRepository = cguRepository,
                  f.remoteConfigRepository = remoteConfigRepository,
                });

        sut.thenExpectChangingStatesThroughOrder([_shouldAcceptUpdatedCgu(cgu)]);
      });
    });

    group("on invite logged in", () {
      sut.whenDispatchingAction(
        () => LoginSuccessAction(mockUser(id: 'id-invite', loginMode: LoginMode.INVITE)),
      );

      void setup(CguSignature? signature, Cgu cgu) {
        when(() => cguRepository.get('id-invite', isInvite: true)).thenAnswer((_) async => signature);
        when(() => remoteConfigRepository.getCgu()).thenReturn(cgu);
        sut.givenStore = givenState() //
            .loggedInUser(loginMode: LoginMode.INVITE)
            .store((f) => {
                  f.cguRepository = cguRepository,
                  f.remoteConfigRepository = remoteConfigRepository,
                });
      }

      test('should accept CGU when never accepted', () {
        setup(CguSignature(null), Cgu(lastUpdate: DateTime(2024), changes: []));

        sut.thenExpectChangingStatesThroughOrder([_shouldAcceptCgu()]);
      });

      test('should not ask again once accepted', () {
        setup(CguSignature(DateTime(2025)), Cgu(lastUpdate: DateTime(2024), changes: []));

        sut.thenExpectChangingStatesThroughOrder([_shouldNotAcceptCgu()]);
      });

      test('should ask for update when CGU were updated since accepted', () {
        final cgu = Cgu(lastUpdate: DateTime(2024), changes: []);
        setup(CguSignature(DateTime(2023)), cgu);

        sut.thenExpectChangingStatesThroughOrder([_shouldAcceptUpdatedCgu(cgu)]);
      });
    });

    group("on invite CGU accepted", () {
      sut.whenDispatchingAction(() => CguAcceptedAction(DateTime(2024)));

      test('should save through invite route and update state', () async {
        when(() => cguRepository.save('id', DateTime(2024), isInvite: true)).thenAnswer((_) async => true);
        sut.givenStore = givenState() //
            .copyWith(loginState: LoginSuccessState(mockUser(id: 'id', loginMode: LoginMode.INVITE)))
            .store((f) => {f.cguRepository = cguRepository});

        await sut.thenExpectChangingStatesThroughOrder([_shouldHaveAcceptedCgu()]);

        verify(() => cguRepository.save('id', DateTime(2024), isInvite: true)).called(1);
      });
    });

    group("on invite CGU refused", () {
      sut.whenDispatchingAction(() => CguRefusedAction());

      test('should delete invite then logout', () async {
        when(() => cguRepository.deleteInvite('id')).thenAnswer((_) async => true);
        sut.givenStore = givenState() //
            .copyWith(loginState: LoginSuccessState(mockUser(id: 'id', loginMode: LoginMode.INVITE)))
            .store((f) => {f.cguRepository = cguRepository});

        await sut.thenExpectChangingStatesThroughOrder([_shouldLogout()]);

        verify(() => cguRepository.deleteInvite('id')).called(1);
      });
    });

    group("on CGU accepted", () {
      sut.whenDispatchingAction(() => CguAcceptedAction(DateTime(2024)));

      test('should call repository and update state if successful', () async {
        when(() => cguRepository.save('id', DateTime(2024), isInvite: false)).thenAnswer((_) async => true);

        sut.givenStore = givenState() //
            .loggedIn()
            .store((f) => {
                  f.cguRepository = cguRepository,
                });

        await sut.thenExpectChangingStatesThroughOrder([_shouldHaveAcceptedCgu()]);

        verify(() => cguRepository.save('id', DateTime(2024), isInvite: false)).called(1);
      });

      test('should call repository and keep current state if unsuccessful', () async {
        when(() => cguRepository.save('id', DateTime(2024), isInvite: false)).thenAnswer((_) async => false);

        sut.givenStore = givenState() //
            .loggedIn()
            .store((f) => {
                  f.cguRepository = cguRepository,
                });

        await sut.thenExpectNever(_shouldHaveAcceptedCgu());

        verify(() => cguRepository.save('id', DateTime(2024), isInvite: false)).called(1);
      });
    });

    group("on CGU refused", () {
      sut.whenDispatchingAction(() => CguRefusedAction());

      test('should logout user', () async {
        sut.givenStore = givenState() //
            .loggedIn()
            .store();

        sut.thenExpectChangingStatesThroughOrder([_shouldLogout()]);
      });
    });
  });
}

Matcher _shouldAcceptCgu() => StateIs<CguNeverAcceptedState>((state) => state.cguState);

Matcher _shouldHaveAcceptedCgu() => StateIs<CguAlreadyAcceptedState>((state) => state.cguState);

Matcher _shouldNotAcceptCgu() => StateIs<CguAlreadyAcceptedState>((state) => state.cguState);

Matcher _shouldAcceptUpdatedCgu(Cgu expectedCgu) {
  return StateIs<CguUpdateRequiredState>(
    (state) => state.cguState,
    (state) {
      expect(state.updatedCgu, expectedCgu);
    },
  );
}

Matcher _shouldLogout() => StateIs<LoginNotInitializedState>((state) => state.loginState);
