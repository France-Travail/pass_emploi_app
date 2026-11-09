import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

enum SolutionsTab { recherche, offresEnregistrees, alertes }

class SolutionsTabPageViewModel extends Equatable {
  final List<SolutionsTab> tabs;

  SolutionsTabPageViewModel._({
    required this.tabs,
  });

  bool get withTabBar => tabs.length > 1;

  factory SolutionsTabPageViewModel.create(Store<AppState> store) {
    // Temporaire (mise en production du mode invité) : le suivi des offres et les alertes
    // ne sont pas proposés aux invités.
    final isInvite = store.state.isInviteLoginMode();
    return SolutionsTabPageViewModel._(
      tabs: [
        SolutionsTab.recherche,
        if (!isInvite) ...[
          SolutionsTab.offresEnregistrees,
          SolutionsTab.alertes,
        ],
      ],
    );
  }

  @override
  List<Object?> get props => [tabs];
}

extension SolutionsTabTitles on List<SolutionsTab> {
  List<String> titles() {
    return map((tab) {
      return switch (tab) {
        SolutionsTab.recherche => Strings.rechercheTabTitle,
        SolutionsTab.offresEnregistrees => Strings.offresEnregistreesTabTitle,
        SolutionsTab.alertes => Strings.alertesTabTitle,
      };
    }).toList();
  }
}
