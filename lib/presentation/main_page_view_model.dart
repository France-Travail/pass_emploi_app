import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/features/chat/status/chat_status_state.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

enum MainTab { accueil, monSuivi, chat, solutions, evenements }

enum MainPageDisplayState {
  accueil,
  monSuivi,
  chat,
  evenements,
  evenementsRecherche,
  solutionsRecherche,
  solutionsOffresEnregistrees,
  solutionsAlertes,
  actualisationPoleEmploi,
  chatActualiteMissionLocale,
}

class MainPageViewModel extends Equatable {
  final List<MainTab> tabs;
  final bool withChatBadge;
  final Function resetDeeplink;
  final String actualisationPoleEmploiUrl;

  MainPageViewModel({
    required this.tabs,
    required this.withChatBadge,
    required this.resetDeeplink,
    required this.actualisationPoleEmploiUrl,
  });

  factory MainPageViewModel.create(Store<AppState> store) {
    final chatStatusState = store.state.chatStatusState;
    final user = store.state.user();

    final hasUnreadChat = (chatStatusState is ChatStatusSuccessState) && (chatStatusState.hasUnreadMessages);
    final hasNewActualite = _hasNewActualite(
      store.state.actualiteMissionLocaleState,
      store.state.dateConsultationActualiteMissionLocaleState,
    );

    return MainPageViewModel(
      tabs: [
        MainTab.accueil,
        if (user?.accompagnement != Accompagnement.avenirPro) MainTab.monSuivi,
        MainTab.chat,
        MainTab.solutions,
        MainTab.evenements,
      ],
      withChatBadge: hasUnreadChat || hasNewActualite,
      resetDeeplink: () => store.dispatch(ResetDeeplinkAction()),
      actualisationPoleEmploiUrl: store.state.configurationState.configuration?.actualisationPoleEmploiUrl ?? "",
    );
  }

  @override
  List<Object?> get props => [tabs, withChatBadge];
}

bool _hasNewActualite(
  ActualiteMissionLocaleState actualiteMissionLocaleState,
  DateConsultationActualiteMissionLocaleState dateConsultationActualiteMissionLocaleState,
) {
  if (actualiteMissionLocaleState is! ActualiteMissionLocaleSuccessState) return false;
  final lastConsultation = dateConsultationActualiteMissionLocaleState.date;
  if (lastConsultation == null) return actualiteMissionLocaleState.result.isNotEmpty;
  return actualiteMissionLocaleState.result.any((actualite) => actualite.dateCreation.isAfter(lastConsultation));
}
