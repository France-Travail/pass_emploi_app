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
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DsfrSpacings.s2w),
              _SkipButton(active: !_isLastPage(viewModel), viewModel: viewModel),
              const SizedBox(height: DsfrSpacings.s2w),
              Expanded(
                child: PageView(
                  controller: _controller,
                  children: [
                    for (final page in viewModel.pages)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
                        child: _TutorialContentCard(
                          title: page.title,
                          description: page.description,
                          image: page.image,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
                child: SizedBox(
                  width: double.infinity,
                  child: DsfrButton(
                    label: _isLastPage(viewModel) ? Strings.finish : Strings.continueLabel,
                    variant: DsfrButtonVariant.primary,
                    size: DsfrComponentSize.lg,
                    onPressed: () => _onPressed(viewModel),
                  ),
                ),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              _DelayedButton(viewModel: viewModel),
              const SizedBox(height: DsfrSpacings.s2w),
              Semantics(
                label: 'Page ${_currentPage + 1} sur ${viewModel.pages.length}',
                child: _CarouselStepperIndicator(
                  currentPage: _currentPage,
                  pageCount: viewModel.pages.length,
                ),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
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
      PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.continueTutorial);
    } else {
      viewModel.onDone();
      PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.doneTutorial);
    }
  }
}

class _SkipButton extends StatelessWidget {
  final bool active;
  final TutorialPageViewModel viewModel;

  const _SkipButton({
    required this.active,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final button = DsfrButton(
      label: Strings.skip,
      variant: DsfrButtonVariant.tertiaryWithoutBorder,
      size: DsfrComponentSize.md,
      onPressed: active
          ? () {
              viewModel.onDone();
              PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.skipTutorial);
            }
          : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Row(
        children: [
          const Spacer(),
          if (active)
            button
          else
            ExcludeSemantics(
              child: Opacity(
                opacity: 0,
                child: IgnorePointer(child: button),
              ),
            ),
        ],
      ),
    );
  }
}

class _TutorialContentCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const _TutorialContentCard({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_base),
          topRight: Radius.circular(Dimens.radius_s),
        ),
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000012),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Animation(image: image),
                const SizedBox(height: DsfrSpacings.s2w),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                Text(
                  description,
                  style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Animation extends StatefulWidget {
  final String image;

  const _Animation({required this.image});

  @override
  State<_Animation> createState() => _AnimationState();
}

class _AnimationState extends State<_Animation> with SingleTickerProviderStateMixin {
  bool _animating = false;

  late final AnimationController _animationController = AnimationController(
    duration: AnimationDurations.medium,
    reverseDuration: AnimationDurations.medium,
    vsync: this,
  );
  late final Animation<double> _offsetAnimation =
      Tween<double>(
        begin: 0,
        end: 30,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.bounceInOut,
        ),
      );

  Future<void> _playAnimation() async {
    await _animationController.forward(from: 0);
    await _animationController.reverse();
    await _animationController.forward(from: 0);
    await _animationController.reverse();
    await _animationController.forward(from: 0);
    await _animationController.reverse();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_animating) {
      _animating = true;
      _playAnimation();
    }
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, Widget? child) {
        return Transform.scale(
          scale: 1 + _offsetAnimation.value / 150,
          child: Image.asset(widget.image, excludeFromSemantics: true),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.delayedTutorial);
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
          margin: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s1w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isActive ? active : inactive,
          ),
        );
      }),
    );
  }
}
