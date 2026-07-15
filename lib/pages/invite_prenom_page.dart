import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_actions.dart';
import 'package:pass_emploi_app/presentation/invite_prenom_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/base_text_form_field.dart';

/// Écran terminal du parcours invité : on relit le prénom stocké côté API et on
/// permet de le modifier. La suite des écrans reste à développer.
class InvitePrenomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, InvitePrenomPageViewModel>(
      onInit: (store) => store.dispatch(InvitePrenomRequestAction()),
      converter: (store) => InvitePrenomPageViewModel.create(store),
      builder: (context, viewModel) => _Scaffold(viewModel),
      distinct: true,
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold(this.viewModel);

  final InvitePrenomPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.invitePrenomTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Margins.spacing_base),
          child: switch (viewModel.displayState) {
            InvitePrenomDisplayState.loading => Center(child: CircularProgressIndicator()),
            InvitePrenomDisplayState.error => _Error(viewModel),
            InvitePrenomDisplayState.updated => _Updated(viewModel),
            InvitePrenomDisplayState.content => _Form(viewModel),
          },
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form(this.viewModel);

  final InvitePrenomPageViewModel viewModel;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.prenom);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(Strings.invitePrenomSubtitle, style: TextStyles.textBaseRegular),
        SizedBox(height: Margins.spacing_base),
        BaseTextField(
          controller: _controller,
          hintText: Strings.invitePrenomHint,
          errorText: widget.viewModel.withUpdateError ? Strings.invitePrenomUpdateError : null,
          isInvalid: widget.viewModel.withUpdateError,
        ),
        SizedBox(height: Margins.spacing_base),
        PrimaryActionButton(
          label: Strings.invitePrenomValidate,
          onPressed: () => widget.viewModel.onUpdate(_controller.text.trim()),
        ),
      ],
    );
  }
}

class _Updated extends StatelessWidget {
  const _Updated(this.viewModel);

  final InvitePrenomPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 64),
        SizedBox(height: Margins.spacing_base),
        Text(
          Strings.invitePrenomUpdated(viewModel.prenom),
          style: TextStyles.textBaseBold,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Margins.spacing_s),
        Text(
          Strings.invitePrenomNextSteps,
          style: TextStyles.textSRegular(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error(this.viewModel);

  final InvitePrenomPageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(Strings.invitePrenomLoadError, textAlign: TextAlign.center),
        SizedBox(height: Margins.spacing_base),
        PrimaryActionButton(label: Strings.retry, onPressed: viewModel.onRetry),
      ],
    );
  }
}
