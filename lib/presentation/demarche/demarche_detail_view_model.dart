import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/demarche/update/update_demarche_actions.dart';
import 'package:pass_emploi_app/features/demarche/update/update_demarche_state.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_state.dart';
import 'package:pass_emploi_app/models/demarche.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_card_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_store_extension.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/model/formatted_text.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_pillule.dart';
import 'package:redux/redux.dart';

class DemarcheDetailViewModel extends Equatable {
  final bool createdByAdvisor;
  final bool modifiedByAdvisor;
  final bool withOfflineBehavior;
  final List<FormattedText> dateFormattedTexts;
  final String? label;
  final String? titreDetail;
  final String? modificationDate;
  final String? creationDate;
  final String? withDateDerniereMiseAJour;
  final List<String> attributs;
  final bool withDemarcheDoneButton;
  final Function() resetUpdateStatus;
  final DisplayState updateDisplayState;
  final CardPilluleType? pillule;
  final String? promptIa;

  DemarcheDetailViewModel({
    required this.createdByAdvisor,
    required this.modifiedByAdvisor,
    required this.withOfflineBehavior,
    required this.dateFormattedTexts,
    required this.label,
    required this.titreDetail,
    required this.attributs,
    required this.modificationDate,
    required this.creationDate,
    required this.withDateDerniereMiseAJour,
    required this.withDemarcheDoneButton,
    required this.resetUpdateStatus,
    required this.updateDisplayState,
    required this.pillule,
    required this.promptIa,
  });

  factory DemarcheDetailViewModel.create(Store<AppState> store, String demarcheId) {
    final demarche = store.getDemarcheOrNull(demarcheId);

    if (demarche == null) {
      return DemarcheDetailViewModel.empty();
    }

    final dateDerniereMiseAJour = _getDateDerniereMiseAJour(store);
    demarche.possibleStatus.sort((a, b) => a.compareTo(b));
    final updateState = store.state.updateDemarcheState;
    return DemarcheDetailViewModel(
      createdByAdvisor: demarche.createdByAdvisor,
      modifiedByAdvisor: demarche.modifiedByAdvisor,
      withOfflineBehavior: store.state.connectivityState.isOffline(),
      dateFormattedTexts: _formattedDate(demarche),
      label: demarche.label,
      titreDetail: demarche.titre,
      attributs: demarche.attributs.map((e) => e.value).toList(),
      modificationDate: demarche.modificationDate?.toDay(),
      creationDate: demarche.creationDate?.toDay(),
      withDateDerniereMiseAJour: _withDateDerniereMiseAJour(dateDerniereMiseAJour),
      withDemarcheDoneButton: demarche.possibleStatus.contains(DemarcheStatus.DONE),
      resetUpdateStatus: () => store.dispatch(UpdateDemarcheResetAction()),
      updateDisplayState: _updateStateDisplayState(updateState),
      pillule: demarche.pillule(),
      promptIa: demarche.promptIa,
    );
  }

  factory DemarcheDetailViewModel.empty() {
    return DemarcheDetailViewModel(
      createdByAdvisor: false,
      modifiedByAdvisor: false,
      withOfflineBehavior: false,
      dateFormattedTexts: [],
      label: null,
      titreDetail: null,
      attributs: [],
      modificationDate: null,
      creationDate: null,
      withDateDerniereMiseAJour: null,
      withDemarcheDoneButton: false,
      resetUpdateStatus: () {},
      updateDisplayState: DisplayState.EMPTY,
      pillule: null,
      promptIa: null,
    );
  }

  @override
  List<Object?> get props => [
    createdByAdvisor,
    modifiedByAdvisor,
    withOfflineBehavior,
    dateFormattedTexts,
    dateFormattedTexts,
    label,
    titreDetail,
    modificationDate,
    creationDate,
    withDateDerniereMiseAJour,
    attributs,
    withDemarcheDoneButton,
    updateDisplayState,
    pillule,
    promptIa,
  ];
}

DateTime? _getDateDerniereMiseAJour(Store<AppState> store) {
  if (store.state.monSuiviState is MonSuiviSuccessState) {
    return (store.state.monSuiviState as MonSuiviSuccessState).monSuivi.dateDerniereMiseAJourPoleEmploi;
  }
  return null;
}

String? _withDateDerniereMiseAJour(DateTime? dateDerniereMiseAJour) {
  if (dateDerniereMiseAJour == null) return null;
  return Strings.dateDerniereMiseAJourDemarches(dateDerniereMiseAJour.toDayAndHour());
}

List<FormattedText> _formattedDate(Demarche demarche) {
  if (demarche.status == DemarcheStatus.CANCELLED && demarche.deletionDate != null) {
    return [
      FormattedText(Strings.demarcheCancelledLabel),
      FormattedText(demarche.deletionDate!.toDay(), bold: true),
    ];
  } else if (demarche.status == DemarcheStatus.DONE && demarche.endDate != null) {
    return [
      FormattedText(Strings.demarcheDoneLabel),
      FormattedText(demarche.endDate!.toDay(), bold: true),
    ];
  } else if (demarche.endDate != null) {
    return [
      FormattedText(Strings.demarcheActiveLabel),
      FormattedText(demarche.endDate!.toDay(), bold: true),
    ];
  } else {
    return [FormattedText(Strings.withoutDate)];
  }
}

DisplayState _updateStateDisplayState(UpdateDemarcheState state) {
  if (state is UpdateDemarcheLoadingState) return DisplayState.LOADING;
  if (state is UpdateDemarcheFailureState) return DisplayState.FAILURE;
  return DisplayState.EMPTY;
}
