import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_actions.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_state.dart';
import 'package:pass_emploi_app/features/user_action/commentaire/list/action_commentaire_list_actions.dart';
import 'package:pass_emploi_app/features/user_action/delete/user_action_delete_actions.dart';
import 'package:pass_emploi_app/features/user_action/details/user_action_details_actions.dart';
import 'package:pass_emploi_app/features/user_action/update/user_action_update_actions.dart';
import 'package:pass_emploi_app/models/user_action.dart';
import 'package:pass_emploi_app/pages/generic_success_page.dart';
import 'package:pass_emploi_app/pages/user_action/action_commentaires_page.dart';
import 'package:pass_emploi_app/pages/user_action/user_action_detail_bottom_sheet.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/presentation/model/date_suggestions_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/commentaires/action_commentaire_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_details_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_done_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/comment.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/loading_overlay.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:pass_emploi_app/widgets/text_with_clickable_links.dart';

class UserActionDetailPage extends StatefulWidget {
  final String userActionId;
  final UserActionStateSource source;

  UserActionDetailPage._(this.userActionId, this.source);

  static Future<void> show(
    BuildContext context,
    String userActionId,
    UserActionStateSource source,
  ) {
    return showDsfrBottomSheet(
      context: context,
      name: AnalyticsScreenNames.userActionDetails,
      builder: (context) => UserActionDetailPage._(userActionId, source),
    );
  }

  @override
  State<UserActionDetailPage> createState() => _ActionDetailPageState();
}

class _ActionDetailPageState extends State<UserActionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.userActionDetails,
      child: ConfettiWrapper(
        builder: (context, confettiController) {
          return StoreConnector<AppState, UserActionDetailsViewModel>(
            onInit: (store) {
              final monSuiviState = store.state.monSuiviState;
              if (monSuiviState is! MonSuiviSuccessState) {
                store.dispatch(MonSuiviRequestAction(MonSuiviPeriod.current));
              }
              if (widget.source == UserActionStateSource.noSource) {
                store.dispatch(
                  UserActionDetailsRequestAction(widget.userActionId),
                );
              }

              store.dispatch(UserActionUpdateResetAction());
              store.dispatch(UserActionDeleteResetAction());
            },
            converter: (store) => UserActionDetailsViewModel.create(
              store,
              widget.source,
              widget.userActionId,
            ),
            builder: (context, viewModel) =>
                StoreConnector<AppState, UserActionDoneBottomSheetViewModel>(
                  converter: (store) =>
                      UserActionDoneBottomSheetViewModel.create(
                        store,
                        widget.source,
                        widget.userActionId,
                      ),
                  builder: (context, doneViewModel) => _Sheet(
                    viewModel: viewModel,
                    doneViewModel: doneViewModel,
                    source: widget.source,
                  ),
                  onDidChange: (previous, next) {
                    if (previous?.displayState != DisplayState.CONTENT &&
                        next.displayState == DisplayState.CONTENT) {
                      confettiController.play();
                    }
                  },
                  distinct: true,
                ),
            onDispose: (store) {
              if (widget.source == UserActionStateSource.noSource) {
                store.dispatch(UserActionDetailsResetAction());
              }
            },
            onDidChange: (previousVm, newVm) => _pageNavigationHandling(newVm),
            distinct: true,
          );
        },
      ),
    );
  }

  void _pageNavigationHandling(UserActionDetailsViewModel viewModel) {
    final context = this.context;
    if (viewModel.updateDisplayState == UpdateDisplayState.SHOW_UPDATE_ERROR) {
      showSnackBarWithSystemError(context, Strings.updateStatusError);
      viewModel.resetUpdateStatus();
    } else if (viewModel.updateDisplayState ==
        UpdateDisplayState.TO_DISMISS_AFTER_UPDATE) {
      _trackSuccessfulUpdate();
    } else if (viewModel.deleteDisplayState ==
        DeleteDisplayState.TO_DISMISS_AFTER_DELETION) {
      final navigator = Navigator.of(context);
      navigator.pop();
      navigator.push(
        GenericSuccessPage.route(
          title: Strings.deleteActionSuccessTitle,
          content: Strings.deleteActionSuccess,
        ),
      );
    } else if (viewModel.deleteDisplayState ==
        DeleteDisplayState.SHOW_DELETE_ERROR) {
      showSnackBarWithSystemError(context, Strings.deleteActionError);
    }
  }

  void _trackSuccessfulUpdate() {
    PassEmploiMatomoTracker.instance.trackScreen(
      AnalyticsScreenNames.updateUserAction,
    );
  }
}

class _Sheet extends StatelessWidget {
  final UserActionDetailsViewModel viewModel;
  final UserActionDoneBottomSheetViewModel doneViewModel;
  final UserActionStateSource source;

  const _Sheet({
    required this.viewModel,
    required this.doneViewModel,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = doneViewModel.displayState == DisplayState.CONTENT;
    return Stack(
      children: [
        DsfrBottomSheet(
          leading: viewModel.displayState == DisplayState.CONTENT && !isSuccess
              ? DsfrBottomSheetMoreActionsButton(
                  onPressed: () => UserActionDetailsBottomSheet.show(
                    context,
                    source,
                    viewModel.id,
                  ),
                )
              : null,
          actions: _actions(context, isSuccess),
          child: _Body(
            viewModel: viewModel,
            doneViewModel: doneViewModel,
            isSuccess: isSuccess,
          ),
        ),
        if (_isLoading(viewModel) ||
            doneViewModel.displayState == DisplayState.LOADING)
          Positioned.fill(child: LoadingOverlay()),
      ],
    );
  }

  Widget? _actions(BuildContext context, bool isSuccess) {
    if (isSuccess) {
      return DsfrButton(
        label: Strings.understood,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.md,
        onPressed: () => Navigator.of(context).pop(),
      );
    }
    if (viewModel.displayState != DisplayState.CONTENT) return null;
    if (viewModel.withUnfinishedButton) {
      return DsfrButton(
        label: Strings.unCompleteAction,
        icon: DsfrIcons.systemTimeLine,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.md,
        onPressed: () => viewModel.updateStatus(UserActionStatus.IN_PROGRESS),
      );
    }
    return null;
  }

  bool _isLoading(UserActionDetailsViewModel viewModel) {
    return viewModel.updateDisplayState == UpdateDisplayState.SHOW_LOADING ||
        viewModel.deleteDisplayState == DeleteDisplayState.SHOW_LOADING;
  }
}

class _Body extends StatelessWidget {
  final UserActionDetailsViewModel viewModel;
  final UserActionDoneBottomSheetViewModel doneViewModel;
  final bool isSuccess;

  const _Body({
    required this.viewModel,
    required this.doneViewModel,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuccess) return const _SuccessContent();
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _Content(viewModel, doneViewModel),
      DisplayState.LOADING => const Center(child: CircularProgressIndicator()),
      _ => Retry(Strings.userActionDetailsError, () => viewModel.onRetry()),
    };
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent();

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
          Strings.updateActionConfirmation,
          textAlign: TextAlign.center,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final UserActionDetailsViewModel viewModel;
  final UserActionDoneBottomSheetViewModel doneViewModel;

  const _Content(this.viewModel, this.doneViewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.withOfflineBehavior) ConnectivityBandeau(),
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            DsfrCategoryTag.emploiCategory(label: viewModel.category),
            DsfrStatusBadge.fromPillule(
              pillule: viewModel.pillule,
              forDemarche: false,
            ),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Semantics(
          header: true,
          child: Text(
            viewModel.title,
            style: DsfrTextStyle.headline5(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrDetailIconLine(
          icon: DsfrIcons.businessCalendarEventLine,
          text: viewModel.date,
          semanticsLabel: viewModel.date.toDateForScreenReaders(),
        ),
        if (viewModel.withSubtitle) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          TextWithClickableLinks(
            viewModel.subtitle,
            style: DsfrTextStyle.bodyMd(
              color: DsfrColorDecisions.textDefaultGrey(context),
            ),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          viewModel.creationDetails,
          semanticsLabel: viewModel.creationDetails.toDateForScreenReaders(),
          style: DsfrTextStyle.bodyXs(
            color: DsfrColorDecisions.textMentionGrey(context),
          ),
        ),
        if (viewModel.withComments) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
            child: Divider(
              height: 1,
              color: DsfrColorDecisions.borderDefaultGrey(context),
            ),
          ),
          _CommentSection(viewModel),
        ],
        if (viewModel.withFinishedButton) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
            child: Divider(
              height: 1,
              color: DsfrColorDecisions.borderDefaultGrey(context),
            ),
          ),
          _FinishActionSection(doneViewModel: doneViewModel),
        ],
      ],
    );
  }
}

class _FinishActionSection extends StatefulWidget {
  const _FinishActionSection({required this.doneViewModel});

  final UserActionDoneBottomSheetViewModel doneViewModel;

  @override
  State<_FinishActionSection> createState() => _FinishActionSectionState();
}

class _FinishActionSectionState extends State<_FinishActionSection> {
  DateInputSource _date = DateNotInitialized();
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doneViewModel.displayState == DisplayState.FAILURE) {
      return Retry(
        Strings.miscellaneousErrorRetry,
        () => Navigator.pop(context),
        buttonLabel: Strings.close,
      );
    }

    final suggestions = DateSuggestionListViewModel.createPast(
      DateTime.now(),
      null,
    ).suggestions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.actionDoneWhen,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            for (final suggestion in suggestions)
              DsfrButton(
                label: suggestion.date.isToday()
                    ? Strings.dateSuggestionAujourdhui
                    : Strings.dateSuggestionHier,
                variant: _isSuggestionSelected(suggestion)
                    ? DsfrButtonVariant.primary
                    : DsfrButtonVariant.secondary,
                size: DsfrComponentSize.sm,
                onPressed: () => _selectSuggestion(suggestion),
              ),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.otherDate,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textLabelGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1v),
        Text(
          Strings.cannotFinishActionInFuture,
          style: DsfrTextStyle.bodyXs(
            color: DsfrColorDecisions.textMentionGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrInputHeadless(
          controller: _dateController,
          isDatePicker: true,
          lastDate: DateTime.now(),
          locale: const Locale('fr', 'FR'),
          onDateChanged: (date) {
            setState(() => _date = DateFromPicker(date));
          },
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: Strings.markActionAsDone,
          icon: DsfrIcons.systemCheckLine,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.md,
          onPressed: _date.isValid
              ? () => widget.doneViewModel.onActionDone(_date.selectedDate)
              : null,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrButton(
          label: Strings.completeActionNotYet,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  bool _isSuggestionSelected(DateSuggestionViewModel suggestion) {
    return switch (_date) {
      DateFromSuggestion(:final date) =>
        DateUtils.dateOnly(date) == DateUtils.dateOnly(suggestion.date),
      _ => false,
    };
  }

  void _selectSuggestion(DateSuggestionViewModel suggestion) {
    setState(() {
      _date = DateFromSuggestion(suggestion.date, suggestion.label);
      _dateController.text = DateFormat('dd/MM/yyyy').format(suggestion.date);
    });
  }
}

class _CommentSection extends StatelessWidget {
  const _CommentSection(this.viewModel);

  final UserActionDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.withOfflineBehavior) {
      return const _UnavailableCommentsOffline();
    } else {
      return _CommentCard(actionId: viewModel.id, actionTitle: viewModel.title);
    }
  }
}

class _CommentCard extends StatelessWidget {
  final String actionId;
  final String actionTitle;

  const _CommentCard({required this.actionId, required this.actionTitle});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ActionCommentaireViewModel>(
      onInit: (store) =>
          store.dispatch(ActionCommentaireListRequestAction(actionId)),
      converter: (store) => ActionCommentaireViewModel.create(store, actionId),
      builder: (context, viewModel) => _build(context, viewModel),
      distinct: true,
    );
  }

  Widget _build(BuildContext context, ActionCommentaireViewModel viewModel) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _content(
        context,
        viewModel,
        actionId,
        actionTitle,
      ),
      DisplayState.FAILURE => Retry(
        Strings.miscellaneousErrorRetry,
        () => viewModel.onRetry(),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _content(
    BuildContext context,
    ActionCommentaireViewModel viewModel,
    String actionId,
    String actionTitle,
  ) {
    final commentsNumber = viewModel.comments.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.lastComment,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        if (viewModel.lastComment != null)
          Comment(comment: viewModel.lastComment!),
        if (viewModel.lastComment == null)
          Text(
            Strings.noComments,
            style: DsfrTextStyle.bodyMd(
              color: DsfrColorDecisions.textDefaultGrey(context),
            ),
          ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          onPressed: () => _onCommentClick(context, actionId, actionTitle),
          label: commentsNumber < 1
              ? Strings.addComment
              : Strings.seeNComments(commentsNumber.toString()),
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.md,
        ),
      ],
    );
  }

  void _onCommentClick(
    BuildContext context,
    String actionId,
    String actionTitle,
  ) {
    PassEmploiMatomoTracker.instance.trackScreen(
      AnalyticsActionNames.accessToActionComments,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActionCommentairesPage(
          actionId: actionId,
          actionTitle: actionTitle,
        ),
      ),
    );
  }
}

class _UnavailableCommentsOffline extends StatelessWidget {
  const _UnavailableCommentsOffline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.lastComment,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.commentsUnavailableOffline,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
      ],
    );
  }
}
