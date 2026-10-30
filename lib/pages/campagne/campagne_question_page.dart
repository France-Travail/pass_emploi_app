import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/campagne.dart';
import 'package:pass_emploi_app/pages/generic_success_page.dart';
import 'package:pass_emploi_app/presentation/question_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/radio_list_tile.dart';

const maxAnswerLength = 255;

class CampagneQuestionPage extends StatefulWidget {
  final int questionOffset;

  CampagneQuestionPage._(this.questionOffset) : super();

  static MaterialPageRoute<void> materialPageRoute(int questionOffset) {
    return MaterialPageRoute(builder: (context) => CampagneQuestionPage._(questionOffset));
  }

  @override
  State<CampagneQuestionPage> createState() => _CampagneQuestionPageState();
}

class _CampagneQuestionPageState extends State<CampagneQuestionPage> {
  int? _answerId;
  String? _pourquoi;
  final GlobalKey _textFieldKey = GlobalKey();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(_onTextFieldFocusChange);
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  void _onTextFieldFocusChange() {
    if (!_textFieldFocusNode.hasFocus) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      final textFieldContext = _textFieldKey.currentContext;
      if (textFieldContext != null && textFieldContext.mounted) Scrollable.ensureVisible(textFieldContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, QuestionPageViewModel>(
      converter: (store) => QuestionPageViewModel.create(store, widget.questionOffset),
      builder: (context, viewModel) => _scaffold(context, viewModel),
      distinct: true,
    );
  }

  Widget _scaffold(BuildContext context, QuestionPageViewModel viewModel) {
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: SecondaryAppBar(title: viewModel.titre, backgroundColor: backgroundColor),
      body: _content(viewModel),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: SizedBox(
          width: double.infinity,
          child: DsfrButton(
            onPressed: _answerId != null ? () => onButtonPressed(viewModel) : null,
            label: viewModel.bottomButton == QuestionBottomButton.next
                ? Strings.nextButtonTitle
                : Strings.validateButtonTitle,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _content(QuestionPageViewModel viewModel) {
    final pourquoiLength = _pourquoi?.length ?? 0;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(Strings.mandatory, style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context))),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(viewModel.question, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
            const SizedBox(height: DsfrSpacings.s2w),
            _answerOptions(viewModel.options),
            const SizedBox(height: DsfrSpacings.s4w),
            DsfrInput(
              key: _textFieldKey,
              label: Strings.pourquoiTitle,
              placeholder: Strings.pourquoiHintText,
              focusNode: _textFieldFocusNode,
              onChanged: (value) {
                Scrollable.ensureVisible(_textFieldKey.currentContext!);

                setState(() => _pourquoi = value);
              },
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 8,
              // Pas de maxLength : rendu DSFR cassé, voir https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
              inputFormatters: [LengthLimitingTextInputFormatter(maxAnswerLength)],
              componentState: pourquoiLength >= maxAnswerLength
                  ? DsfrComponentState.error(errorMessage: Strings.fieldMaxLengthExceeded(maxAnswerLength))
                  : const DsfrComponentState.none(),
            ),
            const SizedBox(height: DsfrSpacings.s1v),
            ExcludeSemantics(
              child: Text(
                '$pourquoiLength/$maxAnswerLength',
                textAlign: TextAlign.end,
                style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
              ),
            ),
            SizedBox(height: Margins.spacing_x_huge * 2),
          ],
        ),
      ),
    );
  }

  void onButtonPressed(QuestionPageViewModel viewModel) {
    submitAnswer(viewModel);
    if (viewModel.bottomButton == QuestionBottomButton.next) {
      Navigator.push(context, CampagneQuestionPage.materialPageRoute(widget.questionOffset + 1));
    } else {
      Navigator.of(context).popAll();
      Navigator.push(context, GenericSuccessPage.route(title: Strings.evaluationSuccessfullySent));
    }
  }

  void submitAnswer(QuestionPageViewModel viewModel) {
    viewModel.onButtonClick(viewModel.idQuestion, _answerId!, _pourquoi);
  }

  Widget _answerOptions(List<Option> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options
          .map(
            (option) => CustomRadioGroup<int>(
              title: option.libelle,
              value: option.id,
              groupValue: _answerId,
              onChanged: (value) {
                setState(() {
                  _answerId = value;
                });
              },
            ),
          )
          .toList(),
    );
  }
}
