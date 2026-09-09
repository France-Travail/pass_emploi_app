import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pass_emploi_app/features/thematiques_demarche/thematiques_demarche_actions.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/demarche/thematiques_demarche_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_solution_tile.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class CreateDemarcheStep1Page extends StatelessWidget {
  const CreateDemarcheStep1Page(this.formViewModel, {super.key});
  final CreateDemarcheFormChangeNotifier formViewModel;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ThematiqueDemarchePageViewModel>(
      onInit: (store) => store.dispatch(ThematiqueDemarcheRequestAction()),
      converter: (store) => ThematiqueDemarchePageViewModel.create(store),
      builder: (context, thematiqueViewModel) =>
          _Content(thematiqueViewModel: thematiqueViewModel, formViewModel: formViewModel),
      distinct: true,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.thematiqueViewModel, required this.formViewModel});
  final ThematiqueDemarchePageViewModel thematiqueViewModel;
  final CreateDemarcheFormChangeNotifier formViewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      child: AnimatedSwitcher(
        duration: AnimationDurations.fast,
        child: switch (thematiqueViewModel.displayState) {
          DisplayState.FAILURE => _ErrorMessage(
            thematiqueViewModel,
            onCreateCustomDemarche: _onCreateCustomDemarcheSelected,
          ),
          DisplayState.CONTENT => _Success(
            thematiqueViewModel,
            formViewModel,
            onCreateCustomDemarche: _onCreateCustomDemarcheSelected,
          ),
          _ => const _LoadingPlaceholder(),
        },
      ),
    );
  }

  void _onCreateCustomDemarcheSelected() {
    formViewModel.navigateToCreateCustomDemarche();
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: EmojiSolutionGrid(
        tiles: List.generate(
          7,
          (index) => AnimationConfiguration.staggeredList(
            position: index,
            duration: AnimationDurations.fast,
            delay: AnimationDurations.veryFast,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: DsfrColorDecisions.backgroundContrastGrey(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: const SizedBox(height: 157),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage(this.viewModel, {required this.onCreateCustomDemarche});
  final ThematiqueDemarchePageViewModel viewModel;
  final void Function() onCreateCustomDemarche;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Retry(Strings.thematiquesErrorSubtitle, viewModel.onRetry),
        const SizedBox(height: DsfrSpacings.s4w),
        _CreateCustomDemarche(onCreateCustomDemarche),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success(this.thematiqueViewModel, this.formViewModel, {required this.onCreateCustomDemarche});
  final ThematiqueDemarchePageViewModel thematiqueViewModel;
  final void Function() onCreateCustomDemarche;
  final CreateDemarcheFormChangeNotifier formViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: DsfrSpacings.s2w),
        EmojiSolutionGrid(
          tiles: thematiqueViewModel.thematiques
              .map(
                (thematique) => EmojiSolutionTile(
                  onTap: () => formViewModel.thematiqueSelected(thematique),
                  emoji: thematique.emoji,
                  emojiBackground: thematique.emojiBackground,
                  title: thematique.title,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: DsfrSpacings.s3v),
        _CreateCustomDemarche(onCreateCustomDemarche),
        const SizedBox(height: DsfrSpacings.s5w),
      ],
    );
  }
}

class _CreateCustomDemarche extends StatelessWidget {
  final void Function() onCreateCustomDemarche;

  const _CreateCustomDemarche(this.onCreateCustomDemarche);

  @override
  Widget build(BuildContext context) {
    return EmojiSolutionTile(
      onTap: onCreateCustomDemarche,
      emoji: '🤔',
      emojiBackground: DsfrColors.purpleGlycine925,
      title: Strings.customDemarcheTitle,
      subtitle: Strings.customDemarcheSubtitle,
      textAlign: TextAlign.start,
    );
  }
}
