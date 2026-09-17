import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_state.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/create_demarche_success_page.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_step3_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_creation_state.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_source.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_selectable_card.dart';
import 'package:redux/redux.dart';

class CreateDemarcheDuReferentielForm extends StatefulWidget {
  const CreateDemarcheDuReferentielForm({
    required this.idDemarche,
    required this.source,
    required this.createDemarcheButtonLabel,
    this.onCreateDemarcheSuccess,
    this.initialCodeComment,
  });

  final String idDemarche;
  final DemarcheSource source;
  final String? initialCodeComment;
  final String createDemarcheButtonLabel;
  final void Function(String demarcheCreatedId)? onCreateDemarcheSuccess;

  @override
  State<CreateDemarcheDuReferentielForm> createState() => _CreateDemarcheDuReferentielFormState();
}

class _CreateDemarcheDuReferentielFormState extends State<CreateDemarcheDuReferentielForm> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CreateDemarcheStep3ViewModel>(
      builder: (_, viewModel) => _Form(
        viewModel,
        widget.source,
        initialCodeComment: widget.initialCodeComment,
        createDemarcheButtonLabel: widget.createDemarcheButtonLabel,
      ),
      converter: (store) => CreateDemarcheStep3ViewModel.create(store, widget.idDemarche, widget.source),
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

  void _onDidChange(CreateDemarcheStep3ViewModel? _, CreateDemarcheStep3ViewModel newVm) {
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
      widget.onCreateDemarcheSuccess?.call(demarcheId);
      Navigator.of(context).popAll();
      Navigator.of(context).push(CreateDemarcheSuccessPage.route(CreateDemarcheSource.fromReferentiel));
    });
  }
}

class _Form extends StatefulWidget {
  const _Form(this.viewModel, this.source, {this.initialCodeComment, required this.createDemarcheButtonLabel});

  final DemarcheSource source;
  final String? initialCodeComment;
  final String createDemarcheButtonLabel;
  final CreateDemarcheStep3ViewModel viewModel;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  String? _codeComment;
  DateTime? _endDate;
  DateInputSource _dateSource = DateNotInitialized();

  @override
  void initState() {
    _codeComment = widget.initialCodeComment ?? widget.viewModel.comments.firstOrNull?.code;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.demarcheCreationState is DemarcheCreationSuccessState) {
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DsfrSpacings.s2w),
          Semantics(
            header: true,
            child: Text(
              widget.viewModel.quoi,
              style: DsfrTextStyle.bodyLg(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          if (widget.viewModel.isCommentMandatory) ...[
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              Strings.allMandatoryFields,
              style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
          ],
          if (widget.viewModel.comments.isNotEmpty) ...[
            const SizedBox(height: DsfrSpacings.s3w),
            Text(
              Strings.comment,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            if (widget.viewModel.isCommentMandatory) ...[
              const SizedBox(height: DsfrSpacings.s1w),
              Text(
                Strings.selectComment,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
              ),
            ],
            const SizedBox(height: DsfrSpacings.s2w),
            _Comments(
              widget.viewModel.comments,
              _codeComment,
              (codeComment) => setState(() => _codeComment = codeComment),
            ),
          ],
          const SizedBox(height: DsfrSpacings.s3w),
          Text(
            Strings.quand,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrDateInputSuggestions(
            label: Strings.selectQuand,
            dateSource: _dateSource,
            onDateChanged: (dateSource) {
              setState(() {
                _dateSource = dateSource;
                _endDate = dateSource.isValid ? dateSource.selectedDate : null;
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
              label: widget.createDemarcheButtonLabel,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: _buttonIsActive(widget.viewModel)
                  ? () => widget.viewModel.onCreateDemarche(_codeComment, _endDate!)
                  : null,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
      ),
    );
  }

  bool _buttonIsActive(CreateDemarcheStep3ViewModel viewModel) {
    return viewModel.displayState != DisplayState.LOADING &&
        _endDate != null &&
        (_codeComment != null || !viewModel.isCommentMandatory);
  }
}

class _Comments extends StatelessWidget {
  const _Comments(this.comments, this.codeComment, this.onCommentSelected);

  final List<CommentItem> comments;
  final String? codeComment;
  final void Function(String? codeComment) onCommentSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: comments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: DsfrSpacings.s2w),
      itemBuilder: (context, index) {
        final comment = comments[index];
        if (comment is CommentTextItem) {
          return Text(
            comment.label,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          );
        }
        return DsfrSelectableCard(
          label: comment.label,
          selected: codeComment == comment.code,
          onTap: () => onCommentSelected(comment.code),
        );
      },
    );
  }
}
