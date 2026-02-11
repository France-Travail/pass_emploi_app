import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/presentation/actualite_mission_locale/actualite_mission_locale_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/chat/chat_day_section.dart';
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
      padding: const EdgeInsets.only(
        left: Margins.spacing_base,
        right: Margins.spacing_xl,
        top: Margins.spacing_base,
        bottom: Margins.spacing_l,
      ),
      itemCount: viewModel.actualites.length,
      reverse: true,
      separatorBuilder: (_, __) => const SizedBox(height: Margins.spacing_base),
      itemBuilder: (context, index) => switch (viewModel.actualites[index]) {
        final ActualiteMissionLocaleItemSupprimeViewModel actualite => _ActualiteItemSupprime(actualite),
        final ActualiteMissionLocaleItemViewModel actualite => _ActualiteItem(actualite),
      },
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyStatePlaceholder(
        illustration: Container(
          padding: EdgeInsets.all(Margins.spacing_m),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(Drawables.megaphone),
        ),
        title: Strings.actualiteMissionLocaleEmptyTitle,
        subtitle: Strings.actualiteMissionLocaleEmptySubtitle,
      ),
    );
  }
}

class _ActualiteItem extends StatelessWidget {
  const _ActualiteItem(this.actualite);

  final ActualiteMissionLocaleItemViewModel actualite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChatDaySection(dayLabel: actualite.dateCreation),
        SizedBox(height: Margins.spacing_s),
        CardContainer(
          onTap: () => _onPressed(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(actualite.titre, style: TextStyles.textBaseBold.copyWith(color: AppColors.primaryDarken)),
              SizedBox(height: Margins.spacing_s),
              Text(actualite.corps, style: TextStyles.textSRegular().copyWith(color: AppColors.primaryDarken)),
              if (actualite.titreLien != null && actualite.lien != null) ...[
                SizedBox(height: Margins.spacing_s),
                _CustomPressedTip(tip: actualite.titreLien!),
              ],
            ],
          ),
        ),
        SizedBox(height: Margins.spacing_s),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(actualite.heureEtNomConseiller, style: TextStyles.textXsMedium()),
        ),
      ],
    );
  }

  void _onPressed(BuildContext context) {
    if (actualite.lien == null || actualite.titreLien == null) return;
    _ExternalUrlAlertDialog.show(context, actualite.lien!);
  }
}

class _CustomPressedTip extends StatelessWidget {
  const _CustomPressedTip({required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.primaryDarken;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(AppIcons.open_in_new_rounded, color: textColor, size: Dimens.icon_size_base),
        SizedBox(width: Margins.spacing_s),
        Flexible(
          child: Text(
            tip,
            style: TextStyles.textBaseRegular.copyWith(
              color: textColor,
              decoration: TextDecoration.underline,
              decorationColor: textColor,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Semantics(label: Strings.link),
      ],
    );
  }
}

class _ExternalUrlAlertDialog extends StatelessWidget {
  const _ExternalUrlAlertDialog({required this.url});
  final String url;

  static void show(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => _ExternalUrlAlertDialog(url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: Margins.spacing_m),
              SizedBox.square(dimension: 120, child: Illustration.blue(AppIcons.open_in_new_rounded)),
              SizedBox(height: Margins.spacing_m),
              Text(Strings.externalUrlAlertTitle, style: TextStyles.textBaseBold, textAlign: TextAlign.center),
              SizedBox(height: Margins.spacing_m),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.primaryDarken),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(label: Strings.cancelLabel, onPressed: () => Navigator.pop(context, false)),
            ),
            SizedBox(width: Margins.spacing_s),
            Expanded(
              child: PrimaryActionButton(
                label: Strings.confirmLabel,
                onPressed: () {
                  Navigator.pop(context);
                  launchExternalUrl(url);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActualiteItemSupprime extends StatelessWidget {
  const _ActualiteItemSupprime(this.actualite);
  final ActualiteMissionLocaleItemSupprimeViewModel actualite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChatDaySection(dayLabel: actualite.dateCreation),
        SizedBox(height: Margins.spacing_s),
        Container(
          margin: EdgeInsets.symmetric(vertical: Margins.spacing_base),
          padding: EdgeInsets.symmetric(vertical: Margins.spacing_base, horizontal: Margins.spacing_base),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey500),
            borderRadius: BorderRadius.circular(Dimens.radius_base),
          ),
          child: Text(
            Strings.actualiteMissionLocaleSupprime,
            style: TextStyles.textSRegular(color: AppColors.grey800),
          ),
        ),
      ],
    );
  }
}
