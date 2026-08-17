import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/thematiques_demarche/thematiques_demarche_actions.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_from_referentiel_step_3_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_step3_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_selectable_card.dart';

class CreateDemarcheFromThematiqueStep3Page extends StatelessWidget {
  const CreateDemarcheFromThematiqueStep3Page(this.formVm);
  final CreateDemarcheFormChangeNotifier formVm;

  @override
  Widget build(BuildContext context) {
    final selectedThematique = formVm.step1ViewModel.selectedThematique;

    final selectedDemarche = formVm.thematiqueStep2ViewModel.selectedDemarcheVm;

    if (selectedThematique == null || selectedDemarche == null) {
      return const SizedBox();
    }

    return StoreConnector<AppState, CreateDemarcheFromReferentielStep3ViewModel>(
      onInit: (store) => store.dispatch(ThematiqueDemarcheRequestAction()),
      converter: (store) =>
          CreateDemarcheFromReferentielStep3ViewModel.create(store, selectedDemarche.idDemarche, selectedThematique.id),
      builder: (context, storeVm) => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DsfrSpacings.s1w),
                Text(
                  selectedDemarche.quoi,
                  style: DsfrTextStyle.bodyLg(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                Text(
                  Strings.allMandatoryFields,
                  style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
                ),
                const SizedBox(height: DsfrSpacings.s3w),
                DsfrDateInputSuggestions(
                  label: Strings.thematiquesDemarcheDateShort,
                  dateSource: formVm.fromThematiqueStep3ViewModel.dateSource,
                  onDateChanged: (date) {
                    formVm.dateDemarcheThematiqueChanged(date);
                    if (!date.isNone) {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (context.mounted) FocusScope.of(context).nextFocus();
                      });
                    }
                  },
                ),
                if (storeVm.isCommentMandatory) ...[
                  const SizedBox(height: DsfrSpacings.s3w),
                  Text(
                    Strings.selectMoyen,
                    style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  _MoyensList(
                    storeVm: storeVm,
                    onCommentSelected: (comment) => formVm.commentChanged(comment),
                    selectedComment: formVm.fromThematiqueStep3ViewModel.commentItem,
                  ),
                ],
                const SizedBox(height: DsfrSpacings.s8w),
              ],
            ),
          ),
          if (formVm.fromThematiqueStep3ViewModel.isValid(storeVm.isCommentMandatory))
            Align(
              alignment: Alignment.bottomCenter,
              child: ColoredBox(
                color: DsfrColorDecisions.backgroundDefaultGrey(context),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: DsfrSpacings.s2w,
                    left: DsfrSpacings.s2w,
                    right: DsfrSpacings.s2w,
                    bottom: MediaQuery.of(context).padding.bottom + DsfrSpacings.s2w,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DsfrButton(
                      label: Strings.validateLaDemarche,
                      variant: DsfrButtonVariant.primary,
                      size: DsfrComponentSize.md,
                      onPressed: () => formVm.submitDemarcheThematique(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoyensList extends StatelessWidget {
  const _MoyensList({required this.storeVm, required this.onCommentSelected, this.selectedComment});
  final CreateDemarcheFromReferentielStep3ViewModel storeVm;
  final CommentItem? selectedComment;
  final void Function(CommentItem) onCommentSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: storeVm.comments.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: DsfrSpacings.s2w),
      itemBuilder: (context, index) {
        final moyen = storeVm.comments[index];
        return DsfrSelectableCard(
          label: moyen.label,
          selected: moyen == selectedComment,
          onTap: () => onCommentSelected(moyen),
        );
      },
    );
  }
}
