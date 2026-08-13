import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step1.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step3.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class CreateUserActionForm extends StatefulWidget {
  const CreateUserActionForm({super.key, required this.onSubmit, required this.onAbort});

  final void Function(CreateUserActionFormViewModel viewModel) onSubmit;
  final void Function() onAbort;

  @override
  State<CreateUserActionForm> createState() => _CreateUserActionFormState();
}

class _CreateUserActionFormState extends State<CreateUserActionForm> {
  late final CreateUserActionFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateUserActionFormViewModel();
    _viewModel.addListener(_onFormStateChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onFormStateChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onFormStateChanged() {
    if (_viewModel.isAborted) {
      widget.onAbort();
      return;
    }
    if (_viewModel.isSubmitted) {
      widget.onSubmit(_viewModel);
    }
    if (mounted) setState(() {});
  }

  void _onBack() {
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      FocusScope.of(context).unfocus();
      return;
    }
    _viewModel.viewChangedBackward();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        resizeToAvoidBottomInset: false,
        appBar: _CreateUserActionAppBar(onBackPressed: _onBack),
        body: Stack(
          children: [
            _CreateUserActionForm(_viewModel),
            Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: _viewModel.shouldDisplayNavigationButtons && MediaQuery.viewInsetsOf(context).bottom == 0,
                child: _NavButtons(
                  displayState: _viewModel.displayState,
                  onGoBackPressed: _onBack,
                  onGoForwardPressed: _viewModel.canGoForward ? () => _viewModel.viewChangedForward() : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUserActionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CreateUserActionAppBar({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final backColor = DsfrColorDecisions.textActionHighBlueFrance(context);
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: Strings.back,
            child: InkWell(
              onTap: onBackPressed,
              child: Padding(
                padding: const EdgeInsets.only(left: DsfrSpacings.s1w, right: DsfrSpacings.s3v),
                child: Row(
                  children: [
                    Icon(DsfrIcons.systemArrowLeftSLine, color: backColor, size: 32),
                    Expanded(
                      child: Text(
                        Strings.back,
                        style: DsfrTextStyle.bodyMdBold(color: backColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Semantics(
              header: true,
              child: Text(
                Strings.createActionAppBarTitle,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButtons extends StatelessWidget {
  const _NavButtons({
    required this.displayState,
    required this.onGoBackPressed,
    required this.onGoForwardPressed,
  });

  final CreateUserActionDisplayState displayState;
  final void Function()? onGoBackPressed;
  final void Function()? onGoForwardPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      child: Padding(
        padding: EdgeInsets.only(
          top: DsfrSpacings.s4w,
          left: DsfrSpacings.s2w,
          right: DsfrSpacings.s2w,
          bottom: MediaQuery.of(context).padding.bottom + DsfrSpacings.s2w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: DsfrButton(
                label: displayState.nextLabel,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.md,
                onPressed: onGoForwardPressed,
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            SizedBox(
              width: double.infinity,
              child: DsfrButton(
                label: Strings.back,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.md,
                onPressed: onGoBackPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUserActionForm extends StatelessWidget {
  const _CreateUserActionForm(this.formState);

  final CreateUserActionFormViewModel formState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: DsfrSpacings.s2w),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: AutoFocusA11y(
            key: ValueKey(formState.displayState),
            child: DsfrStepper(
              currentStep: formState.displayState.stepIndex + 1,
              stepsCount: CreateUserActionDisplayState.stepCount,
              stepTitle: _stepTitle,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: AnimatedSwitcher(
              duration: AnimationDurations.fast,
              child: Align(
                alignment: Alignment.topCenter,
                child: switch (formState.displayState) {
                  CreateUserActionDisplayState.step1 => CreateUserActionFormStep1(
                    onActionTypeSelected: (type) => formState.userActionTypeSelected(type),
                  ),
                  CreateUserActionDisplayState.step2 => CreateUserActionFormStep2(
                    actionType: formState.step1.actionCategory!,
                    viewModel: formState.step2,
                    onTitleChanged: (titleSource) => formState.titleChanged(titleSource),
                    onDescriptionChanged: (description) => formState.descriptionChanged(description),
                  ),
                  CreateUserActionDisplayState.step3 => CreateUserActionFormStep3(
                    actionType: formState.step1.actionCategory!,
                    viewModel: formState.step3,
                    onDateChanged: (id, dateSource) => formState.duplicateUserActionDateChanged(id, dateSource),
                    onDescriptionChanged: (id, description) =>
                        formState.duplicateUserActionDescriptionChanged(id, description),
                    onDelete: (id) => formState.deleteDuplicatedUserAction(id),
                    onAddDuplicatedUserAction: () => formState.addDuplicatedUserAction(),
                    titleSource: formState.step2.titleSource,
                  ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get _stepTitle => switch (formState.displayState) {
    CreateUserActionDisplayState.step1 => Strings.userActionTitleStep1,
    CreateUserActionDisplayState.step2 => formState.step1.actionCategory!.label,
    CreateUserActionDisplayState.step3 => Strings.userActionTitleStep3,
    _ => '',
  };
}
