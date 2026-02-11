import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';
import 'package:pass_emploi_app/presentation/chat/chat_home_page_view_model.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  group('Create ChatHomePageViewModel', () {
    test('should display 0 unread when actualites are not loaded', () {
      final store = givenState().store();

      final viewModel = ChatHomePageViewModel.create(store);

      expect(viewModel.unreadMissionLocaleCount, 0);
    });

    test('should count all actualites when no consultation date exists', () {
      final store = givenState()
          .copyWith(
            actualiteMissionLocaleState: ActualiteMissionLocaleSuccessState([
              _actualite('1', DateTime(2026, 2, 10)),
              _actualite('2', DateTime(2026, 2, 11)),
            ]),
            dateConsultationActualiteMissionLocaleState: DateConsultationActualiteMissionLocaleState(),
          )
          .store();

      final viewModel = ChatHomePageViewModel.create(store);

      expect(viewModel.unreadMissionLocaleCount, 2);
    });

    test('should count only newer actualites than consultation date', () {
      final consultationDate = DateTime(2026, 2, 10, 12);
      final store = givenState()
          .copyWith(
            actualiteMissionLocaleState: ActualiteMissionLocaleSuccessState([
              _actualite('1', DateTime(2026, 2, 10, 11)),
              _actualite('2', DateTime(2026, 2, 10, 13)),
              _actualite('3', DateTime(2026, 2, 11, 8)),
            ]),
            dateConsultationActualiteMissionLocaleState: DateConsultationActualiteMissionLocaleState(
              date: consultationDate,
            ),
          )
          .store();

      final viewModel = ChatHomePageViewModel.create(store);

      expect(viewModel.unreadMissionLocaleCount, 2);
    });
  });
}

ActualiteMissionLocale _actualite(String id, DateTime dateCreation) {
  return ActualiteMissionLocale(
    titre: 'Titre $id',
    contenu: 'Corps $id',
    titreLien: '',
    lien: '',
    nomPrenomConseiller: 'Conseiller',
    dateCreation: dateCreation,
    isSupprime: false,
  );
}
