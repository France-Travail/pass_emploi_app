import 'package:flutter/material.dart';
import 'package:pass_emploi_app/pages/actualite_mission_locale/actualite_mission_locale_page.dart';
import 'package:pass_emploi_app/pages/chat/chat_page.dart';
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
    return DefaultTabController(
      initialIndex: _tabIndex(initialTab),
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grey100,
        appBar: PrimaryAppBar(title: Strings.menuChat, withAutofocusA11y: true),
        body: Column(
          children: [
            PassEmploiTabBar(tabLabels: [Strings.chatTabMonConseiller, Strings.chatTabMaMissionLocale]),
            Expanded(
              child: TabBarView(
                children: [
                  ChatPage(withScaffold: false, withAppBar: false),
                  ActualiteMissionLocalePage(),
                ],
              ),
            ),
          ],
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
