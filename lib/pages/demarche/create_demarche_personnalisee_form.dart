import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_state.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/create_demarche_success_page.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_personnalisee_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_creation_state.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';
import 'package:redux/redux.dart';

class DemarchePersonnaliseeForm extends StatefulWidget {
  const DemarchePersonnaliseeForm({
    super.key,
    required this.createDemarcheLabel,
    required this.estDuplicata,
    this.initialCommentaire,
  });

  final String createDemarcheLabel;
  final String? initialCommentaire;
  final bool estDuplicata;

  @override
  State<DemarchePersonnaliseeForm> createState() => _DemarchePersonnaliseeFormState();
}

class _DemarchePersonnaliseeFormState extends State<DemarchePersonnaliseeForm> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CreateDemarchePersonnaliseeViewModel>(
      builder: (_, viewModel) => _Body(
        viewModel: viewModel,
        createDemarcheLabel: widget.createDemarcheLabel,
        initialCommentaire: widget.initialCommentaire,
      ),
      converter: (store) => CreateDemarchePersonnaliseeViewModel.create(store, widget.estDuplicata),
      onDidChange: _onDidChange,
      onInit: _onInit,
      distinct: true,
    );
  }

  void _onInit(Store<AppState> store) {
    final creationState = store.state.createDemarcheState;
    if (creationState is CreateDemarcheSuccessState) {
      _onSuccess(creationState.demarcheCreatedId);
    }
  }

  void _onDidChange(CreateDemarchePersonnaliseeViewModel? _, CreateDemarchePersonnaliseeViewModel newVm) {
    final creationState = newVm.demarcheCreationState;
    if (creationState is DemarcheCreationSuccessState) {
      _onSuccess(creationState.demarcheCreatedId);
    }
  }

  void _onSuccess(String demarcheId) {
    final context = this.context;
    // To avoid poping during the build
    Future.delayed(AnimationDurations.veryFast, () {
      if (!context.mounted) return;
      Navigator.of(context).popAll();
      Navigator.of(context).push(CreateDemarcheSuccessPage.route(CreateDemarcheSource.personnalisee));
    });
  }
}

class _Body extends StatefulWidget {
  final CreateDemarchePersonnaliseeViewModel viewModel;
  final String createDemarcheLabel;
  final String? initialCommentaire;

  const _Body({required this.viewModel, required this.createDemarcheLabel, this.initialCommentaire});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  static const _maxCommentLength = 255;

  late String _commentaire;
  DateTime? _dateEcheance;
  DateInputSource _dateSource = DateNotInitialized();

  @override
  void initState() {
    _commentaire = widget.initialCommentaire ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.demarcheCreationState is DemarcheCreationSuccessState) {
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DsfrSpacings.s2w),
          Semantics(
            header: true,
            child: Text(
              Strings.createDemarcheAppBarTitle,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            Strings.allMandatoryFields,
            style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrInput(
            label: Strings.descriptionDemarche,
            initialValue: widget.initialCommentaire,
            minLines: 4,
            maxLines: 8,
            inputFormatters: [LengthLimitingTextInputFormatter(_maxCommentLength)],
            componentState: !_isCommentaireValid()
                ? DsfrComponentState.error(errorMessage: Strings.addAMessageError)
                : const DsfrComponentState.none(),
            onChanged: (query) => setState(() => _commentaire = query),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          Text(
            Strings.quand,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrDateInputSuggestions(
            label: Strings.selectEcheance,
            dateSource: _dateSource,
            onDateChanged: (dateSource) {
              setState(() {
                _dateSource = dateSource;
                _dateEcheance = dateSource.isValid ? dateSource.selectedDate : null;
              });
            },
          ),
          if (widget.viewModel.displayState == DisplayState.FAILURE) ...[
            const SizedBox(height: DsfrSpacings.s3w),
            DsfrAlert(
              type: DsfrAlertType.error,
              description: DsfrAlertDescriptionText(Strings.genericCreationError),
            ),
          ],
          const SizedBox(height: DsfrSpacings.s3w),
          SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: widget.createDemarcheLabel,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: _buttonShouldBeActive(widget.viewModel)
                  ? () => widget.viewModel.onCreateDemarche(_commentaire, _dateEcheance!)
                  : null,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
      ),
    );
  }

  bool _buttonShouldBeActive(CreateDemarchePersonnaliseeViewModel viewModel) {
    return _isFormValid() && viewModel.displayState != DisplayState.LOADING;
  }

  bool _isCommentaireValid() {
    return _commentaire.length <= _maxCommentLength;
  }

  bool _isFormValid() {
    return _isCommentaireValid() && _commentaire.isNotEmpty && _dateEcheance != null;
  }
}
