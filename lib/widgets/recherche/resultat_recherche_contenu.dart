import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/presentation/recherche/bloc_resultat_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';

class ResultatRechercheContenu<Result> extends StatefulWidget {
  final String analyticsType;
  final BlocResultatRechercheViewModel<Result> viewModel;
  final FavoriIdsState<Result> Function(AppState) favorisState;
  final Widget Function(BuildContext, Result, int, BlocResultatRechercheViewModel<Result>) buildResultItem;
  final String Function(int count) resultsCountLabel;

  const ResultatRechercheContenu({
    super.key,
    required this.analyticsType,
    required this.viewModel,
    required this.favorisState,
    required this.buildResultItem,
    required this.resultsCountLabel,
  });

  @override
  State<ResultatRechercheContenu<Result>> createState() => ResultatRechercheContenuState();
}

class ResultatRechercheContenuState<Result> extends State<ResultatRechercheContenu<Result>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FavorisStateContext<Result>(
      selectState: (store) => widget.favorisState(store.state),
      child: AnimationLimiter(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: DsfrSpacings.s3v, bottom: 200),
          controller: _scrollController,
          itemCount: widget.viewModel.items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Semantics(
                header: true,
                child: Text(
                  widget.resultsCountLabel(widget.viewModel.items.length),
                  style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
              );
            }

            final itemIndex = index - 1;
            final isLastItem = itemIndex == widget.viewModel.items.length - 1;
            return AnimationConfiguration.staggeredList(
              position: itemIndex,
              duration: AnimationDurations.fast,
              delay: AnimationDurations.veryFast,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    children: [
                      widget.buildResultItem(
                        context,
                        widget.viewModel.items[itemIndex],
                        itemIndex,
                        widget.viewModel,
                      ),
                      if (widget.viewModel.withLoadMore && isLastItem) ...[
                        const SizedBox(height: DsfrSpacings.s2w),
                        _LoadMoreButton(onPressed: () => _onLoadMorePressed(context)),
                        const SizedBox(height: DsfrSpacings.s8w),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            if (index == 0) return const SizedBox(height: DsfrSpacings.s3v);
            return const SizedBox(height: DsfrSpacings.s2w);
          },
        ),
      ),
    );
  }

  void _onLoadMorePressed(BuildContext context) {
    widget.viewModel.onLoadMore();
    PassEmploiMatomoTracker.instance.trackScreen(
      AnalyticsScreenNames.rechercheAfficherPlusOffres(widget.analyticsType),
    );
  }

  void scrollToTop() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }
}

class _LoadMoreButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _LoadMoreButton({required this.onPressed});

  @override
  State<_LoadMoreButton> createState() => _LoadMoreButtonState();
}

class _LoadMoreButtonState extends State<_LoadMoreButton> {
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: crossFadeState,
      sizeCurve: Curves.ease,
      duration: const Duration(milliseconds: 200),
      firstChild: SizedBox(
        width: double.infinity,
        child: DsfrButton(
          label: Strings.rechercheAfficherPlus,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            widget.onPressed();
            setState(() => crossFadeState = CrossFadeState.showSecond);
          },
        ),
      ),
      secondChild: const Center(
        child: Padding(
          padding: EdgeInsets.all(DsfrSpacings.s2w),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
