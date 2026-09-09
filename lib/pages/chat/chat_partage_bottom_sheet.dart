import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/pages/generic_success_page.dart';
import 'package:pass_emploi_app/presentation/chat/chat_partage_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class ChatPartageBottomSheet extends StatefulWidget {
  final ChatPartageSource source;

  ChatPartageBottomSheet._({required this.source});

  @override
  ChatPartageBottomSheetState createState() => ChatPartageBottomSheetState();

  static Future<void> show(BuildContext context, ChatPartageSource source) {
    return showPassEmploiBottomSheet(
      context: context,
      builder: (context) => ChatPartageBottomSheet._(source: source),
    );
  }
}

class ChatPartageBottomSheetState extends State<ChatPartageBottomSheet> {
  TextEditingController? _controller;

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.emploiPartagePage,
      child: StoreConnector<AppState, ChatPartageBottomSheetViewModel>(
        converter: (store) => ChatPartageBottomSheetViewModel.fromSource(store, widget.source),
        builder: _builder,
        onWillChange: _onWillChange,
        distinct: true,
        onDidChange: (oldVm, newVm) {
          // a11y : 5.4
          if (oldVm?.snackbarState == DisplayState.CONTENT && newVm.snackbarState == DisplayState.LOADING) {
            SemanticsService.announce(Strings.loadingAnnouncement, TextDirection.ltr);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _builder(BuildContext context, ChatPartageBottomSheetViewModel viewModel) {
    _controller ??= TextEditingController(text: viewModel.defaultMessage);
    return FiltresBottomSheet(
      title: viewModel.pageTitle,
      body: _Body(viewModel, _controller),
    );
  }

  void _onWillChange(ChatPartageBottomSheetViewModel? _, ChatPartageBottomSheetViewModel viewModel) {
    switch (viewModel.snackbarState) {
      case DisplayState.CONTENT:
        PassEmploiMatomoTracker.instance.trackScreen(viewModel.snackbarSuccessTracking);
        A11yUtils.announce(viewModel.shareSuccessTitle);
        viewModel.confirmationDisplayed();
        Navigator.pop(context);
        Navigator.push(
          context,
          GenericSuccessPage.route(
            title: viewModel.shareSuccessTitle,
            content: viewModel.shareSuccessContent,
          ),
        );
        break;
      case DisplayState.FAILURE:
        showSnackBarWithSystemError(context);
        viewModel.confirmationDisplayed();
        break;
      case DisplayState.EMPTY:
      case DisplayState.LOADING:
        A11yUtils.announce(Strings.loadingAnnouncement);
        break;
    }
  }
}

class _Body extends StatelessWidget {
  final ChatPartageBottomSheetViewModel _viewModel;
  final TextEditingController? _controller;

  const _Body(this._viewModel, this._controller);

  @override
  Widget build(BuildContext context) {
    final isLoading = _viewModel.snackbarState == DisplayState.LOADING;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                _viewModel.willShareTitle,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              _ShareablePreview(title: _viewModel.shareableTitle),
              const SizedBox(height: DsfrSpacings.s3w),
              DsfrInput(
                label: Strings.messagePourConseiller,
                controller: _controller,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 5,
                enabled: !isLoading,
              ),
              const SizedBox(height: DsfrSpacings.s3w),
              DsfrAlert(
                type: DsfrAlertType.info,
                description: DsfrAlertDescriptionText(_viewModel.information),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        _PartageButton(_viewModel, _controller),
      ],
    );
  }
}

class _ShareablePreview extends StatelessWidget {
  final String title;

  const _ShareablePreview({required this.title});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundContrastGrey(context),
        border: Border(
          left: BorderSide(
            color: DsfrColorDecisions.borderPlainBlueFrance(context),
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Text(
          title,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
      ),
    );
  }
}

class _PartageButton extends StatelessWidget {
  final ChatPartageBottomSheetViewModel _viewModel;
  final TextEditingController? _controller;

  const _PartageButton(this._viewModel, this._controller);

  @override
  Widget build(BuildContext context) {
    return switch (_viewModel.snackbarState) {
      DisplayState.LOADING => Center(
        child: CircularProgressIndicator(
          color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
        ),
      ),
      _ => DsfrButton(
        label: _viewModel.shareButtonTitle,
        icon: DsfrIcons.systemShareLine,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.lg,
        onPressed: () => _viewModel.onShare(_controller?.text ?? ''),
      ),
    };
  }
}
