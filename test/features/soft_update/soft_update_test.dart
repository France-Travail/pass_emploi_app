import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/soft_update/soft_update_actions.dart';
import 'package:pass_emploi_app/features/soft_update/soft_update_state.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('SoftUpdate', () {
    final sut = StoreSut();
    final repository = MockSoftUpdateRepository();
    final remoteConfigRepository = MockRemoteConfigRepository();

    group('when checking for update', () {
      sut.whenDispatchingAction(() => SoftUpdateCheckAction());

      test('should show soft update when repository says so', () {
        // given
        when(() => remoteConfigRepository.softUpdateVersion(isAndroid: any(named: 'isAndroid'))).thenReturn('99.0.0');
        when(() => repository.shouldShowSoftUpdate('99.0.0')).thenAnswer((_) async => true);
        // when
        sut.givenStore = givenState().store(
          (f) => {
            f.softUpdateRepository = repository,
            f.remoteConfigRepository = remoteConfigRepository,
          },
        );
        // then
        sut.thenExpectAtSomePoint(_shouldShowSoftUpdate());
      });

      test('should not show soft update when repository says no', () {
        // given
        when(() => remoteConfigRepository.softUpdateVersion(isAndroid: any(named: 'isAndroid'))).thenReturn('99.0.0');
        when(() => repository.shouldShowSoftUpdate('99.0.0')).thenAnswer((_) async => false);
        // when
        sut.givenStore = givenState().store(
          (f) => {
            f.softUpdateRepository = repository,
            f.remoteConfigRepository = remoteConfigRepository,
          },
        );
        // then
        sut.thenExpectNever(_shouldShowSoftUpdate());
      });
    });

    group('when dismissing', () {
      sut.whenDispatchingAction(() => SoftUpdateDismissAction());

      test('should hide soft update and persist dismiss', () {
        // given
        when(() => repository.dismiss()).thenAnswer((_) async {});
        // when
        sut.givenStore = givenState()
            .copyWith(softUpdateState: ShowSoftUpdateState())
            .store((f) => {f.softUpdateRepository = repository});
        // then
        sut.thenExpectChangingStatesThroughOrder([_shouldNotShowSoftUpdate()]);
        verify(() => repository.dismiss()).called(1);
      });
    });

    group('when downloading', () {
      sut.whenDispatchingAction(() => SoftUpdateDownloadAction());

      test('should hide soft update', () {
        sut.givenStore = givenState()
            .copyWith(softUpdateState: ShowSoftUpdateState())
            .store((f) => {f.softUpdateRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldNotShowSoftUpdate()]);
      });
    });
  });
}

Matcher _shouldShowSoftUpdate() => StateIs<ShowSoftUpdateState>((state) => state.softUpdateState);

Matcher _shouldNotShowSoftUpdate() => StateIs<SoftUpdateNotShownState>((state) => state.softUpdateState);
