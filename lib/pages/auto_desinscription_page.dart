import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_actions.dart';
import 'package:pass_emploi_app/features/events/list/event_list_actions.dart';
import 'package:pass_emploi_app/presentation/auto_desinscription_view_model.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class DesinscriptionPage extends StatelessWidget {
  const DesinscriptionPage({super.key, required this.source, required this.rdvId});
  final RendezvousStateSource source;
  final String rdvId;

  static Route<bool?> route({required RendezvousStateSource source, required String rdvId}) {
    return MaterialPageRoute<bool?>(
      fullscreenDialog: true,
      builder: (_) => DesinscriptionPage(source: source, rdvId: rdvId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return StoreConnector<AppState, AutoDesinscriptionViewModel>(
      converter: (store) => AutoDesinscriptionViewModel.create(store, source: source, rdvId: rdvId),
      onDispose: (store) {
        store.dispatch(AutoDesinscriptionResetAction());
        store.dispatch(EventListRequestAction(DateTime.now(), forceRefresh: true));
      },
      builder: (context, viewModel) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
        return Theme(
          data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: SecondaryAppBar(
              title: switch (viewModel.displayState) {
                AutoDesinscriptionDisplayState.success => Strings.autoDesinscriptionSuccessAppBarTitle,
                _ => Strings.annulerInscription,
              },
              backgroundColor: backgroundColor,
            ),
            body: _Body(viewModel: viewModel, textController: textController),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.viewModel, required this.textController});
  final TextEditingController textController;
  final AutoDesinscriptionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      child: switch (viewModel.displayState) {
        AutoDesinscriptionDisplayState.loading => const _Loading(),
        AutoDesinscriptionDisplayState.success => _Success(viewModel: viewModel),
        AutoDesinscriptionDisplayState.failure => const _Failure(),
        AutoDesinscriptionDisplayState.initial => _Form(viewModel: viewModel, textController: textController),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _Failure extends StatelessWidget {
  const _Failure();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          Drawables.illustrationWarning,
          width: 160,
          height: 160,
          excludeFromSemantics: true,
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        Semantics(
          header: true,
          child: Text(
            Strings.error,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          Strings.genericError,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        const _CloseButton(),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.viewModel});
  final AutoDesinscriptionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: DsfrSpacings.s3w),
                  const SuccessIllustration(size: 160),
                  const SizedBox(height: DsfrSpacings.s3w),
                  Semantics(
                    header: true,
                    child: Text(
                      Strings.autoDesinscriptionSuccessTitle(viewModel.title ?? ""),
                      style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomActions(
            children: [
              SizedBox(
                width: double.infinity,
                child: DsfrButton(
                  label: Strings.autoDesinscriptionVoirAutresEvenements,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.md,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  _Form({required this.viewModel, required this.textController});
  final TextEditingController textController;
  final AutoDesinscriptionViewModel viewModel;
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.title != null)
            Semantics(
              header: true,
              child: Text(
                viewModel.title!,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrDetailIconLine(
            icon: DsfrIcons.businessCalendarLine,
            text: viewModel.date,
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrDetailIconLine(
            icon: DsfrIcons.systemTimeLine,
            text: viewModel.hourAndDuration,
            semanticsLabel: viewModel.hourAndDuration.toTimeAndDurationForScreenReaders(),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            Strings.autoDesinscriptionFormConfirmation,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          KeyedSubtree(
            key: _textFieldKey,
            child: DsfrInput(
              label: Strings.autoDesinscriptionFormFieldTitle,
              controller: textController,
              minLines: 5,
              maxLines: 5,
              inputFormatters: [LengthLimitingTextInputFormatter(250)],
              onChanged: (value) {
                Scrollable.ensureVisible(_textFieldKey.currentContext!);
              },
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          _ConfirmButton(
            onPressed: () => viewModel.desinscribe(textController.text),
            textController: textController,
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          const _CancelButton(),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatefulWidget {
  const _ConfirmButton({required this.onPressed, required this.textController});
  final VoidCallback onPressed;
  final TextEditingController textController;

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool get isDisabled => widget.textController.text.isEmpty;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DsfrButton(
        label: Strings.autoDesinscriptionConfirm,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.md,
        onPressed: isDisabled ? null : widget.onPressed,
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DsfrButton(
        label: Strings.autoDesinscriptionCancel,
        variant: DsfrButtonVariant.secondary,
        size: DsfrComponentSize.md,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DsfrButton(
        label: Strings.close,
        variant: DsfrButtonVariant.secondary,
        size: DsfrComponentSize.md,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
