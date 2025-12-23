import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/models/alerte/evenement_emploi_alerte.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/pages/event_list_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_evenement_emploi_page.dart';
import 'package:pass_emploi_app/presentation/events/event_tab_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/pass_emploi_tab_bar.dart';
import 'package:redux/redux.dart';

class EventsTabPage extends StatefulWidget {
  final EventTab? initialTab;

  EventsTabPage({this.initialTab});

  @override
  State<EventsTabPage> createState() => _EventsTabPageState();
}

class _EventsTabPageState extends State<EventsTabPage> {
  @override
  Widget build(BuildContext context) {
    return AutoFocusA11y(
      child: StoreConnector<AppState, EventsTabPageViewModel>(
        builder: (context, viewModel) => _Body(viewModel, widget.initialTab),
        converter: (store) => EventsTabPageViewModel.create(store),
        onInit: _initializeRechercheEvenementEmploi,
      ),
    );
  }

  void _initializeRechercheEvenementEmploi(Store<AppState> store) {
    if (store.state.rechercheEvenementEmploiState.request != null) return;

    final recent = store.state.recherchesRecentesState.recentSearches;
    final EvenementEmploiAlerte? lastEventSearch = _lastEvenementEmploiSearch(recent);
    if (lastEventSearch == null) return;

    store.dispatch(
      RechercheRequestAction(
        RechercheRequest(
          EvenementEmploiCriteresRecherche(
            location: lastEventSearch.location,
            secteurActivite: lastEventSearch.secteurActivite,
          ),
          EvenementEmploiFiltresRecherche.noFiltre(),
          1,
        ),
      ),
    );
  }
}

EvenementEmploiAlerte? _lastEvenementEmploiSearch(List<Object?> recentSearches) {
  for (final s in recentSearches) {
    if (s is EvenementEmploiAlerte) return s;
  }
  return null;
}

class _Body extends StatelessWidget {
  final EventsTabPageViewModel viewModel;
  final EventTab? initialTab;

  _Body(this.viewModel, this.initialTab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: PrimaryAppBar(title: Strings.eventAppBarTitle, withAutofocusA11y: true),
      body: ConnectivityContainer(
        child: DefaultTabController(
          initialIndex: viewModel.tabs._index(initialTab),
          length: viewModel.tabs.length,
          child: Builder(
            builder: (context) {
              if (viewModel.tabs.length == 1) return viewModel.tabs._pages()[0];
              return Column(
                children: [
                  PassEmploiTabBar(tabLabels: viewModel.tabs._titles()),
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

extension _Tabs on List<EventTab> {
  int _index(EventTab? tab) {
    if (tab == null) return 0;
    final index = indexOf(tab);
    return index == -1 ? 0 : index;
  }

  List<Widget> _pages() {
    return map((tab) {
      return switch (tab) {
        EventTab.maMissionLocale => EventListPage(),
        EventTab.rechercheExternes => RechercheEvenementEmploiPage(),
      };
    }).toList();
  }

  List<String> _titles() {
    return map((tab) {
      return switch (tab) {
        EventTab.maMissionLocale => Strings.eventTabMaMissionLocale,
        EventTab.rechercheExternes => Strings.eventTabExternes,
      };
    }).toList();
  }
}
