import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_actions.dart';
import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_state.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/invite_prenom_repository.dart';
import 'package:redux/src/store.dart';

import '../../doubles/fixtures.dart';
import '../../utils/test_setup.dart';

class _InvitePrenomRepositoryStub extends Mock implements InvitePrenomRepository {}

void main() {
  late _InvitePrenomRepositoryStub repository;

  setUp(() {
    repository = _InvitePrenomRepositoryStub();
  });

  test('after invite login, empty prenom should show the form', () async {
    when(() => repository.getPrenom(any())).thenAnswer((_) async => '');

    final testStoreFactory = TestStoreFactory();
    testStoreFactory.invitePrenomRepository = repository;
    final store = testStoreFactory.initializeReduxStore(
      initialState: AppState.initialState(),
    );
    final successState = store.onChange.firstWhere((state) => state.invitePrenomState is InvitePrenomSuccessState);

    store.dispatch(LoginSuccessAction(mockUser(id: 'invite-id', loginMode: LoginMode.INVITE)));

    final state = await successState;
    expect((state.invitePrenomState as InvitePrenomSuccessState).prenom, '');
  });

  test('retry should load prenom after a previous failure', () async {
    when(() => repository.getPrenom(any())).thenAnswer((_) async => 'Adrien');

    final testStoreFactory = TestStoreFactory();
    testStoreFactory.invitePrenomRepository = repository;
    final store = testStoreFactory.initializeReduxStore(
      initialState: AppState.initialState().copyWith(
        loginState: LoginSuccessState(mockUser(id: 'invite-id', loginMode: LoginMode.INVITE)),
        invitePrenomState: InvitePrenomFailureState(),
      ),
    );
    final successState = store.onChange.firstWhere((state) => state.invitePrenomState is InvitePrenomSuccessState);

    store.dispatch(InvitePrenomRequestAction());

    final state = await successState;
    expect((state.invitePrenomState as InvitePrenomSuccessState).prenom, 'Adrien');
  });
}
