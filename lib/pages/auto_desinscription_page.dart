import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_actions.dart';
import 'package:pass_emploi_app/presentation/auto_desinscription_view_model.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/media_sizes.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_complement.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';
import 'package:pass_emploi_app/widgets/illustration/illustration.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';

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
      onDispose: (store) => store.dispatch(AutoDesinscriptionResetAction()),
      builder: (context, viewModel) => Scaffold(
        floatingActionButton: _Buttons(viewModel: viewModel, textController: textController),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        backgroundColor: Colors.white,
        appBar: SecondaryAppBar(title: Strings.annulerInscription),
        body: _Body(viewModel: viewModel, textController: textController),
      ),
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
      padding: const EdgeInsets.all(Margins.spacing_base),
      child: switch (viewModel.displayState) {
        AutoDesinscriptionDisplayState.loading => _Loading(),
        AutoDesinscriptionDisplayState.success => _Success(viewModel: viewModel),
        AutoDesinscriptionDisplayState.failure => _Failure(),
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
        SizedBox.square(dimension: 150, child: Illustration.red(AppIcons.warning_rounded)),
        SizedBox(height: Margins.spacing_m),
        ErrorText(Strings.genericError),
      ],
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.viewModel});
  final AutoDesinscriptionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: height < MediaSizes.height_xs ? 60 : 180,
          child: Illustration.green(
            AppIcons.check_rounded,
          ),
        ),
        SizedBox(height: Margins.spacing_m),
        Text(
          Strings.autoDesinscriptionSuccessTitle(viewModel.title ?? ""),
          style: TextStyles.textMBold,
          textAlign: TextAlign.center,
        ),
      ],
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
          if (viewModel.title != null) Text(viewModel.title!, style: TextStyles.textLBold()),
          SizedBox(height: Margins.spacing_m),
          Wrap(
            spacing: Margins.spacing_base,
            children: [
              CardComplement.date(text: viewModel.date),
              CardComplement.hour(text: viewModel.hourAndDuration),
            ],
          ),
          SizedBox(height: Margins.spacing_m),
          Text(Strings.autoDesinscriptionFormConfirmation, style: TextStyles.textMBold),
          SizedBox(height: Margins.spacing_m),
          Text(Strings.autoDesinscriptionFormFieldTitle, style: TextStyles.textBaseBold),
          SizedBox(height: Margins.spacing_s),
          BaseTextField(
            key: _textFieldKey,
            controller: textController,
            minLines: 5,
            maxLength: 250,
            onChanged: (value) {
              Scrollable.ensureVisible(_textFieldKey.currentContext!);
            },
          ),
          SizedBox(height: Margins.spacing_m),
          _InformationBandeau(),
          SizedBox(height: Margins.spacing_xx_huge),
        ],
      ),
    );
  }
}

class _InformationBandeau extends StatelessWidget {
  const _InformationBandeau();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLighten,
        borderRadius: BorderRadius.circular(Dimens.radius_base),
      ),
      child: Padding(
        padding: EdgeInsets.all(Margins.spacing_base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.info_rounded, color: AppColors.primaryCej, size: Dimens.icon_size_m),
            SizedBox(width: Margins.spacing_base),
            Expanded(
              child: Text(
                Strings.autoDesinscriptionInformation,
                style: TextStyles.textSRegular(color: AppColors.primaryCej),
              ),
            ),
          ],
        ),
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

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryActionButton(
      label: Strings.autoDesinscriptionConfirm,
      onPressed: isDisabled ? null : widget.onPressed,
    );
  }
}

class _SuccessCloseButton extends StatelessWidget {
  const _SuccessCloseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryActionButton(
        label: Strings.autoDesinscriptionVoirAutresEvenements,
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: Strings.autoDesinscriptionCancel,
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({required this.viewModel, required this.textController});
  final AutoDesinscriptionViewModel viewModel;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
      child: switch (viewModel.displayState) {
        AutoDesinscriptionDisplayState.loading => SizedBox.shrink(),
        AutoDesinscriptionDisplayState.success => _SuccessCloseButton(),
        AutoDesinscriptionDisplayState.failure => _CloseButton(),
        AutoDesinscriptionDisplayState.initial => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ConfirmButton(
              onPressed: () => viewModel.desinscribe(textController.text),
              textController: textController,
            ),
            SizedBox(height: Margins.spacing_base),
            _CancelButton(),
          ],
        ),
      },
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SecondaryButton(
        label: Strings.close,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}
