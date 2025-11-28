import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/chat/messages/chat_actions.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_state.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/user_action/create/user_action_create_actions.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

class RechercheEventRequestMock extends Mock
    implements RechercheRequest<EvenementEmploiCriteresRecherche, EvenementEmploiFiltresRecherche> {}

class RechercheOffreRequestMock extends Mock
    implements RechercheRequest<EmploiCriteresRecherche, EmploiFiltresRecherche> {}

void main() {
  setUpAll(() {
    registerFallbackValue(Onboarding());
  });

  group('Onboarding', () {
    final sut = StoreSut();
    final repository = MockOnboardingRepository();
    final pushNotificationManager = MockPushNotificationManager();

    group("on bootstrap", () {
      sut.whenDispatchingAction(() => BootstrapAction());

      test('should succeed when request succeeds', () {
        when(() => repository.get()).thenAnswer((_) async => Onboarding());

        sut.givenStore =
            givenState() //
                .store((f) => {f.onboardingRepository = repository});

        sut.thenExpectAtSomePoint(_shouldSucceed(Onboarding()));
      });
    });

    group("when requesting push notification permission", () {
      sut.whenDispatchingAction(() => OnboardingPushNotificationPermissionRequestAction());

      test('should wait for requested permission and update onboarding state', () {
        final givenOnboarding = Onboarding(showNotificationsOnboarding: true);

        when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
        when(() => repository.save(any())).thenAnswer((_) async {});
        when(() => pushNotificationManager.requestPermission()).thenAnswer((_) async {});

        sut.givenStore =
            givenState() //
                .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                .store(
                  (f) => {f.onboardingRepository = repository, f.pushNotificationManager = pushNotificationManager},
                );

        sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(showNotificationsOnboarding: false)));
        verify(() => pushNotificationManager.requestPermission()).called(1);
      });
    });

    group('on completed', () {
      group('when sending a message', () {
        sut.whenDispatchingAction(() => SendMessageAction('any'));

        test('should update onboarding state', () {
          final givenOnboarding = Onboarding();

          when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
          when(() => repository.save(any())).thenAnswer((_) async {});

          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(messageCompleted: true)));
        });
      });

      group('when creating a user action', () {
        sut.whenDispatchingAction(() => UserActionCreateSuccessAction('any'));

        test('should update onboarding state', () {
          final givenOnboarding = Onboarding();

          when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
          when(() => repository.save(any())).thenAnswer((_) async {});

          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(actionCompleted: true)));
        });
      });

      group('when creating a demarche', () {
        sut.whenDispatchingAction(() => CreateDemarcheSuccessAction('any'));

        test('should update onboarding state', () {
          final givenOnboarding = Onboarding();

          when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
          when(() => repository.save(any())).thenAnswer((_) async {});

          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(actionCompleted: true)));
        });
      });

      group('when searching for evenement', () {
        sut.whenDispatchingAction(
          () => RechercheRequestAction<EvenementEmploiCriteresRecherche, EvenementEmploiFiltresRecherche>(
            RechercheEventRequestMock(),
          ),
        );

        test('should update onboarding state', () {
          final givenOnboarding = Onboarding();

          when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
          when(() => repository.save(any())).thenAnswer((_) async {});

          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(evenementCompleted: true)));
        });
      });

      group('when searching for offre', () {
        sut.whenDispatchingAction(
          () => RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>(RechercheOffreRequestMock()),
        );

        test('should update onboarding state', () {
          final givenOnboarding = Onboarding();

          when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
          when(() => repository.save(any())).thenAnswer((_) async {});

          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(offreCompleted: true)));
        });
      });
    });

    group('on started', () {
      final givenOnboarding = Onboarding();

      group("MessageOnboardingStartedAction", () {
        sut.whenDispatchingAction(() => MessageOnboardingStartedAction());

        test('should showMessageOnboarding', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store();

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showMessageOnboarding, true);
            }),
          );
        });
      });
      group("ActionOnboardingStartedAction", () {
        sut.whenDispatchingAction(() => ActionOnboardingStartedAction());

        test('should showActionOnboarding', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store();

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showActionOnboarding, true);
            }),
          );
        });
      });
      group("OffreOnboardingStartedAction", () {
        sut.whenDispatchingAction(() => OffreOnboardingStartedAction());

        test('should showOffreOnboarding', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store();

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showOffreOnboarding, true);
            }),
          );
        });
      });
      group("EvenementOnboardingStartedAction", () {
        sut.whenDispatchingAction(() => EvenementOnboardingStartedAction());

        test('should showEvenementOnboarding', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store();

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showEvenementOnboarding, true);
            }),
          );
        });
      });
      group("OutilsOnboardingStartedAction", () {
        sut.whenDispatchingAction(() => OutilsOnboardingStartedAction());

        test('should showOutilsOnboarding', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                  .store();

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showOutilsOnboarding, true);
            }),
          );
        });
      });
    });

    group('_updateOnboarding', () {
      setUp(() {
        reset(repository);
      });

      sut.whenDispatchingAction(() => SendMessageAction('any'));

      test('should save onboarding and dispatch OnboardingSuccessAction with updated steps', () {
        final givenOnboarding = Onboarding();

        when(() => repository.get()).thenAnswer((_) async => givenOnboarding);
        when(() => repository.save(any())).thenAnswer((_) async {});

        sut.givenStore =
            givenState() //
                .copyWith(onboardingState: OnboardingState(onboarding: givenOnboarding))
                .store((f) => {f.onboardingRepository = repository});

        sut.thenExpectAtSomePoint(_shouldSucceed(givenOnboarding.copyWith(messageCompleted: true)));
        verify(() => repository.save(givenOnboarding.copyWith(messageCompleted: true))).called(1);
      });
    });

    group('reducer logic for _updateOnboarding', () {
      group('when message is completed', () {
        sut.whenDispatchingAction(() => OnboardingSuccessAction(Onboarding(messageCompleted: true)));

        test('should hide message showcase', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(showMessageOnboarding: true))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showMessageOnboarding, false);
              expect(state.onboarding?.messageCompleted, true);
            }),
          );
        });
      });

      group('when message is not completed', () {
        sut.whenDispatchingAction(() => OnboardingSuccessAction(Onboarding(messageCompleted: false)));

        test('should keep message showcase visible', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(showMessageOnboarding: true))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showMessageOnboarding, true);
              expect(state.onboarding?.messageCompleted, false);
            }),
          );
        });
      });

      group('when action is completed', () {
        sut.whenDispatchingAction(() => OnboardingSuccessAction(Onboarding(actionCompleted: true)));

        test('should hide action showcase', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(showActionOnboarding: true))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showActionOnboarding, false);
              expect(state.onboarding?.actionCompleted, true);
            }),
          );
        });
      });

      group('when offre is completed', () {
        sut.whenDispatchingAction(() => OnboardingSuccessAction(Onboarding(offreCompleted: true)));

        test('should hide offre showcase', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(showOffreOnboarding: true))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showOffreOnboarding, false);
              expect(state.onboarding?.offreCompleted, true);
            }),
          );
        });
      });

      group('when evenement is completed', () {
        sut.whenDispatchingAction(() => OnboardingSuccessAction(Onboarding(evenementCompleted: true)));

        test('should hide evenement showcase', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(showEvenementOnboarding: true))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showEvenementOnboarding, false);
              expect(state.onboarding?.evenementCompleted, true);
            }),
          );
        });
      });

      group('when outils is completed', () {
        sut.whenDispatchingAction(() => OnboardingSuccessAction(Onboarding(outilsCompleted: true)));

        test('should hide outils showcase', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(showOutilsOnboarding: true))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showOutilsOnboarding, false);
              expect(state.onboarding?.outilsCompleted, true);
            }),
          );
        });
      });

      group('when multiple steps are completed', () {
        sut.whenDispatchingAction(
          () =>
              OnboardingSuccessAction(Onboarding(messageCompleted: true, actionCompleted: true, offreCompleted: false)),
        );

        test('should hide multiple showcases', () {
          sut.givenStore =
              givenState() //
                  .copyWith(
                    onboardingState: OnboardingState(
                      showMessageOnboarding: true,
                      showActionOnboarding: true,
                      showOffreOnboarding: true,
                    ),
                  )
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.showMessageOnboarding, false);
              expect(state.showActionOnboarding, false);
              expect(state.showOffreOnboarding, true);
              expect(state.onboarding?.messageCompleted, true);
              expect(state.onboarding?.actionCompleted, true);
              expect(state.onboarding?.offreCompleted, false);
            }),
          );
        });
      });

      group('when all steps are completed', () {
        final newOnboarding = Onboarding(
          messageCompleted: true,
          actionCompleted: true,
          offreCompleted: true,
          evenementCompleted: true,
          outilsCompleted: true,
        );

        sut.whenDispatchingAction(() => OnboardingSuccessAction(newOnboarding));

        test('should update onboarding data correctly', () {
          sut.givenStore =
              givenState() //
                  .copyWith(onboardingState: OnboardingState(onboarding: Onboarding()))
                  .store((f) => {f.onboardingRepository = repository});

          sut.thenExpectAtSomePoint(
            StateIs<OnboardingState>((state) => state.onboardingState, (state) {
              expect(state.onboarding, newOnboarding);
            }),
          );
        });
      });
    });
  });
}

Matcher _shouldSucceed(Onboarding onboarding) {
  return StateIs<OnboardingState>((state) => state.onboardingState, (state) {
    expect(state.onboarding, onboarding);
  });
}
