import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('FeatureFlip', () {
    final sut = StoreSut();
    final remoteConfigRepository = MockRemoteConfigRepository();

    group('invite access password on bootstrap', () {
      sut.whenDispatchingAction(() => BootstrapAction());

      test('should store password from remote config', () {
        when(() => remoteConfigRepository.inviteAccessPassword()).thenReturn("remote-password!");

        sut.givenStore = givenState().store((f) => {f.remoteConfigRepository = remoteConfigRepository});

        sut.thenExpectChangingStatesThroughOrder([_shouldHaveInviteAccessPassword("remote-password!")]);
      });

      test('should keep no password when remote config has none', () {
        when(() => remoteConfigRepository.inviteAccessPassword()).thenReturn(null);

        sut.givenStore = givenState().store((f) => {f.remoteConfigRepository = remoteConfigRepository});

        sut.thenExpectNever(_shouldHaveAnyInviteAccessPassword());
      });
    });
  });
}

Matcher _shouldHaveInviteAccessPassword(String password) {
  return StateMatch((state) => state.featureFlipState.featureFlip.inviteAccessPassword == password);
}

Matcher _shouldHaveAnyInviteAccessPassword() {
  return StateMatch((state) => state.featureFlipState.featureFlip.inviteAccessPassword != null);
}
