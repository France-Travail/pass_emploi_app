import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_actions.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_reducer.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

const _lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');

const _request = StructuresAccompagnementRequest(
  type: StructureAccompagnementType.missionLocale,
  commune: _lille,
  origine: StructuresAccompagnementCommuneOrigine.saisie,
);

const _missionLocale = StructureAccompagnement(
  nom: 'Mission Locale de Lille',
  adresse: StructureAccompagnementAdresse(ligne: '5 Bd du Maréchal Vaillant', codePostal: '59800', ville: 'Lille'),
  telephone: '03 20 00 00 00',
);

void main() {
  group('StructuresAccompagnement', () {
    final sut = StoreSut();
    final repository = MockStructuresAccompagnementRepository();

    setUpAll(() => registerFallbackValue(StructureAccompagnementType.missionLocale));

    void givenRepositoryAnswers(List<StructureAccompagnement>? result) {
      when(
        () => repository.get(
          type: any(named: 'type'),
          codeInsee: any(named: 'codeInsee'),
          codePostal: any(named: 'codePostal'),
        ),
      ).thenAnswer((_) async => result);
    }

    group("when requesting", () {
      sut.whenDispatchingAction(() => StructuresAccompagnementRequestAction(_request));

      test('should send the commune codes, load then succeed', () async {
        givenRepositoryAnswers([_missionLocale]);
        sut.givenStore =
            givenState() //
                .loggedInUser(loginMode: LoginMode.INVITE)
                .store((f) => {f.structuresAccompagnementRepository = repository});

        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceed()]);
        verify(
          () => repository.get(
            type: StructureAccompagnementType.missionLocale,
            codeInsee: '59350',
            codePostal: '59000',
          ),
        ).called(1);
      });

      test('should load then fail when request fails', () {
        givenRepositoryAnswers(null);
        sut.givenStore =
            givenState() //
                .loggedInUser(loginMode: LoginMode.INVITE)
                .store((f) => {f.structuresAccompagnementRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFail()]);
      });

      test('should do nothing for a jeune connecté (route reserved to invités)', () {
        givenRepositoryAnswers([_missionLocale]);
        sut.givenStore =
            givenState() //
                .loggedInUser(loginMode: LoginMode.MILO)
                .store((f) => {f.structuresAccompagnementRepository = repository});

        sut.thenExpectNever(_shouldLoad());
      });
    });

    group('reducer', () {
      final otherRequest = StructuresAccompagnementRequest(
        type: StructureAccompagnementType.franceTravail,
        commune: _lille,
        origine: StructuresAccompagnementCommuneOrigine.saisie,
      );

      test('ignores a late answer to a previous search', () {
        final state = structuresAccompagnementReducer(
          StructuresAccompagnementLoadingState(otherRequest),
          StructuresAccompagnementSuccessAction(_request, [_missionLocale]),
        );

        expect(state, StructuresAccompagnementLoadingState(otherRequest));
      });

      test('ignores an answer arriving after leaving the list', () {
        final state = structuresAccompagnementReducer(
          StructuresAccompagnementNotInitializedState(),
          StructuresAccompagnementFailureAction(_request),
        );

        expect(state, StructuresAccompagnementNotInitializedState());
      });

      test('reset goes back to not initialized', () {
        final state = structuresAccompagnementReducer(
          StructuresAccompagnementSuccessState(_request, [_missionLocale]),
          StructuresAccompagnementResetAction(),
        );

        expect(state, StructuresAccompagnementNotInitializedState());
      });
    });
  });
}

Matcher _shouldLoad() => StateIs<StructuresAccompagnementLoadingState>((state) => state.structuresAccompagnementState);

Matcher _shouldFail() => StateIs<StructuresAccompagnementFailureState>((state) => state.structuresAccompagnementState);

Matcher _shouldSucceed() {
  return StateIs<StructuresAccompagnementSuccessState>(
    (state) => state.structuresAccompagnementState,
    (state) {
      expect(state.request, _request);
      expect(state.result, [_missionLocale]);
    },
  );
}
