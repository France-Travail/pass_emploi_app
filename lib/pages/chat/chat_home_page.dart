import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/pages/actualite_mission_locale/actualite_mission_locale_page.dart';
import 'package:pass_emploi_app/pages/chat/chat_page.dart';
import 'package:pass_emploi_app/presentation/chat/chat_home_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/pass_emploi_tab_bar.dart';

enum ChatTab { conseiller, missionLocale }

class ChatHomePage extends StatelessWidget {
  final ChatTab? initialTab;

  const ChatHomePage({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ChatHomePageViewModel>(
      converter: (store) => ChatHomePageViewModel.create(store),
      distinct: true,
      builder: (context, viewModel) => DefaultTabController(
        initialIndex: _tabIndex(initialTab),
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.grey100,
          appBar: PrimaryAppBar(title: Strings.menuChat, withAutofocusA11y: true),
          body: Builder(
            builder: (context) {
              if (viewModel.tabs.length == 1) return viewModel.tabs._pages()[0];
              return Column(
                children: [
                  PassEmploiTabBar(
                    tabLabels: viewModel.tabs._titles(),
                    badgeCountByTabIndex: viewModel.unreadMissionLocaleCount > 0
                        ? <int, int>{1: viewModel.unreadMissionLocaleCount}
                        : const <int, int>{},
                  ),
                  Expanded(
                    child: TabBarView(
                      children: viewModel.tabs._pages(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

int _tabIndex(ChatTab? tab) {
  if (tab == null) return 0;
  return switch (tab) {
    ChatTab.conseiller => 0,
    ChatTab.missionLocale => 1,
  };
}

extension _Tabs on List<ChatHomePageTab> {
  List<Widget> _pages() {
    return map((tab) {
      return switch (tab) {
        ChatHomePageTab.conseiller => ChatPage(withScaffold: false, withAppBar: false),
        ChatHomePageTab.missionLocale => ActualiteMissionLocalePage(),
      };
    }).toList();
  }

  List<String> _titles() {
    return map((tab) {
      return switch (tab) {
        ChatHomePageTab.conseiller => Strings.chatTabMonConseiller,
        ChatHomePageTab.missionLocale => Strings.chatTabMaMissionLocale,
      };
    }).toList();
  }
}
