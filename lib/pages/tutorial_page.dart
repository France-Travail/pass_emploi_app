import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/tutorial_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

class TutorialPage extends StatefulWidget {
  @override
  State<TutorialPage> createState() => _TutorialPageState();

  static MaterialPageRoute<bool> materialPageRoute() {
    return MaterialPageRoute(builder: (_) => TutorialPage());
  }
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _controller = PageController();
  int? _displayedPage;
  int _currentPage = 0;

  @override
  void initState() {
    _controller.addListener(() {
      final controllerPage = _controller.page?.floor();
      if (!mounted) return;
      setState(() {
        _currentPage = controllerPage as int;
      });
      if (controllerPage != null && controllerPage != _displayedPage) {
        _displayedPage = controllerPage;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.tutorialPage,
      child: StoreConnector<AppState, TutorialPageViewModel>(
        builder: (context, viewModel) => _content(viewModel),
        converter: (store) => TutorialPageViewModel.create(store),
        distinct: true,
      ),
    );
  }

  Widget _content(TutorialPageViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final page = viewModel.pages[_currentPage];
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundContrastBlueFrance(
          context,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DsfrSpacings.s3w,
              vertical: DsfrSpacings.s1w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TutorialCard(
                    viewModel: viewModel,
                    pageController: _controller,
                    currentPage: _currentPage,
                    title: page.title,
                    description: page.description,
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s3v),
                DsfrButton(
                  label: _isLastPage(viewModel) ? Strings.finish : Strings.continueLabel,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.lg,
                  onPressed: () => _onPressed(viewModel),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                _DelayedButton(viewModel: viewModel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLastPage(TutorialPageViewModel viewModel) => _currentPage == viewModel.pages.length - 1;

  void _onPressed(TutorialPageViewModel viewModel) {
    final currentPage = _controller.page;
    setState(() {
      if (currentPage != null) _currentPage = _controller.page?.floor() as int;
    });
    if (currentPage != null && currentPage < viewModel.pages.length - 1) {
      _controller.animateToPage(
        currentPage.floor() + 1,
        duration: AnimationDurations.medium,
        curve: Curves.linearToEaseOut,
      );
      PassEmploiMatomoTracker.instance.trackScreen(
        AnalyticsActionNames.continueTutorial,
      );
    } else {
      viewModel.onDone();
      PassEmploiMatomoTracker.instance.trackScreen(
        AnalyticsActionNames.doneTutorial,
      );
    }
  }
}

class _TutorialCard extends StatelessWidget {
  final TutorialPageViewModel viewModel;
  final PageController pageController;
  final int currentPage;
  final String title;
  final String description;

  const _TutorialCard({
    required this.viewModel,
    required this.pageController,
    required this.currentPage,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: BorderRadius.circular(Dimens.radius_s),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                children: [
                  for (final page in viewModel.pages)
                    Center(
                      child: Image.asset(
                        page.image,
                        fit: BoxFit.contain,
                        alignment: Alignment.topCenter,
                        excludeFromSemantics: true,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: DsfrSpacings.s3v),
            Semantics(
              label: 'Page ${currentPage + 1} sur ${viewModel.pages.length}',
              child: _CarouselStepperIndicator(
                currentPage: currentPage,
                pageCount: viewModel.pages.length,
              ),
            ),
            const SizedBox(height: DsfrSpacings.s3v),
            Semantics(
              header: true,
              child: Text(
                title,
                style: DsfrTextStyle.headline3(
                  color: DsfrColorDecisions.textTitleGrey(context),
                ),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s3v),
            Text(
              description,
              style: DsfrTextStyle.bodyMd(
                color: DsfrColorDecisions.textDefaultGrey(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DelayedButton extends StatelessWidget {
  final TutorialPageViewModel viewModel;

  const _DelayedButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DsfrLink(
        label: Strings.seeLater,
        onTap: () {
          viewModel.onDelay();
          PassEmploiMatomoTracker.instance.trackScreen(
            AnalyticsActionNames.delayedTutorial,
          );
        },
      ),
    );
  }
}

class _CarouselStepperIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _CarouselStepperIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final active = DsfrColorDecisions.backgroundActionHighBlueFrance(context);
    final inactive = active.withValues(alpha: 0.4);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: AnimationDurations.fast,
          width: isActive ? 24 : 10,
          height: 10,
          margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isActive ? active : inactive,
          ),
        );
      }),
    );
  }
}
