import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_actions.dart';
import 'package:pass_emploi_app/network/post_evenement_engagement.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche_form_page.dart';
import 'package:pass_emploi_app/pages/demarche/demarche_detail_bottom_sheet.dart';
import 'package:pass_emploi_app/pages/demarche/demarche_detail_page.dart';
import 'package:pass_emploi_app/pages/rendezvous/rendezvous_details_page.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_page.dart';
import 'package:pass_emploi_app/pages/user_action/user_action_detail_bottom_sheet.dart';
import 'package:pass_emploi_app/pages/user_action/user_action_detail_page.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/mon_suivi/mon_suivi_view_model.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_card_view_model.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/animated_list_loader.dart';
import 'package:pass_emploi_app/widgets/cards/demarche_card.dart';
import 'package:pass_emploi_app/widgets/cards/rendezvous_card.dart';
import 'package:pass_emploi_app/widgets/cards/user_action_card.dart';
import 'package:pass_emploi_app/widgets/comptage_des_heures_card.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/onboarding/ft_ia_showcase.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:shimmer/shimmer.dart';

class MonSuiviPage extends StatefulWidget {
  @override
  State<MonSuiviPage> createState() => _MonSuiviPageState();
}

class _MonSuiviPageState extends State<MonSuiviPage> {
  @override
  Widget build(BuildContext context) {
    return AutoFocusA11y(
      child: Tracker(
        tracking: AnalyticsScreenNames.monSuivi,
        child: _StateProvider(
          child: StoreConnector<AppState, MonSuiviViewModel>(
            onInit: (store) =>
                store.dispatch(MonSuiviRequestAction(MonSuiviPeriod.current)),
            converter: (store) => MonSuiviViewModel.create(store),
            builder: (_, viewModel) => _Scaffold(
              body: _Body(viewModel),
              withCreateButton: viewModel.withCreateButton,
              ctaType: viewModel.ctaType,
            ),
            onDispose: (store) => store.dispatch(MonSuiviResetAction()),
            distinct: true,
          ),
        ),
      ),
    );
  }
}

//ignore: must_be_immutable
class _StateProvider extends InheritedWidget {
  final GlobalKey centerKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  int previousPeriodCount = 0;
  int nextPeriodCount = 0;

  _StateProvider({required super.child});

  static _StateProvider? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StateProvider>();

  @override
  bool updateShouldNotify(_StateProvider old) => false;
}

class _Scaffold extends StatelessWidget {
  final Widget body;
  final bool withCreateButton;
  final MonSuiviCtaType ctaType;

  const _Scaffold({
    required this.body,
    required this.withCreateButton,
    required this.ctaType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: _ScrollAwareAppBar(),
      body: ConnectivityContainer(child: body),
      floatingActionButton: Visibility(
        visible: withCreateButton,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width - (DsfrSpacings.s2w * 2),
          child: CreateDemarcheButton(ctaType: ctaType),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _ScrollAwareAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<_ScrollAwareAppBar> createState() => _ScrollAwareAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(PrimaryAppBar.toolBarHeight);
}

class _ScrollAwareAppBarState extends State<_ScrollAwareAppBar> {
  bool withActionButton = false;

  @override
  void didChangeDependencies() {
    _StateProvider.maybeOf(
      context,
    )?.scrollController.addListener(_scrollListener);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool isScreenReader = A11yUtils.withScreenReader(context);
    return PrimaryAppBar(
      title: Strings.agendaTitle,
      actionButton: withActionButton || isScreenReader
          ? IconButton(
              onPressed: () =>
                  _StateProvider.maybeOf(context)?.scrollController.animateTo(
                    0,
                    duration: AnimationDurations.fast,
                    curve: Curves.fastEaseInToSlowEaseOut,
                  ),
              icon: Padding(
                padding: const EdgeInsets.all(DsfrSpacings.s1w),
                child: Icon(
                  DsfrIcons.businessCalendarEventLine,
                  color: DsfrColorDecisions.textActionHighBlueFrance(context),
                  size: DsfrSpacings.s3w,
                ),
              ),
              tooltip: Strings.monSuiviTooltip,
            )
          : null,
    );
  }

  void _scrollListener() {
    if (_StateProvider.maybeOf(context)?.scrollController.offset != 0) {
      if (!withActionButton) setState(() => withActionButton = true);
    } else {
      if (withActionButton) setState(() => withActionButton = false);
    }
  }
}

class _Body extends StatelessWidget {
  final MonSuiviViewModel viewModel;

  const _Body(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AnimationDurations.fast,
      child: switch (viewModel.displayState) {
        DisplayState.FAILURE => Retry(
          Strings.monSuiviError,
          () => viewModel.onRetry(),
        ),
        DisplayState.CONTENT => _Content(viewModel),
        _ => _MonSuiviLoader(),
      },
    );
  }
}

class _Content extends StatelessWidget {
  final MonSuiviViewModel viewModel;

  const _Content(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (viewModel.withWarningOnWrongPoleEmploiDataRetrieval) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          _WarningCard(
            label: Strings.monSuiviPoleEmploiDataError,
            onPressed: () => viewModel.onRetry(),
          ),
        ],
        if (viewModel.monSuiviDemarchesKoMessage != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: DsfrAlert(
              type: DsfrAlertType.info,
              description: DsfrAlertDescriptionText(
                viewModel.monSuiviDemarchesKoMessage!,
              ),
            ),
          ),
        ],
        if (viewModel.withWarningOnWrongSessionMiloRetrieval) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          _WarningCard(
            label: Strings.monSuiviSessionMiloError,
            onPressed: () => viewModel.onRetry(),
          ),
        ],
        if (viewModel.pendingActionCreations > 0) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          _UserActionsPendingCard(viewModel.pendingActionCreations),
        ],
        if (viewModel.withComptageDesHeures) const _ScrollAwareComptageDesHeures(),
        Expanded(child: _TodayCenteredMonSuiviList(viewModel)),
      ],
    );
  }
}

class _ScrollAwareComptageDesHeures extends StatefulWidget {
  const _ScrollAwareComptageDesHeures();

  @override
  State<_ScrollAwareComptageDesHeures> createState() => _ScrollAwareComptageDesHeuresState();
}

class _ScrollAwareComptageDesHeuresState extends State<_ScrollAwareComptageDesHeures> {
  bool _visible = true;
  ScrollController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = _StateProvider.maybeOf(context)?.scrollController;
    if (_controller == controller) return;
    _controller?.removeListener(_onScroll);
    _controller = controller;
    _controller?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = (_controller?.offset ?? 0) == 0;
    if (shouldShow != _visible) setState(() => _visible = shouldShow);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible || A11yUtils.withScreenReader(context);
    return ClipRect(
      child: AnimatedAlign(
        duration: AnimationDurations.fast,
        curve: Curves.fastEaseInToSlowEaseOut,
        alignment: Alignment.topCenter,
        heightFactor: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: ExcludeSemantics(
            excluding: !visible,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s1w, DsfrSpacings.s2w, 0),
              child: ComptageDesHeuresCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningCard extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _WarningCard({required this.label, required this.onPressed});

  @override
  State<_WarningCard> createState() => _WarningCardState();
}

class _WarningCardState extends State<_WarningCard> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: AnimationDurations.fast,
      firstChild: const SizedBox.shrink(),
      crossFadeState: _visible
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      secondChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: DsfrAlert(
          type: DsfrAlertType.warning,
          description: DsfrAlertDescriptionWidget(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  focusable: true,
                  child: Text(
                    widget.label,
                    style: DsfrTextStyle.bodyMd(
                      color: DsfrColorDecisions.textDefaultGrey(context),
                    ),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                Align(
                  alignment: Alignment.centerRight,
                  child: DsfrButton(
                    label: Strings.retry,
                    variant: DsfrButtonVariant.secondary,
                    size: DsfrComponentSize.sm,
                    onPressed: widget.onPressed,
                  ),
                ),
              ],
            ),
          ),
          onClose: () => setState(() => _visible = false),
          semanticCloseLabel: Strings.closeDialog,
        ),
      ),
    );
  }
}

class _UserActionsPendingCard extends StatelessWidget {
  final int userActionsPostponedCount;

  const _UserActionsPendingCard(this.userActionsPostponedCount);

  @override
  Widget build(BuildContext context) {
    final message = userActionsPostponedCount > 1
        ? Strings.pendingActionCreationPlural(userActionsPostponedCount)
        : Strings.pendingActionCreationSingular;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: DsfrAlert(
        type: DsfrAlertType.info,
        description: DsfrAlertDescriptionText(message),
      ),
    );
  }
}

class _TodayCenteredMonSuiviList extends StatelessWidget {
  final MonSuiviViewModel viewModel;
  final List<MonSuiviItem> pastItems;
  final List<MonSuiviItem> presentAndFutureItems;

  _TodayCenteredMonSuiviList(this.viewModel)
    : pastItems = viewModel.items
          .sublist(0, viewModel.indexOfTodayItem)
          .reversed
          .toList(),
      presentAndFutureItems = viewModel.items.sublist(
        viewModel.indexOfTodayItem,
      );

  @override
  Widget build(BuildContext context) {
    bool loadingPreviousPeriod = false;
    bool loadingNextPeriod = false;

    return Padding(
      padding: EdgeInsets.only(
        left: DsfrSpacings.s2w,
        right: DsfrSpacings.s2w,
        bottom: A11yUtils.withScreenReader(context) ? DsfrSpacings.s15w : 0,
      ),
      child: CustomScrollView(
        center: _StateProvider.maybeOf(context)?.centerKey,
        controller: _StateProvider.maybeOf(context)?.scrollController,
        slivers: [
          SliverList.separated(
            separatorBuilder: (context, index) =>
                const SizedBox(height: DsfrSpacings.s3v),
            itemCount: pastItems.length + 1,
            itemBuilder: (context, index) {
              if (_shouldAutomaticallyLoadPreviousPeriod(
                context,
                index,
                loadingPreviousPeriod,
              )) {
                loadingPreviousPeriod = true;
                _loadPreviousPeriod(context);
              }
              if (index == pastItems.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
                  child: viewModel.withPagination
                      ? _Pagination(
                          label: Strings.monSuiviA11yPreviousPeriodButton,
                          onPressed: () {
                            loadingPreviousPeriod = true;
                            _loadPreviousPeriod(context);
                          },
                        )
                      : _LimitReachedBanner(Strings.monSuiviPePastLimitReached),
                );
              }
              return pastItems[index].toWidget();
            },
          ),
          SliverList.separated(
            key: _StateProvider.maybeOf(context)?.centerKey,
            separatorBuilder: (context, index) =>
                const SizedBox(height: DsfrSpacings.s3v),
            itemCount: presentAndFutureItems.length + 1,
            itemBuilder: (context, index) {
              if (_shouldAutomaticallyLoadNextPeriod(
                context,
                index,
                loadingNextPeriod,
              )) {
                loadingNextPeriod = true;
                _loadNextPeriod(context);
              }
              if (index == presentAndFutureItems.length) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: viewModel.withPagination
                        ? DsfrSpacings.s2w
                        : DsfrSpacings.s8w,
                  ),
                  child: viewModel.withPagination
                      ? _Pagination(
                          label: Strings.monSuiviA11yNextPeriodButton,
                          onPressed: () {
                            loadingNextPeriod = true;
                            _loadNextPeriod(context);
                          },
                        )
                      : _LimitReachedBanner(
                          Strings.monSuiviPeFutureLimitReached,
                        ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? DsfrSpacings.s2w : 0,
                ),
                child: index == 0
                    // A11y - 10.2: required to focus on today item when app bar button is clicked
                    ? AutoFocusA11y(child: presentAndFutureItems[0].toWidget())
                    : presentAndFutureItems[index].toWidget(),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _shouldAutomaticallyLoadNextPeriod(
    BuildContext context,
    int index,
    bool loadingNextPeriod,
  ) {
    if (A11yUtils.withScreenReader(context)) return false;
    return viewModel.withPagination &&
        index > presentAndFutureItems.length - 2 &&
        !loadingNextPeriod;
  }

  bool _shouldAutomaticallyLoadPreviousPeriod(
    BuildContext context,
    int index,
    bool loadingPreviousPeriod,
  ) {
    if (A11yUtils.withScreenReader(context)) return false;
    return viewModel.withPagination &&
        index > pastItems.length - 2 &&
        !loadingPreviousPeriod;
  }

  void _loadNextPeriod(BuildContext context) {
    viewModel.onLoadNextPeriod();
    _StateProvider.maybeOf(context)?.nextPeriodCount++;
  }

  void _loadPreviousPeriod(BuildContext context) {
    viewModel.onLoadPreviousPeriod();
    _StateProvider.maybeOf(context)?.previousPeriodCount--;
  }
}

class _SemaineSectionItem extends StatelessWidget {
  final String interval;
  final String? boldTitle;

  const _SemaineSectionItem(this.interval, this.boldTitle);

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s1w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                boldTitle ?? interval,
                style: DsfrTextStyle.headline6(
                  color: DsfrColorDecisions.textTitleGrey(context),
                ),
              ),
              if (boldTitle != null) ...[
                const SizedBox(height: DsfrSpacings.s1v),
                Text(
                  interval,
                  style: DsfrTextStyle.bodyXs(
                    color: DsfrColorDecisions.textMentionGrey(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledDayItem extends StatelessWidget {
  final MonSuiviDay day;
  final List<MonSuiviEntry> entries;

  const _FilledDayItem(this.day, this.entries);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: DsfrSpacings.s3v),
          _AgendaTile(
            dashed: false,
            onTap: () => entries[i].onTap(context),
            onLongPress: entries[i].onLongPress(context),
            child: _DayRow(
              day: day,
              child: entries[i].toWidget(),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyDayItem extends StatefulWidget {
  final MonSuiviDay day;
  final String text;

  const _EmptyDayItem(this.day, this.text);

  @override
  State<_EmptyDayItem> createState() => _EmptyDayItemState();
}

class _EmptyDayItemState extends State<_EmptyDayItem> {
  late Color _textColor;
  late Color _borderColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textColor = DsfrColorDecisions.textDefaultGrey(context);
    _borderColor = DsfrColorDecisions.borderDefaultGrey(context);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() {
          _textColor = focused
              ? DsfrColorDecisions.textActionHighBlueFrance(context)
              : DsfrColorDecisions.textDefaultGrey(context);
          _borderColor = focused
              ? DsfrColorDecisions.borderPlainBlueFrance(context)
              : DsfrColorDecisions.borderDefaultGrey(context);
        });
      },
      child: _AgendaTile(
        dashed: true,
        borderColor: _borderColor,
        backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
        child: _DayRow(
          day: widget.day,
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Text(
            widget.text,
            style: DsfrTextStyle.bodySm(color: _textColor),
          ),
        ),
      ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  final Widget child;
  final bool dashed;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AgendaTile({
    required this.child,
    required this.dashed,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
  });

  static const _radius = Radius.circular(4);

  @override
  Widget build(BuildContext context) {
    final resolvedBorder =
        borderColor ?? DsfrColorDecisions.borderDefaultGrey(context);
    final resolvedBackground =
        backgroundColor ?? DsfrColorDecisions.backgroundDefaultGrey(context);
    final borderRadius = const BorderRadius.all(_radius);
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(color: resolvedBorder),
    );

    final paddedChild = Padding(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      child: child,
    );

    final interactiveChild = (onTap == null && onLongPress == null)
        ? paddedChild
        : InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            customBorder: shape,
            child: paddedChild,
          );

    if (dashed) {
      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [4, 4],
          radius: _radius,
          color: resolvedBorder,
          strokeWidth: 1,
          padding: EdgeInsets.symmetric(horizontal: 1),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: ColoredBox(
            color: resolvedBackground,
            child: interactiveChild,
          ),
        ),
      );
    }

    return Material(
      color: resolvedBackground,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: interactiveChild,
    );
  }
}

class _DayRow extends StatelessWidget {
  final MonSuiviDay day;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  const _DayRow({
    required this.day,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        _Day(day),
        const SizedBox(width: DsfrSpacings.s2w),
        Expanded(child: child),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  final MonSuiviDay day;

  const _Day(this.day);

  @override
  Widget build(BuildContext context) {
    final textColor = DsfrColorDecisions.textTitleGrey(context);

    return SizedBox(
      width: DsfrSpacings.s8w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              day.name,
              style: DsfrTextStyle.bodyXs(color: textColor),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          Text(
            day.number,
            style: DsfrTextStyle.bodyLgBold(color: textColor),
            textAlign: TextAlign.center,
          ),
          Text(
            day.month,
            style: DsfrTextStyle.bodyXs(color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _UserActionMonSuiviItem extends StatelessWidget {
  final UserActionMonSuiviEntry entry;

  const _UserActionMonSuiviItem(this.entry);

  @override
  Widget build(BuildContext context) {
    return UserActionCard(
      userActionId: entry.id,
      source: UserActionStateSource.monSuivi,
    );
  }
}

class _DemarcheMonSuiviItem extends StatelessWidget {
  final DemarcheMonSuiviEntry entry;

  const _DemarcheMonSuiviItem(this.entry);

  @override
  Widget build(BuildContext context) {
    return DemarcheCard(demarcheId: entry.id);
  }
}

class _RendezvousMonSuiviItem extends StatelessWidget {
  final RendezvousMonSuiviEntry entry;

  const _RendezvousMonSuiviItem(this.entry);

  @override
  Widget build(BuildContext context) {
    return RendezvousCard(
      converter: (store) => RendezvousCardViewModel.create(
        store,
        RendezvousStateSource.monSuivi,
        entry.id,
      ),
      withChrome: false,
    );
  }
}

class _SessionMiloMonSuiviItem extends StatelessWidget {
  final SessionMiloMonSuiviEntry entry;

  const _SessionMiloMonSuiviItem(this.entry);

  @override
  Widget build(BuildContext context) {
    return RendezvousCard(
      converter: (store) => RendezvousCardViewModel.create(
        store,
        RendezvousStateSource.monSuiviSessionMilo,
        entry.id,
      ),
      withChrome: false,
    );
  }
}

class _MonSuiviLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedListLoader(
      placeholders: [
        ..._dayItems(screenWidth, (7 - DateTime.now().weekday) + 1),
        ..._semaineSection(screenWidth),
        ..._dayItems(screenWidth, 7),
        ..._semaineSection(screenWidth),
      ],
    );
  }

  List<Widget> _dayItems(double screenWidth, int count) {
    return [
      for (var i = 0; i < count; ++i)
        Padding(
          padding: const EdgeInsets.only(top: DsfrSpacings.s3v),
          child: _MonSuiviItemLoader(screenWidth: screenWidth),
        ),
    ];
  }

  List<Widget> _semaineSection(double screenWidth) {
    return [
      const SizedBox(height: DsfrSpacings.s3w),
      AnimatedListLoader.placeholderBuilder(
        width: screenWidth * 0.5,
        height: 24,
      ),
      const SizedBox(height: DsfrSpacings.s1w),
      AnimatedListLoader.placeholderBuilder(
        width: screenWidth * 0.3,
        height: 16,
      ),
      const SizedBox(height: DsfrSpacings.s1w),
    ];
  }
}

class _Pagination extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _Pagination({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return A11yUtils.withScreenReader(context)
        ? _LoadPeriodButton(label: label, onPressed: onPressed)
        : _PaginationLoader();
  }
}

class _PaginationLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DsfrColorDecisions.backgroundContrastGrey(context),
      highlightColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      child: _MonSuiviItemLoader(
        screenWidth: MediaQuery.of(context).size.width,
      ),
    );
  }
}

class _LoadPeriodButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _LoadPeriodButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DsfrButton(
        label: label,
        variant: DsfrButtonVariant.secondary,
        size: DsfrComponentSize.md,
        onPressed: onPressed,
      ),
    );
  }
}

class _LimitReachedBanner extends StatelessWidget {
  final String text;

  const _LimitReachedBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DsfrTextStyle.bodyXsMedium(
        color: DsfrColorDecisions.textMentionGrey(context),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _MonSuiviItemLoader extends StatelessWidget {
  final double screenWidth;

  const _MonSuiviItemLoader({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return AnimatedListLoader.placeholderBuilder(
      width: screenWidth,
      height: 80,
    );
  }
}

extension on MonSuiviItem {
  Widget toWidget() {
    return switch (this) {
      final SemaineSectionMonSuiviItem item => _SemaineSectionItem(
        item.interval,
        item.boldTitle,
      ),
      final EmptyDayMonSuiviItem item => _EmptyDayItem(item.day, item.text),
      final FilledDayMonSuiviItem item => _FilledDayItem(
        item.day,
        item.entries,
      ),
    };
  }
}

extension on MonSuiviEntry {
  Widget toWidget() {
    return switch (this) {
      final UserActionMonSuiviEntry entry => _UserActionMonSuiviItem(entry),
      final DemarcheMonSuiviEntry entry => _DemarcheMonSuiviItem(entry),
      final RendezvousMonSuiviEntry entry => _RendezvousMonSuiviItem(entry),
      final SessionMiloMonSuiviEntry entry => _SessionMiloMonSuiviItem(entry),
    };
  }

  void onTap(BuildContext context) {
    switch (this) {
      case UserActionMonSuiviEntry(:final id):
        context.trackEvenementEngagement(EvenementEngagement.ACTION_DETAIL);
        UserActionDetailPage.show(context, id, UserActionStateSource.monSuivi);
      case DemarcheMonSuiviEntry(:final id):
        context.trackEvenementEngagement(EvenementEngagement.ACTION_DETAIL);
        DemarcheDetailPage.show(context, id);
      case RendezvousMonSuiviEntry(:final id):
        context.trackEvenementEngagement(EvenementEngagement.RDV_DETAIL);
        RendezvousDetailsPage.show(context, RendezvousStateSource.monSuivi, id);
      case SessionMiloMonSuiviEntry(:final id):
        context.trackEvenementEngagement(
          EvenementEngagement.RDV_DETAIL_SESSION,
        );
        RendezvousDetailsPage.show(
          context,
          RendezvousStateSource.sessionMiloDetails,
          id,
        );
    }
  }

  VoidCallback? onLongPress(BuildContext context) {
    return switch (this) {
      UserActionMonSuiviEntry(:final id) =>
        () => UserActionDetailsBottomSheet.show(
          context,
          UserActionStateSource.monSuivi,
          id,
        ),
      DemarcheMonSuiviEntry(:final id) => () => DemarcheDetailsBottomSheet.show(
        context,
        id,
      ),
      _ => null,
    };
  }
}

class CreateDemarcheButton extends StatefulWidget {
  const CreateDemarcheButton({super.key, required this.ctaType});
  final MonSuiviCtaType ctaType;

  @override
  State<CreateDemarcheButton> createState() => _CreateDemarcheButtonState();
}

class _CreateDemarcheButtonState extends State<CreateDemarcheButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  int _pulseCount = 0;
  bool _shouldAnimate = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _shouldAnimate) {
        _pulseCount++;
        if (_pulseCount < 3) {
          _controller.forward(from: 0);
        } else {
          _shouldAnimate = false;
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final label = widget.ctaType == MonSuiviCtaType.createAction
            ? Strings.addAnAction
            : Strings.addADemarche;
        final button = DsfrButton(
          label: label,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            switch (widget.ctaType) {
              case MonSuiviCtaType.createDemarche:
                Navigator.push(context, CreateDemarcheFormPage.route());
                break;
              case MonSuiviCtaType.createAction:
                CreateUserActionFormPage.pushUserActionCreationTunnel(
                  StoreProvider.of<AppState>(context),
                  Navigator.of(context),
                  UserActionStateSource.monSuivi,
                );
                break;
            }
          },
        );
        return SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: DsfrColorDecisions.backgroundActionHighBlueFrance(
                        context,
                      ).withValues(alpha: 0.5),
                    ),
                    child: IgnorePointer(
                      child: SizedBox(width: double.infinity, child: button),
                    ),
                  ),
                ),
              ),
              OnboardingShowcase(
                source: ShowcaseSource.action,
                child: FtIaShowcase(
                  child: SizedBox(width: double.infinity, child: button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
