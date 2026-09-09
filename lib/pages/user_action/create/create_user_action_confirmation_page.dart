import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_page.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/user_action/create_user_action_confirmation_view_model.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';

class CreateUserActionConfirmationPage extends StatelessWidget {
  final UserActionStateSource source;
  final bool multipleActions;
  final bool showActionDoneTag;

  const CreateUserActionConfirmationPage({
    super.key,
    required this.source,
    required this.multipleActions,
    this.showActionDoneTag = false,
  });

  static Route<CreateActionFormResult> route(
    UserActionStateSource source, {
    required bool multipleActions,
    bool showActionDoneTag = false,
  }) {
    return MaterialPageRoute<CreateActionFormResult>(
      fullscreenDialog: true,
      builder: (_) => CreateUserActionConfirmationPage(
        source: source,
        multipleActions: multipleActions,
        showActionDoneTag: showActionDoneTag,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CreateActionSuccessViewModel>(
      converter: (store) => CreateActionSuccessViewModel.create(store),
      builder: (context, viewModel) {
        return Scaffold(
          backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              DsfrButton(
                label: Strings.close,
                icon: DsfrIcons.systemCloseLine,
                iconLocation: DsfrButtonIconLocation.right,
                variant: DsfrButtonVariant.tertiaryWithoutBorder,
                size: DsfrComponentSize.sm,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: SafeArea(
            child: _Content(
              viewModel: viewModel,
              multipleActions: multipleActions,
              showActionDoneTag: showActionDoneTag,
              source: source,
            ),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.viewModel,
    required this.multipleActions,
    required this.showActionDoneTag,
    required this.source,
  });
  final CreateActionSuccessViewModel viewModel;
  final bool multipleActions;
  final bool showActionDoneTag;
  final UserActionStateSource source;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _Body(
          viewModel: viewModel,
          multipleActions: multipleActions,
          showActionDoneTag: showActionDoneTag,
          source: source,
        ),
      DisplayState.FAILURE => Center(child: ErrorText(Strings.genericCreationError)),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.viewModel,
    required this.multipleActions,
    required this.showActionDoneTag,
    required this.source,
  });
  final CreateActionSuccessViewModel viewModel;
  final bool multipleActions;
  final bool showActionDoneTag;
  final UserActionStateSource source;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: DsfrSpacings.s3w),
                  Center(
                    child: SvgPicture.asset(
                      Drawables.illustrationSuccess,
                      width: 56,
                      height: 56,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s3v),
                  if (showActionDoneTag) ...[
                    DsfrCategoryTag.actionDone(),
                    const SizedBox(height: DsfrSpacings.s3v),
                  ],
                  Text(
                    Strings.userActionConfirmationTitle(viewModel.firstName),
                    textAlign: TextAlign.center,
                    style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  Text(
                    multipleActions
                        ? Strings.userActionConfirmationSubtitlePlural
                        : Strings.userActionConfirmationSubtitle(viewModel.actionContent),
                    textAlign: TextAlign.center,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ],
              ),
            ),
          ),
          _Buttons(
            onGoActionDetail: () => Navigator.pop(context, NavigateToUserActionDetails(viewModel.actionId, source)),
            onCreateMore: () => Navigator.pop(context, CreateNewUserAction()),
            multipleActions: multipleActions,
            onGoToMonSuivi: () => Navigator.pop(context, NavigateToMonSuivi()),
          ),
        ],
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({
    required this.onGoActionDetail,
    required this.onCreateMore,
    required this.multipleActions,
    required this.onGoToMonSuivi,
  });

  final void Function() onGoActionDetail;
  final void Function() onCreateMore;
  final void Function() onGoToMonSuivi;
  final bool multipleActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w, top: DsfrSpacings.s4w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (multipleActions)
            AutoFocusA11y(
              child: SizedBox(
                width: double.infinity,
                child: DsfrButton(
                  label: Strings.goToMonSuivi,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.md,
                  onPressed: onGoToMonSuivi,
                ),
              ),
            )
          else
            AutoFocusA11y(
              child: SizedBox(
                width: double.infinity,
                child: DsfrButton(
                  label: Strings.userActionConfirmationSeeDetailButton,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.md,
                  onPressed: onGoActionDetail,
                ),
              ),
            ),
          const SizedBox(height: DsfrSpacings.s2w),
          SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: Strings.userActionConfirmationCreateMoreButton,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.md,
              onPressed: onCreateMore,
            ),
          ),
        ],
      ),
    );
  }
}
