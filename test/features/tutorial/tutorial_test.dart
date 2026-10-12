import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/tutorial/tutorial_actions.dart';
import 'package:pass_emploi_app/features/tutorial/tutorial_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/fonctionnalite.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/tutorial/tutorial_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/tutorial_repository.dart';
import 'package:redux/redux.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

final List<TutorialPage> miloTutorials = [
  TutorialPage(
    title: 'title MILO',
    description: 'description MILO',
    image: 'image MILO',
  ),
];
final List<TutorialPage> poleEmploiTutorials = [
  TutorialPage(
    title: 'title PE',
    description: 'description PE',
    image: 'image PE',
  ),
];
final List<TutorialPage> planActionTutorials = [
  TutorialPage(title: 'plan 1', description: 'description 1', image: 'image 1'),
  TutorialPage(title: 'plan 2', description: 'description 2', image: 'image 2'),
];

void main() {
  final repository = MockTutorialRepository();

  setUp(() => reset(repository));

  test(
    "Returns tutorial pages list when user didn't see the tutorial and logged in via MILO",
    () async {
      // Given
      when(() => repository.getMiloTutorial()).thenReturn(miloTutorials);
      when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
      final store =
          givenState() //
              .loggedInMiloUser()
              .store((factory) => {factory.tutorialRepository = repository});

      final successState = store.onChange.firstWhere(
        (e) => e.tutorialState is ShowTutorialState,
      );

      // When
      store.dispatch(LoginSuccessAction(mockedMiloUser()));

      // Then
      final successAppState = await successState;
      final dataState = (successAppState.tutorialState as ShowTutorialState);
      expect(dataState.pages, miloTutorials);
    },
  );

  test(
    "Returns tutorial pages list when user didn't see the tutorial and logged in via Pole Emploi",
    () async {
      // Given
      when(
        () => repository.getPoleEmploiTutorial(),
      ).thenReturn(poleEmploiTutorials);
      when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
      final store = givenState().loggedInPoleEmploiUser().store(
        (factory) => {factory.tutorialRepository = repository},
      );

      final successState = store.onChange.firstWhere(
        (e) => e.tutorialState is ShowTutorialState,
      );

      // When
      store.dispatch(LoginSuccessAction(mockedPoleEmploiCejUser()));

      // Then
      final successAppState = await successState;
      final dataState = (successAppState.tutorialState as ShowTutorialState);
      expect(dataState.pages, poleEmploiTutorials);
    },
  );

  test("Does not show plan action tutorial for an invite user", () async {
    // Given
    when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
    when(() => repository.getMiloTutorial()).thenReturn(miloTutorials);
    when(
      () => repository.shouldShowPlanActionTutorial(),
    ).thenAnswer((_) async => true);
    when(
      () => repository.getPlanActionTutorial(),
    ).thenReturn(planActionTutorials);
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .store((factory) => {factory.tutorialRepository = repository});

    final successState = store.onChange.firstWhere(
      (e) => e.tutorialState is ShowTutorialState,
    );

    // When
    store.dispatch(
      LoginSuccessAction(mockUser(loginMode: LoginMode.INVITE, id: "id")),
    );

    // Then
    final successAppState = await successState;
    final dataState = (successAppState.tutorialState as ShowTutorialState);
    expect(dataState.kind, TutorialKind.generic);
    expect(dataState.pages, miloTutorials);
  });

  test("Returns plan action tutorial when Milo user has plan action", () async {
    // Given
    when(
      () => repository.shouldShowPlanActionTutorial(),
    ).thenAnswer((_) async => true);
    when(
      () => repository.getPlanActionTutorial(),
    ).thenReturn(planActionTutorials);
    final store = _store(
      repository,
      givenState().loggedInMiloUser(),
      fonctionnalites: {Fonctionnalite.planAction},
    );
    final successState = store.onChange.firstWhere(
      (e) => e.tutorialState is ShowTutorialState,
    );

    // When
    store.dispatch(LoginSuccessAction(mockedMiloUser()));

    // Then
    final dataState = (await successState).tutorialState as ShowTutorialState;
    expect(dataState.kind, TutorialKind.planAction);
    expect(dataState.pages, planActionTutorials);
    expect(dataState.pages, hasLength(2));
  });

  test(
    "Returns plan action tutorial when France Travail CEJ user has plan action",
    () async {
      // Given
      when(
        () => repository.shouldShowPlanActionTutorial(),
      ).thenAnswer((_) async => true);
      when(
        () => repository.getPlanActionTutorial(),
      ).thenReturn(planActionTutorials);
      final store = _store(
        repository,
        givenState().loggedInPoleEmploiUser(),
        fonctionnalites: {Fonctionnalite.planAction},
      );
      final successState = store.onChange.firstWhere(
        (e) => e.tutorialState is ShowTutorialState,
      );

      // When
      store.dispatch(LoginSuccessAction(mockedPoleEmploiCejUser()));

      // Then
      final dataState = (await successState).tutorialState as ShowTutorialState;
      expect(dataState.kind, TutorialKind.planAction);
      expect(dataState.pages, planActionTutorials);
    },
  );

  test(
    "Returns generic tutorial when Milo user does not have plan action",
    () async {
      // Given
      when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
      when(() => repository.getMiloTutorial()).thenReturn(miloTutorials);
      final store = _store(
        repository,
        givenState().loggedInMiloUser(),
        fonctionnalites: {},
      );
      final successState = store.onChange.firstWhere(
        (e) => e.tutorialState is ShowTutorialState,
      );

      // When
      store.dispatch(LoginSuccessAction(mockedMiloUser()));

      // Then
      final dataState = (await successState).tutorialState as ShowTutorialState;
      expect(dataState.kind, TutorialKind.generic);
      expect(dataState.pages, miloTutorials);
    },
  );

  test(
    "Returns generic tutorial when plan action tutorial was already seen",
    () async {
      // Given
      when(
        () => repository.shouldShowPlanActionTutorial(),
      ).thenAnswer((_) async => false);
      when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
      when(() => repository.getMiloTutorial()).thenReturn(miloTutorials);
      final store = _store(
        repository,
        givenState().loggedInMiloUser(),
        fonctionnalites: {Fonctionnalite.planAction},
      );
      final successState = store.onChange.firstWhere(
        (e) => e.tutorialState is ShowTutorialState,
      );

      // When
      store.dispatch(LoginSuccessAction(mockedMiloUser()));

      // Then
      final dataState = (await successState).tutorialState as ShowTutorialState;
      expect(dataState.kind, TutorialKind.generic);
      expect(dataState.pages, miloTutorials);
    },
  );

  test(
    "Does not show plan action tutorial for a Conseil départemental user",
    () async {
      // Given
      when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
      when(
        () => repository.getPoleEmploiTutorial(),
      ).thenReturn(poleEmploiTutorials);
      final user = mockUser(
        id: "id",
        loginMode: LoginMode.POLE_EMPLOI,
        accompagnement: Accompagnement.rsaConseilsDepartementaux,
      );
      final store = _store(
        repository,
        givenState().loggedInUser(
          loginMode: LoginMode.POLE_EMPLOI,
          accompagnement: Accompagnement.rsaConseilsDepartementaux,
        ),
        fonctionnalites: {Fonctionnalite.planAction},
      );

      // When
      await _dispatchAndWait(store, LoginSuccessAction(user), {
        Fonctionnalite.planAction,
      });

      // Then
      final dataState = store.state.tutorialState as ShowTutorialState;
      expect(dataState.kind, TutorialKind.generic);
      expect(dataState.pages, poleEmploiTutorials);
    },
  );

  test(
    "Does not show plan action tutorial for France Travail outside CEJ",
    () async {
      // Given
      when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
      when(
        () => repository.getPoleEmploiTutorial(),
      ).thenReturn(poleEmploiTutorials);
      final user = mockUser(
        id: "id",
        loginMode: LoginMode.POLE_EMPLOI,
        accompagnement: Accompagnement.aij,
      );
      final store = _store(
        repository,
        givenState().loggedInUser(
          loginMode: LoginMode.POLE_EMPLOI,
          accompagnement: Accompagnement.aij,
        ),
        fonctionnalites: {Fonctionnalite.planAction},
      );

      // When
      await _dispatchAndWait(store, LoginSuccessAction(user), {
        Fonctionnalite.planAction,
      });

      // Then
      final dataState = store.state.tutorialState as ShowTutorialState;
      expect(dataState.kind, TutorialKind.generic);
      expect(dataState.pages, poleEmploiTutorials);
    },
  );

  test("Does not show plan action tutorial in demo mode", () async {
    // Given
    when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
    when(() => repository.getMiloTutorial()).thenReturn(miloTutorials);
    final user = mockUser(id: "id", loginMode: LoginMode.DEMO_MILO);
    final store = _store(
      repository,
      givenState().loggedInUser(loginMode: LoginMode.DEMO_MILO),
      fonctionnalites: {Fonctionnalite.planAction},
    );

    // When
    await _dispatchAndWait(store, LoginSuccessAction(user), {
      Fonctionnalite.planAction,
    });

    // Then
    final dataState = store.state.tutorialState as ShowTutorialState;
    expect(dataState.kind, TutorialKind.generic);
    expect(dataState.pages, miloTutorials);
  });

  test("Does not show plan action tutorial on pass emploi", () async {
    // Given
    Brand.setBrand(Brand.passEmploi);
    addTearDown(() => Brand.setBrand(Brand.cej));
    when(() => repository.shouldShowTutorial()).thenAnswer((_) async => true);
    when(
      () => repository.getPoleEmploiTutorial(),
    ).thenReturn(poleEmploiTutorials);
    final store = _store(
      repository,
      givenState().loggedInPoleEmploiUser(),
      fonctionnalites: {Fonctionnalite.planAction},
    );

    // When
    await _dispatchAndWait(
      store,
      LoginSuccessAction(mockedPoleEmploiCejUser()),
      {Fonctionnalite.planAction},
    );

    // Then
    final dataState = store.state.tutorialState as ShowTutorialState;
    expect(dataState.kind, TutorialKind.generic);
    expect(dataState.pages, poleEmploiTutorials);
  });

  test("Marks the plan action tutorial as read when it is dismissed", () async {
    // Given
    when(
      () => repository.shouldShowPlanActionTutorial(),
    ).thenAnswer((_) async => true);
    when(
      () => repository.getPlanActionTutorial(),
    ).thenReturn(planActionTutorials);
    when(() => repository.setPlanActionTutorialRead()).thenAnswer((_) async {});
    final store = _store(
      repository,
      givenState().loggedInMiloUser(),
      fonctionnalites: {Fonctionnalite.planAction},
    );
    final successState = store.onChange.firstWhere(
      (e) => e.tutorialState is ShowTutorialState,
    );
    store.dispatch(LoginSuccessAction(mockedMiloUser()));
    await successState;

    // When
    store.dispatch(TutorialDoneAction());
    await Future<void>.delayed(Duration.zero);

    // Then
    verify(() => repository.setPlanActionTutorialRead()).called(1);
    verifyNever(() => repository.setTutorialRead());
  });

  test(
    "Returns not initialized tutorial state when user already read the tutorial before",
    () async {
      // Given
      when(
        () => repository.shouldShowTutorial(),
      ).thenAnswer((_) async => false);
      when(() => repository.setTutorialRead()).thenAnswer((_) async {});
      final store = givenState().loggedInPoleEmploiUser().store(
        (factory) => {factory.tutorialRepository = repository},
      );
      await store.dispatch(TutorialDoneAction());

      // When
      await store.dispatch(LoginSuccessAction(mockedMiloUser()));

      // Then
      expect(store.state.tutorialState, isA<TutorialNotInitializedState>());
    },
  );
}

Store<AppState> _store(
  MockTutorialRepository repository,
  AppState state, {
  required Set<Fonctionnalite> fonctionnalites,
}) {
  final fonctionnalitesRepository = MockFonctionnalitesRepository();
  when(
    () => fonctionnalitesRepository.get(any()),
  ).thenAnswer((_) async => fonctionnalites);
  return state.store((factory) {
    factory.tutorialRepository = repository;
    factory.fonctionnalitesRepository = fonctionnalitesRepository;
  });
}

Future<void> _dispatchAndWait(
  Store<AppState> store,
  dynamic action,
  Set<Fonctionnalite> fonctionnalites,
) async {
  final settled = store.onChange.firstWhere((state) {
    return state.tutorialState is ShowTutorialState &&
        state.fonctionnalitesState.actives.containsAll(fonctionnalites);
  });
  store.dispatch(action);
  await settled;
  await Future<void>.delayed(Duration.zero);
}

class TutorialRepositoryStub extends TutorialRepository {
  TutorialRepositoryStub() : super(FlutterSecureStorageSpy());

  @override
  List<TutorialPage> getMiloTutorial() => miloTutorials;

  @override
  List<TutorialPage> getPoleEmploiTutorial() => poleEmploiTutorials;
}
