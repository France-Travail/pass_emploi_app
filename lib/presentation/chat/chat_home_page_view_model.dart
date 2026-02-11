import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

enum ChatHomePageTab {
  conseiller,
  missionLocale,
}

class ChatHomePageViewModel extends Equatable {
  final int unreadMissionLocaleCount;
  final List<ChatHomePageTab> tabs;

  ChatHomePageViewModel({required this.unreadMissionLocaleCount, required this.tabs});

  factory ChatHomePageViewModel.create(Store<AppState> store) {
    final state = store.state.loginState;
    final user = state is LoginSuccessState ? state.user : null;
    final isMiLo = user?.loginMode.isMiLo() == true;
    return ChatHomePageViewModel(
      unreadMissionLocaleCount: _unreadActualiteCount(
        store.state.actualiteMissionLocaleState,
        store.state.dateConsultationActualiteMissionLocaleState,
      ),
      tabs: [
        ChatHomePageTab.conseiller,
        if (isMiLo) ChatHomePageTab.missionLocale,
      ],
    );
  }

  @override
  List<Object?> get props => [unreadMissionLocaleCount];
}

int _unreadActualiteCount(
  ActualiteMissionLocaleState actualiteMissionLocaleState,
  DateConsultationActualiteMissionLocaleState dateConsultationActualiteMissionLocaleState,
) {
  if (actualiteMissionLocaleState is! ActualiteMissionLocaleSuccessState) return 0;
  final lastConsultation = dateConsultationActualiteMissionLocaleState.date;
  if (lastConsultation == null) return actualiteMissionLocaleState.result.length;
  return actualiteMissionLocaleState.result
      .where((actualite) => actualite.dateCreation.isAfter(lastConsultation))
      .length;
}
