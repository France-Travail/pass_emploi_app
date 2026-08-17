import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/thematiques_demarche/thematiques_demarche_actions.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_du_referentiel_card_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_selectable_card.dart';

class CreateDemarcheFromThematiqueStep2Page extends StatelessWidget {
  const CreateDemarcheFromThematiqueStep2Page(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    final selectedThematique = viewModel.step1ViewModel.selectedThematique;

    if (selectedThematique == null) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            Strings.selectDemarche,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          _ThematiqueDemarcheList(
            thematiqueCode: selectedThematique.id,
            viewModel: viewModel,
          ),
          const SizedBox(height: DsfrSpacings.s5w),
        ],
      ),
    );
  }
}

class _ThematiqueDemarcheList extends StatelessWidget {
  const _ThematiqueDemarcheList({required this.thematiqueCode, required this.viewModel});
  final String thematiqueCode;
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    final thematiqueSource = ThematiqueDemarcheSource(thematiqueCode);
    return StoreConnector<AppState, List<String>>(
      onInit: (store) => store.dispatch(ThematiqueDemarcheRequestAction()),
      converter: (store) => thematiqueSource.demarcheList(store).map((demarche) => demarche.id).toList(),
      builder: (context, demarchesIds) => ListView.separated(
        itemCount: demarchesIds.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: DsfrSpacings.s2w),
        itemBuilder: (context, index) {
          final id = demarchesIds[index];
          return _DemarcheDuReferentielCard(
            source: thematiqueSource,
            idDemarche: id,
            onSelected: (demarcheCardViewModel) => viewModel.demarcheSelected(demarcheCardViewModel),
          );
        },
      ),
      distinct: true,
    );
  }
}

class _DemarcheDuReferentielCard extends StatelessWidget {
  final String idDemarche;
  final DemarcheSource source;
  final Function(DemarcheDuReferentielCardViewModel) onSelected;

  const _DemarcheDuReferentielCard({required this.idDemarche, required this.onSelected, required this.source});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DemarcheDuReferentielCardViewModel>(
      builder: _buildBody,
      converter: (store) => DemarcheDuReferentielCardViewModel.create(store, idDemarche, source),
      distinct: true,
    );
  }

  Widget _buildBody(BuildContext context, DemarcheDuReferentielCardViewModel viewModel) {
    return DsfrSelectableCard(
      label: viewModel.quoi,
      onTap: () => onSelected(viewModel),
    );
  }
}
