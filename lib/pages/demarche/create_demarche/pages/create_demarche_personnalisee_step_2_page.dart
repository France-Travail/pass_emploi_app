import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class CreateDemarchePersonnaliseeStep2Page extends StatefulWidget {
  const CreateDemarchePersonnaliseeStep2Page(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  State<CreateDemarchePersonnaliseeStep2Page> createState() => _CreateDemarchePersonnaliseeStep2PageState();
}

class _CreateDemarchePersonnaliseeStep2PageState extends State<CreateDemarchePersonnaliseeStep2Page> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.personnaliseeStep2ViewModel.description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrInput(
            label: Strings.descriptionDemarchePersonnaliseeLabel,
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            inputFormatters: [LengthLimitingTextInputFormatter(CreateDemarchePersonnaliseeStep2ViewModel.maxLength)],
            onChanged: (value) => widget.viewModel.descriptionChanged(value),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: Strings.continueLabel,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.md,
            onPressed: widget.viewModel.isDescriptionValid
                ? widget.viewModel.navigateToCreateDemarchePersonnaliseeStep3
                : null,
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
