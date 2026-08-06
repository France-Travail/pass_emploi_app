import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/first_launch_onboarding/first_launch_onboarding_actions.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/drawables/app_logo.dart';
import 'package:pass_emploi_app/widgets/dsfr/bloc_marque.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';
import 'package:pass_emploi_app/widgets/dsfr/splash_emoji_cluster.dart';

class FirstLaunchOnboardingPage extends StatefulWidget {
  @override
  State<FirstLaunchOnboardingPage> createState() => _FirstLaunchOnboardingPageState();
}

class _FirstLaunchOnboardingPageState extends State<FirstLaunchOnboardingPage> {
  bool _firstScreen = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tracker(
      tracking: AnalyticsScreenNames.onboardingFirstLaunch,
      child: Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: AnimatedSwitcher(
          duration: AnimationDurations.medium,
          child: _firstScreen ? _FirstScreen(onStart: () => setState(() => _firstScreen = false)) : _PageViewScreen(),
        ),
      ),
    );
  }
}

class _FirstScreen extends StatelessWidget {
  final VoidCallback onStart;

  const _FirstScreen({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: BlocMarque(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: Margins.spacing_m),
                      const SplashEmojiCluster(),
                      const SizedBox(height: Margins.spacing_base),
                      const Align(
                        alignment: Alignment.center,
                        child: AppLogo(width: 220),
                      ),
                      const SizedBox(height: Margins.spacing_l),
                      Text(
                        Strings.firstLaunchOnboardingTagline,
                        style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textDefaultGrey(context)),
                      ),
                      const SizedBox(height: Margins.spacing_base),
                      Text(
                        Strings.firstLaunchOnboardingDescription,
                        style: DsfrTextStyle.bodyMd(
                          color: DsfrColorDecisions.textDefaultGrey(context),
                        ).copyWith(height: 24 / 16),
                      ),
                    ],
                  ),
                ),
              ),
              DsfrButton(
                label: Strings.continueLabel,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.lg,
                onPressed: onStart,
              ),
              const SizedBox(height: Margins.spacing_m),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageViewScreen extends StatefulWidget {
  @override
  State<_PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<_PageViewScreen> {
  final _pageController = PageController();
  final page2Key = GlobalKey();
  final page3Key = GlobalKey();
  int _currentPage = 0;
  final Map<int, double> _pageHeights = {};

  double get _pageViewHeight {
    if (_pageHeights.isEmpty) return 0;
    return _pageHeights.values.reduce((a, b) => a > b ? a : b);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageHeightChanged(int index, double height) {
    if (_pageHeights[index] == height) return;
    setState(() => _pageHeights[index] = height);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(width: 120),
                      const SizedBox(height: Margins.spacing_base),
                      SizedBox(
                        height: _pageViewHeight,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (value) {
                            setState(() => _currentPage = value);
                            if (value == 1) {
                              page2Key.requestFocusDelayed(duration: AnimationDurations.verySlow);
                            } else if (value == 2) {
                              page3Key.requestFocusDelayed(duration: AnimationDurations.verySlow);
                            }
                          },
                          children: [
                            _heightAwarePage(
                              index: 0,
                              child: _DiscoveryCard(
                                emoji: '🎯',
                                emojiBackground: DsfrColors.blueCumulus950,
                                title: Strings.firstLaunchOnboardingCardTitle1,
                                onContinue: () => _pageController.next(),
                                autoFocus: true,
                              ),
                            ),
                            _heightAwarePage(
                              index: 1,
                              child: _DiscoveryCard(
                                emoji: '💼',
                                emojiBackground: DsfrColors.greenEmeraude950,
                                title: Strings.firstLaunchOnboardingCardTitle2,
                                onContinue: () => _pageController.next(),
                                autoFocus: false,
                                globalKey: page2Key,
                              ),
                            ),
                            _heightAwarePage(
                              index: 2,
                              child: _DiscoveryCard(
                                emoji: '💬',
                                emojiBackground: DsfrColors.purpleGlycine925,
                                title: Strings.firstLaunchOnboardingCardTitle3,
                                onContinue: () => context.dispatch(FirstLaunchOnboardingFinishAction()),
                                autoFocus: false,
                                globalKey: page3Key,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Margins.spacing_base),
                      _CarouselStepperIndicator(currentPage: _currentPage),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heightAwarePage({required int index, required Widget child}) {
    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: _SizeReportingWidget(
        onSizeChange: (size) => _onPageHeightChanged(index, size.height),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_xl),
          child: child,
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.emoji,
    required this.emojiBackground,
    required this.title,
    required this.onContinue,
    required this.autoFocus,
    this.globalKey,
  });

  final String emoji;
  final Color emojiBackground;
  final String title;
  final VoidCallback onContinue;
  final bool autoFocus;
  final GlobalKey? globalKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimens.radius_base),
          topRight: Radius.circular(Dimens.radius_s),
        ),
        border: Border(
          top: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context)),
          left: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context)),
          right: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000012),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Margins.spacing_base),
          Center(
            child: EmojiTile(
              emoji: emoji,
              backgroundColor: emojiBackground,
              size: 96,
              emojiSize: 46,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Margins.spacing_m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Builder(
                  builder: (context) {
                    final text = Text(
                      key: globalKey,
                      title,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textDefaultGrey(context)),
                    );
                    if (autoFocus) return AutoFocusA11y(child: text);
                    return text;
                  },
                ),
                const SizedBox(height: Margins.spacing_s),
                DsfrButton(
                  label: Strings.continueLabel,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.lg,
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
          Container(
            height: 4,
            color: DsfrColorDecisions.borderActionHighBlueFrance(context),
          ),
        ],
      ),
    );
  }
}

class _SizeReportingWidget extends StatefulWidget {
  const _SizeReportingWidget({required this.child, required this.onSizeChange});

  final Widget child;
  final ValueChanged<Size> onSizeChange;

  @override
  State<_SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<_SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) return;
    final size = context.size;
    if (size != null && size != _oldSize) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}

class _CarouselStepperIndicator extends StatelessWidget {
  final int currentPage;

  const _CarouselStepperIndicator({required this.currentPage});

  static const _length = 3;

  @override
  Widget build(BuildContext context) {
    final active = DsfrColorDecisions.backgroundActionHighBlueFrance(context);
    final inactive = active.withValues(alpha: 0.4);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: AnimationDurations.fast,
          width: isActive ? 24 : 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: Margins.spacing_xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isActive ? active : inactive,
          ),
        );
      }),
    );
  }
}

extension on PageController {
  Future<void> next() => nextPage(duration: AnimationDurations.medium, curve: Curves.fastEaseInToSlowEaseOut);
}
