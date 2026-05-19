import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/contact_immersion/contact_immersion_actions.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/pages/generic_success_page.dart';
import 'package:pass_emploi_app/pages/immersion/immersion_contact_mode.dart';
import 'package:pass_emploi_app/presentation/immersion/immersion_contact_form_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/loading_overlay.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';

class ImmersionContactFormPage extends StatelessWidget {
  const ImmersionContactFormPage({super.key});

  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (_) => const ImmersionContactFormPage());
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.immersionForm,
      child: StoreConnector<AppState, ImmersionContactFormViewModel>(
        converter: (store) => ImmersionContactFormViewModel.create(store),
        builder: (context, viewModel) => _Scaffold(viewModel: viewModel),
        onDidChange: (previousVm, newVm) => _pageNavigationHandling(newVm, context),
        distinct: true,
        onDispose: ((store) => store.dispatch(ContactImmersionResetAction())),
      ),
    );
  }

  void _pageNavigationHandling(ImmersionContactFormViewModel viewModel, BuildContext context) {
    if (viewModel.sendingState.isFailure()) {
      PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.immersionFormSent(false));
      showSnackBarWithSystemError(context);
      viewModel.resetSendingState();
    } else if (viewModel.sendingState.isAlreadyDone()) {
      PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.immersionFormSent(false));
      showSnackBarWithUserError(context, Strings.contactImmersionAlreadyDone);
      viewModel.resetSendingState();
    } else if (viewModel.sendingState.isSuccess()) {
      PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.immersionFormSent(true));
      Navigator.pop(context);
      Navigator.push(
        context,
        GenericSuccessPage.route(
          title: Strings.immersionContactTitle,
          content: switch (viewModel.contactMode) {
            ImmersionContactMode.MAIL => Strings.immersionContactSucceedMail,
            ImmersionContactMode.PHONE => Strings.immersionContactSucceedPhone,
            ImmersionContactMode.PRESENTIEL => Strings.immersionContactSucceedInPerson,
            ImmersionContactMode.INCONNU => Strings.immersionContactSucceedMail,
          },
        ),
      );
    }
  }
}

class _Scaffold extends StatelessWidget {
  final ImmersionContactFormViewModel viewModel;

  const _Scaffold({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: SecondaryAppBar(title: Strings.immersitionContactFormTitle, backgroundColor: context.bg),
      body: Stack(
        children: [
          _Form(viewModel: viewModel),
          if (viewModel.sendingState.isLoading()) LoadingOverlay(),
        ],
      ),
    );
  }
}

class _Form extends StatefulWidget {
  final ImmersionContactFormViewModel viewModel;
  const _Form({required this.viewModel});

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final ImmersionContactFormChangeNotifier state;

  @override
  void initState() {
    state = ImmersionContactFormChangeNotifier(
      userEmailInitialValue: widget.viewModel.userEmailInitialValue,
      userFirstNameInitialValue: widget.viewModel.userFirstNameInitialValue,
      userLastNameInitialValue: widget.viewModel.userLastNameInitialValue,
    )..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    state.onSubmitAttempted();
    if (state.isFormFullyValid()) {
      final userInput = ImmersionContactUserInput(
        email: state.userEmailController.text,
        firstName: state.userFirstNameController.text,
        lastName: state.userLastNameController.text,
        telephone: state.telephoneController.text,
        datePreferences: state.datePreferencesController.text,
        experience: state.experienceController.text,
        linkedinOrCvUrl: state.linkedinController.text,
      );
      widget.viewModel.onFormSubmitted(userInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Margins.spacing_base),
                  ContactModeTag(contactMode: widget.viewModel.contactMode),
                  SizedBox(height: Margins.spacing_m),
                  Text(
                    Strings.immersitionContactFormSubtitle,
                    style: TextStyles.textBaseRegular.copyWith(color: context.content),
                  ),
                  SizedBox(height: Margins.spacing_m),
                  Text(
                    Strings.immersitionContactFormHint,
                    style: TextStyles.textBaseBold.copyWith(color: context.content),
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: true,
                    controller: state.userFirstNameController,
                    focusNode: state.userFirstNameFocus,
                    label: Strings.immersitionContactFormSurnameHint,
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: true,
                    controller: state.userLastNameController,
                    focusNode: state.userLastNameFocus,
                    label: Strings.immersitionContactFormNameHint,
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: true,
                    mandatoryError: state.showValidationErrors && !state.isEmailValid()
                        ? Strings.immersionContactFormEmailInvalid
                        : null,
                    controller: state.userEmailController,
                    focusNode: state.userEmailFocus,
                    label: Strings.immersitionContactFormEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: true,
                    mandatoryError: state.showValidationErrors && !state.isTelephoneValid()
                        ? Strings.immersionContactFormPhoneInvalid
                        : null,
                    controller: state.telephoneController,
                    focusNode: state.telephoneFocus,
                    label: Strings.immersitionContactFormPhoneHint,
                    keyboardType: TextInputType.phone,
                    textCapitalization: TextCapitalization.none,
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: true,
                    controller: state.datePreferencesController,
                    focusNode: state.datePreferencesFocus,
                    label: Strings.immersitionContactFormStartDateHint,
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: false,
                    controller: state.experienceController,
                    focusNode: state.experienceFocus,
                    label: Strings.immersitionContactFormExperienceLabel,
                    hintText: Strings.immersitionContactFormExperiencePlaceholder,
                    maxLength: 250,
                    maxLines: 5,
                  ),
                  SizedBox(height: Margins.spacing_m),
                  ImmersionTextFormField(
                    isMandatory: false,
                    mandatoryError: state.showValidationErrors && !state.isLinkedinValid()
                        ? Strings.immersionContactFormLinkedinInvalid
                        : null,
                    controller: state.linkedinController,
                    focusNode: state.linkedinFocus,
                    label: Strings.immersitionContactFormLinkedinLabel,
                    keyboardType: TextInputType.url,
                    textCapitalization: TextCapitalization.none,
                  ),
                  SizedBox(height: Margins.spacing_m),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Margins.spacing_m),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryActionButton(
                label: Strings.immersionContactFormButton,
                icon: AppIcons.outgoing_mail,
                onPressed: state.isButtonEnabled && !widget.viewModel.sendingState.isLoading()
                    ? _validateAndSubmit
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImmersionTextFormField extends StatelessWidget {
  final String label;
  final bool isMandatory;
  final String? mandatoryError;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int? maxLength;
  final String? hintText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const ImmersionTextFormField({
    super.key,
    required this.isMandatory,
    this.mandatoryError,
    this.onChanged,
    required this.label,
    this.maxLines = 1,
    required this.controller,
    required this.focusNode,
    this.maxLength,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    final displayedLabel = isMandatory ? '* $label' : '$label ${Strings.immersitionContactFormOptionalSuffix}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayedLabel, style: TextStyles.textBaseMedium.copyWith(color: context.content)),
        SizedBox(height: Margins.spacing_base),
        BaseTextField(
          focusNode: focusNode,
          minLines: 1,
          maxLength: maxLength,
          maxLines: maxLines,
          controller: controller,
          errorText: focusNode.hasFocus ? null : mandatoryError,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          hintText: hintText,
        ),
      ],
    );
  }
}

class ImmersionContactFormChangeNotifier extends ChangeNotifier {
  bool isButtonEnabled = false;
  bool showValidationErrors = false;

  late final TextEditingController userEmailController;
  late final TextEditingController userFirstNameController;
  late final TextEditingController userLastNameController;
  late final TextEditingController telephoneController;
  late final TextEditingController datePreferencesController;
  late final TextEditingController experienceController;
  late final TextEditingController linkedinController;

  late final FocusNode userEmailFocus;
  late final FocusNode userFirstNameFocus;
  late final FocusNode userLastNameFocus;
  late final FocusNode telephoneFocus;
  late final FocusNode datePreferencesFocus;
  late final FocusNode experienceFocus;
  late final FocusNode linkedinFocus;

  ImmersionContactFormChangeNotifier({
    required String userEmailInitialValue,
    required String userFirstNameInitialValue,
    required String userLastNameInitialValue,
  }) {
    userEmailController = TextEditingController(text: userEmailInitialValue)..addListener(onAnyFieldChanged);
    userFirstNameController = TextEditingController(text: userFirstNameInitialValue)..addListener(onAnyFieldChanged);
    userLastNameController = TextEditingController(text: userLastNameInitialValue)..addListener(onAnyFieldChanged);
    telephoneController = TextEditingController()..addListener(onAnyFieldChanged);
    datePreferencesController = TextEditingController(text: Strings.desQuePossible)..addListener(onAnyFieldChanged);
    experienceController = TextEditingController()..addListener(onAnyFieldChanged);
    linkedinController = TextEditingController()..addListener(onAnyFieldChanged);

    userEmailFocus = FocusNode()..addListener(onFocusChanged);
    userFirstNameFocus = FocusNode()..addListener(onFocusChanged);
    userLastNameFocus = FocusNode()..addListener(onFocusChanged);
    telephoneFocus = FocusNode()..addListener(onFocusChanged);
    datePreferencesFocus = FocusNode()..addListener(onFocusChanged);
    experienceFocus = FocusNode()..addListener(onFocusChanged);
    linkedinFocus = FocusNode()..addListener(onFocusChanged);

    isButtonEnabled = _areMandatoryFieldsNonEmpty();
  }

  bool _areMandatoryFieldsNonEmpty() {
    return userFirstNameController.text.isNotEmpty &&
        userLastNameController.text.isNotEmpty &&
        userEmailController.text.isNotEmpty &&
        telephoneController.text.isNotEmpty &&
        datePreferencesController.text.isNotEmpty;
  }

  bool isFormFullyValid() {
    return _areMandatoryFieldsNonEmpty() && isEmailValid() && isTelephoneValid() && isLinkedinValid();
  }

  bool isEmailValid() {
    final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    return emailRegex.hasMatch(userEmailController.text);
  }

  bool isTelephoneValid() {
    final RegExp phoneRegex = RegExp(r'^(?:\+33|0033|0)[1-9](?:[\s.\-]?\d{2}){4}$');
    return phoneRegex.hasMatch(telephoneController.text.trim());
  }

  bool isLinkedinValid() {
    final value = linkedinController.text.trim();
    if (value.isEmpty) return true;
    final RegExp urlRegex = RegExp(r'^https?://[^\s/$.?#].[^\s]*$', caseSensitive: false);
    return urlRegex.hasMatch(value);
  }

  void onSubmitAttempted() {
    showValidationErrors = true;
    notifyListeners();
  }

  void onAnyFieldChanged() {
    isButtonEnabled = _areMandatoryFieldsNonEmpty();
    notifyListeners();
  }

  void onFocusChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    userEmailController.dispose();
    userFirstNameController.dispose();
    userLastNameController.dispose();
    telephoneController.dispose();
    datePreferencesController.dispose();
    experienceController.dispose();
    linkedinController.dispose();
    userEmailFocus.dispose();
    userFirstNameFocus.dispose();
    userLastNameFocus.dispose();
    telephoneFocus.dispose();
    datePreferencesFocus.dispose();
    experienceFocus.dispose();
    linkedinFocus.dispose();
    super.dispose();
  }
}
