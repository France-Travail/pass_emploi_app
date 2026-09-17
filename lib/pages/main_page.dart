import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gaimon/gaimon.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/chat/status/chat_status_actions.dart';
import 'package:pass_emploi_app/features/theme/theme_state.dart';
import 'package:pass_emploi_app/pages/accueil/accueil_page.dart';
import 'package:pass_emploi_app/pages/chat/chat_home_page.dart';
import 'package:pass_emploi_app/pages/events_tab_page.dart';
import 'package:pass_emploi_app/pages/mon_suivi_page.dart';
import 'package:pass_emploi_app/pages/solutions_tabs_page.dart';
import 'package:pass_emploi_app/presentation/events/event_tab_page_view_model.dart';
import 'package:pass_emploi_app/presentation/main_page_view_model.dart';
import 'package:pass_emploi_app/presentation/solutions_tabs_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_navigation.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';
import 'package:pass_emploi_app/widgets/pass_emploi_material_app.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class MainPage extends StatefulWidget {
  final MainPageDisplayState displayState;
  final int deepLinkKey;

  MainPage({this.displayState = MainPageDisplayState.accueil, this.deepLinkKey = 0})
    : super(key: ValueKey(displayState.hashCode + deepLinkKey));

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const _indexNotInitialized = -1;

  bool _deepLinkHandled = false;
  int _selectedIndex = _indexNotInitialized;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      StoreProvider.of<AppState>(context).dispatch(UnsubscribeFromChatStatusAction());
    }
    if (state == AppLifecycleState.resumed) {
      StoreProvider.of<AppState>(context).dispatch(SubscribeToChatStatusAction());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MainPageViewModel>(
      converter: (store) => MainPageViewModel.create(store),
      onInitialBuild: (viewModel) {
        if (widget.displayState == MainPageDisplayState.actualisationPoleEmploi) {
          viewModel.resetDeeplink();
          _showActualisationPeDialog(viewModel.actualisationPoleEmploiUrl);
        }
      },
      onInit: (store) {
        store.dispatch(SubscribeToChatStatusAction());
        store.dispatch(ActualiteMissionLocaleRequestAction());
      },
      onDispose: (store) => store.dispatch(UnsubscribeFromChatStatusAction()),
      builder: (context, viewModel) => _body(viewModel, context),
      distinct: true,
    );
  }

  void _showActualisationPeDialog(String actualisationPoleEmploiUrl) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      barrierLabel: Strings.bottomSheetBarrierLabel,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: _PopUpActualisationPe(actualisationPoleEmploiUrl),
        ),
      ),
    );
  }

  Widget _body(MainPageViewModel viewModel, BuildContext context) {
    _setInitIndexPage(viewModel);
    return _ModeDemoWrapper(
      child: Scaffold(
        backgroundColor: context.bg,
        body: Container(
          color: context.grey100,
          child: _content(_selectedIndex, viewModel),
        ),
        bottomNavigationBar: DsfrBottomNavigation(
          currentIndex: _selectedIndex,
          onTap: (index) => _onItemTapped(index, viewModel),
          items: viewModel.tabs.map((e) => e.asNavItem(viewModel)).toList(),
        ),
      ),
    );
  }

  void _onItemTapped(int index, MainPageViewModel viewModel) {
    Gaimon.selection();
    setState(() => _selectedIndex = index);
  }

  Widget _content(int index, MainPageViewModel viewModel) {
    return switch (viewModel.tabs[index]) {
      MainTab.accueil => AccueilPage(),
      MainTab.monSuivi => MonSuiviPage(),
      MainTab.chat => _chatPage(),
      MainTab.solutions => _solutionsPage(viewModel),
      MainTab.evenements => _eventsPage(viewModel),
    };
  }

  Widget _solutionsPage(MainPageViewModel viewModel) {
    final initialTab = !_deepLinkHandled ? _initialSolutionsTab() : null;
    _deepLinkHandled = true;
    return SolutionsTabPage(initialTab: initialTab);
  }

  Widget _chatPage() {
    final initialTab = !_deepLinkHandled ? _initialChatTab() : null;
    _deepLinkHandled = true;
    return ChatHomePage(initialTab: initialTab);
  }

  Widget _eventsPage(MainPageViewModel viewModel) {
    final initialTab = !_deepLinkHandled ? _initialEventsTab() : null;
    _deepLinkHandled = true;
    return EventsTabPage(initialTab: initialTab);
  }

  SolutionsTab? _initialSolutionsTab() {
    return switch (widget.displayState) {
      MainPageDisplayState.solutionsOffresEnregistrees => SolutionsTab.offresEnregistrees,
      MainPageDisplayState.solutionsAlertes => SolutionsTab.alertes,
      _ => null,
    };
  }

  EventTab? _initialEventsTab() {
    return switch (widget.displayState) {
      MainPageDisplayState.evenementsRecherche => EventTab.rechercheExternes,
      _ => null,
    };
  }

  ChatTab? _initialChatTab() {
    return switch (widget.displayState) {
      MainPageDisplayState.chatActualiteMissionLocale => ChatTab.missionLocale,
      _ => null,
    };
  }

  void _setInitIndexPage(MainPageViewModel viewModel) {
    if (_selectedIndex != _indexNotInitialized) return;

    final tabs = viewModel.tabs;
    final int initialIndex = switch (widget.displayState) {
      MainPageDisplayState.accueil => tabs.indexOf(MainTab.accueil),
      MainPageDisplayState.actualisationPoleEmploi => tabs.indexOf(MainTab.accueil),
      MainPageDisplayState.monSuivi => tabs.indexOf(MainTab.monSuivi),
      MainPageDisplayState.chat => tabs.indexOf(MainTab.chat),
      MainPageDisplayState.chatActualiteMissionLocale => tabs.indexOf(MainTab.chat),
      MainPageDisplayState.solutionsRecherche => tabs.indexOf(MainTab.solutions),
      MainPageDisplayState.solutionsOffresEnregistrees => tabs.indexOf(MainTab.solutions),
      MainPageDisplayState.solutionsAlertes => tabs.indexOf(MainTab.solutions),
      MainPageDisplayState.evenements => tabs.indexOf(MainTab.evenements),
      MainPageDisplayState.evenementsRecherche => tabs.indexOf(MainTab.evenements),
    };
    _selectedIndex = initialIndex != -1 ? initialIndex : 0;
  }
}

class _ModeDemoWrapper extends StatelessWidget {
  final Widget child;

  const _ModeDemoWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    final isDemo = store.state.demoState;
    if (!isDemo) return child;
    final themeState = store.state.themeState;
    final themeMode = themeState is ThemeSuccessState ? themeState.themeMode : ThemeMode.light;
    return Scaffold(
      backgroundColor: context.bg,
      appBar: ModeDemoAppBar(),
      body: PassEmploiMaterialApp(
        themeMode: themeMode,
        scaffoldMessengerKey: modeDemoSnackBarKey,
        debugShowCheckedModeBanner: false,
        builder: (context, materialAppChild) => MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: materialAppChild ?? Container(),
        ),
        // required to avoid automatic top scrolling when keyboard is displayed
        useInheritedMediaQuery: true,
        home: child,
      ),
    );
  }
}

class _PopUpActualisationPe extends StatelessWidget {
  final String actualisationPoleEmploiUrl;

  const _PopUpActualisationPe(this.actualisationPoleEmploiUrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.actualisationPePopUpTitle,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.actualisationPePopUpSubtitle,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        Semantics(
          link: true,
          child: DsfrButton(
            label: Strings.actualisationPePopUpPrimaryButton,
            icon: DsfrIcons.systemExternalLinkLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: () => _onActualisationPressed(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.actualisationPePopUpSecondaryButton,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _onActualisationPressed(BuildContext context) {
    Navigator.pop(context);
    PassEmploiMatomoTracker.instance.trackOutlink(actualisationPoleEmploiUrl);
    launchExternalUrl(actualisationPoleEmploiUrl);
  }
}

extension _MainTab on MainTab {
  DsfrBottomNavigationItem asNavItem(MainPageViewModel viewModel) {
    return switch (this) {
      MainTab.accueil => DsfrBottomNavigationItem(
        icon: DsfrIcons.buildingsHome4Line,
        activeIcon: DsfrIcons.buildingsHome4Fill,
        label: Strings.menuAccueil,
      ),
      MainTab.monSuivi => DsfrBottomNavigationItem(
        icon: DsfrIcons.businessCalendarLine,
        activeIcon: DsfrIcons.businessCalendarFill,
        label: Strings.menuMonSuivi,
      ),
      MainTab.chat => DsfrBottomNavigationItem(
        icon: DsfrIcons.communicationChat3Line,
        activeIcon: DsfrIcons.communicationChat3Fill,
        label: Strings.menuChat,
        withBadge: viewModel.withChatBadge,
      ),
      MainTab.solutions => DsfrBottomNavigationItem(
        icon: DsfrIcons.businessBriefcaseLine,
        activeIcon: DsfrIcons.businessBriefcaseFill,
        label: Strings.menuSolutions,
      ),
      MainTab.evenements => DsfrBottomNavigationItem(
        icon: DsfrIcons.businessCalendarEventLine,
        activeIcon: DsfrIcons.businessCalendarEventFill,
        label: Strings.menuEvenements,
        tileWrapper: (child) => OnboardingShowcase(
          source: ShowcaseSource.evenement,
          child: child,
        ),
      ),
    };
  }
}
