import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/chat/status/chat_status_state.dart';
import 'package:pass_emploi_app/features/cvm/cvm_actions.dart';
import 'package:pass_emploi_app/features/cvm/cvm_state.dart';
import 'package:pass_emploi_app/models/chat/sender.dart';
import 'package:pass_emploi_app/presentation/chat/cvm_chat_item.dart';
import 'package:pass_emploi_app/presentation/chat/cvm_chat_page_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';

import '../../doubles/fixtures.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  group('displayState', () {
    test('loading', () {
      // Given
      final store = givenState().copyWith(cvmState: CvmLoadingState()).store();

      // When
      final viewModel = CvmChatPageViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.LOADING);
    });

    test('failure', () {
      // Given
      final store = givenState().copyWith(cvmState: CvmFailureState()).store();

      // When
      final viewModel = CvmChatPageViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.FAILURE);
    });

    test('empty not handled', () {
      // Given
      final store = givenState().withCvmMessage(messages: []).store();

      // When
      final viewModel = CvmChatPageViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.CONTENT);
    });
  });

  test('full test', () {
    final now = DateTime.now();
    final todayAtNoon = DateTime(now.year, now.month, now.day, 12, 00);
    final january2 = DateTime(2021, 1, 2, 16);
    final lastConseillerReading = DateTime(2021, 1, 1, 16, 30);
    // Given
    final store = givenState()
        .withCvmMessage(messages: [
          mockCvmTextMessage(id: 'id0', content: '0', date: DateTime(2021, 1, 1, 12, 30), sentBy: Sender.jeune),
          mockCvmTextMessage(id: 'id1', content: '1', date: DateTime(2021, 1, 1, 15, 30), sentBy: Sender.conseiller),
          mockCvmTextMessage(id: 'id2', content: '2', date: lastConseillerReading, sentBy: Sender.jeune),
          mockCvmUnknownMessage(id: 'id5', date: DateTime(2021, 1, 1, 19, 00)),
          mockCvmFileMessage(id: 'id3', url: 'u', fileName: 'fn', fileId: 'fi', date: january2),
          mockCvmTextMessage(id: 'id4', content: '4', date: todayAtNoon, sentBy: Sender.jeune),
        ])
        .copyWith(
          chatStatusState: ChatStatusSuccessState(
            hasUnreadMessages: false,
            lastConseillerReading: lastConseillerReading,
          ),
        )
        .store();

    // When
    final viewModel = CvmChatPageViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.CONTENT);
    expect(viewModel.items, [
      CvmDayItem('Le 01/01/2021'),
      CvmTextMessageItem(messageId: 'id0', content: '0', caption: '12:30 · Lu', sender: Sender.jeune),
      CvmTextMessageItem(messageId: 'id1', content: '1', caption: '15:30', sender: Sender.conseiller),
      CvmTextMessageItem(messageId: 'id2', content: '2', caption: '16:30 · Lu', sender: Sender.jeune),
      CvmInformationItem(
        'Le message est inaccessible',
        'Pour avoir l\'accès au contenu, veuillez mettre à jour l\'application.',
      ),
      CvmDayItem('Le 02/01/2021'),
      CvmPieceJointeConseillerMessageItem(
          sender: Sender.conseiller, messageId: 'id3', url: 'u', fileName: 'fn', fileId: 'fi', caption: '16:00'),
      CvmDayItem('Aujourd\'hui'),
      CvmTextMessageItem(messageId: 'id4', content: '4', caption: '12:00 · Envoyé', sender: Sender.jeune),
    ]);
  });

  group('brouillon', () {
    test('when present', () {
      // Given
      final store = givenState().chatBrouillon("coucou").store();

      // When
      final viewModel = CvmChatPageViewModel.create(store);

      // Then
      expect(viewModel.brouillon, "coucou");
    });

    test('when absent', () {
      // Given
      final store = givenState().store();

      // When
      final viewModel = CvmChatPageViewModel.create(store);

      // Then
      expect(viewModel.brouillon, isNull);
    });
  });

  test('sendMessage', () {
    // Given
    final store = givenState().spyStore();
    final viewModel = CvmChatPageViewModel.create(store);

    // When
    viewModel.onSendMessage('message');

    // Then
    expect(store.dispatchedAction, isA<CvmSendMessageAction>());
    expect((store.dispatchedAction as CvmSendMessageAction).message, 'message');
  });
}
