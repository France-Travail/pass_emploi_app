import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/demarche/update/update_demarche_actions.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_done_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/date_pickers/date_picker_suggestions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class DemarcheDoneBottomSheet extends StatelessWidget {
  const DemarcheDoneBottomSheet({super.key, required this.demarcheId});
  final String demarcheId;

  static Future<bool?> show(BuildContext context, String demarcheId) {
    return showDsfrBottomSheet<bool?>(
      context: context,
      name: AnalyticsScreenNames.userActionDetails,
      builder: (context) => DemarcheDoneBottomSheet(demarcheId: demarcheId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DemarcheDoneBottomSheetViewModel>(
      converter: (store) =>
          DemarcheDoneBottomSheetViewModel.create(store, demarcheId),
      onDispose: (store) => store.dispatch(UpdateDemarcheResetAction()),
      builder: (context, viewModel) {
        return DsfrBottomSheet(
          child: AnimatedSwitcher(
            duration: AnimationDurations.fast,
            child: _Body(viewModel),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.viewModel);
  final DemarcheDoneBottomSheetViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => const _Success(),
      DisplayState.FAILURE => _Error(),
      DisplayState.LOADING || DisplayState.EMPTY => Stack(
        children: [
          Opacity(
            opacity: viewModel.displayState == DisplayState.LOADING ? 0.5 : 1,
            child: IgnorePointer(
              ignoring: viewModel.displayState == DisplayState.LOADING,
              child: _Form(viewModel),
            ),
          ),
          if (viewModel.displayState == DisplayState.LOADING)
            Center(
              child: CircularProgressIndicator(
                color: DsfrColorDecisions.backgroundActionHighBlueFrance(
                  context,
                ),
              ),
            ),
        ],
      ),
    };
  }
}

class _Form extends StatefulWidget {
  const _Form(this.viewModel);
  final DemarcheDoneBottomSheetViewModel viewModel;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  DateInputSource date = DateNotInitialized();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.demarcheDoneBottomSheetTitle,
          style: DsfrTextStyle.headline5(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DatePickerSuggestions(
          title: Strings.dateShortMandatory,
          firstDate: widget.viewModel.firstDate,
          isForPastSuggestions: true,
          onDateChanged: (selectedDate) {
            setState(() {
              date = selectedDate;
            });
          },
          dateSource: date,
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.jeValide,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.md,
          onPressed: date.isValid
              ? () => widget.viewModel.onDemarcheDone(date.selectedDate)
              : null,
        ),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsfrSpacings.s4w),
        Center(
          child: SvgPicture.asset(
            Drawables.illustrationSuccess,
            width: 160,
            height: 160,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        Text(
          Strings.felicitations,
          textAlign: TextAlign.center,
          style: DsfrTextStyle.headline4(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          Strings.updateDemarcheConfirmation,
          textAlign: TextAlign.center,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: Strings.understood,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Retry(
      Strings.miscellaneousErrorRetry,
      () => Navigator.pop(context, false),
      buttonLabel: Strings.close,
    );
  }
}
