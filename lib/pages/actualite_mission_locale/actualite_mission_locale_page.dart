import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/presentation/actualite_mission_locale/actualite_mission_locale_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/buttons/lien_button.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/base_card.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_complement.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/illustration/empty_state_placeholder.dart';
import 'package:pass_emploi_app/widgets/illustration/illustration.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class ActualiteMissionLocalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.actualiteMissionLocale,
      child: Container(
        color: AppColors.grey100,
        child: ConnectivityContainer(
          child: StoreConnector<AppState, ActualiteMissionLocaleViewModel>(
            onInit: (store) {
              store.dispatch(ActualiteMissionLocaleRequestAction());
              store.dispatch(DateConsultationActualiteMissionLocaleRequestAction());
            },
            onDispose: (store) {
              store.dispatch(DateConsultationActualiteMissionLocaleWriteAction(DateTime.now()));
            },
            converter: (store) => ActualiteMissionLocaleViewModel.create(store),
            builder: (context, viewModel) => _DisplayState(viewModel: viewModel),
            distinct: true,
          ),
        ),
      ),
    );
  }
}

class _DisplayState extends StatelessWidget {
  const _DisplayState({required this.viewModel});

  final ActualiteMissionLocaleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _Body(viewModel: viewModel),
      DisplayState.LOADING => const Center(child: CircularProgressIndicator()),
      DisplayState.FAILURE => Retry(Strings.actualiteMissionLocaleError, () => viewModel.onRetry()),
      DisplayState.EMPTY => _Empty(),
    };
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.viewModel});

  final ActualiteMissionLocaleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Margins.spacing_base),
      itemCount: viewModel.actualites.length,
      separatorBuilder: (_, __) => const SizedBox(height: Margins.spacing_base),
      itemBuilder: (context, index) => _ActualiteCard(viewModel.actualites[index]),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmptyStatePlaceholder(
      illustration: Illustration.grey(AppIcons.chat_outlined),
      title: Strings.actualiteMissionLocaleEmptyTitle,
      subtitle: Strings.actualiteMissionLocaleEmptySubtitle,
    );
  }
}

class _ActualiteCard extends StatelessWidget {
  const _ActualiteCard(this.actualite);

  final ActualiteMissionLocaleItemViewModel actualite;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: actualite.titre,
      subtitle: actualite.corps,
      complements: [
        CardComplement.person(text: actualite.nomConseiller),
        CardComplement.date(text: actualite.dateCreation),
      ],
      actions: _actions(),
    );
  }

  List<Widget>? _actions() {
    if (actualite.lien.isEmpty || actualite.titreDuLien.isEmpty) return null;
    return [
      LienButton(
        label: actualite.titreDuLien,
        onPressed: () => launchExternalUrl(actualite.lien),
      ),
    ];
  }
}
