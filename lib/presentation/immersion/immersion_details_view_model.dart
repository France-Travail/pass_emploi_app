import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/date_consultation_offre/date_derniere_consultation_store_extension.dart';
import 'package:pass_emploi_app/features/immersion/details/immersion_details_actions.dart';
import 'package:pass_emploi_app/features/immersion/details/immersion_details_state.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/models/immersion_details.dart';
import 'package:pass_emploi_app/presentation/call_to_action.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:redux/redux.dart';

enum ImmersionDetailsPageDisplayState { SHOW_DETAILS, SHOW_INCOMPLETE_DETAILS, SHOW_LOADER, SHOW_ERROR }

class ImmersionDetailsViewModel extends Equatable {
  final ImmersionDetailsPageDisplayState displayState;
  final String id;
  final String title;
  final String companyName;
  final String secteurActivite;
  final DateTime? dateDerniereConsultation;
  final bool fitForDisabledWorkers;
  final String ville;
  final String? address;
  final String? informationComplementaire;
  final String? website;
  final String? contactInformation;
  final bool? withSecondaryCallToActions;
  final ImmersionContactMode contactMode;
  final ImmersionModeDistanciel? modeDistanciel;
  final List<CallToAction>? secondaryCallToActions;
  final Function(String immersionId) onRetry;
  final bool isNotFound;

  ImmersionDetailsViewModel._({
    required this.displayState,
    required this.id,
    required this.title,
    required this.companyName,
    required this.secteurActivite,
    this.dateDerniereConsultation,
    required this.fitForDisabledWorkers,
    required this.ville,
    this.address,
    this.informationComplementaire,
    this.website,
    this.contactInformation,
    this.withSecondaryCallToActions,
    required this.contactMode,
    this.modeDistanciel,
    this.secondaryCallToActions,
    required this.onRetry,
    this.isNotFound = false,
  });

  factory ImmersionDetailsViewModel.create(Store<AppState> store, Platform platform) {
    final state = store.state.immersionDetailsState;
    if (state is ImmersionDetailsSuccessState) {
      final immersionDetails = state.immersion;
      return _successViewModel(
        state,
        immersionDetails,
        [],
        store,
        true,
        store.getOffreDateDerniereConsultationOrNull(immersionDetails.id),
      );
    } else if (state is ImmersionDetailsIncompleteDataState) {
      final immersion = state.immersion;
      return _incompleteViewModel(immersion, store, store.getOffreDateDerniereConsultationOrNull(immersion.id));
    } else {
      return _viewModelForNotFound(state, store);
    }
  }

  @override
  List<Object?> get props => [
    displayState,
    id,
    title,
    companyName,
    secteurActivite,
    ville,
    address,
    informationComplementaire,
    website,
    contactInformation,
    contactMode,
    modeDistanciel,
    secondaryCallToActions,
    isNotFound,
  ];
}

ImmersionDetailsPageDisplayState _displayState(ImmersionDetailsState state) {
  if (state is ImmersionDetailsSuccessState) {
    return ImmersionDetailsPageDisplayState.SHOW_DETAILS;
  } else if (state is ImmersionDetailsLoadingState) {
    return ImmersionDetailsPageDisplayState.SHOW_LOADER;
  } else {
    return ImmersionDetailsPageDisplayState.SHOW_ERROR;
  }
}

ImmersionDetailsViewModel _successViewModel(
  ImmersionDetailsState state,
  ImmersionDetails immersionDetails,
  List<CallToAction> secondaryCallToActions,
  Store<AppState> store,
  bool withContactForm,
  DateTime? dateDerniereConsultation,
) {
  return ImmersionDetailsViewModel._(
    displayState: _displayState(state),
    id: immersionDetails.id,
    title: immersionDetails.metier,
    companyName: immersionDetails.companyName,
    secteurActivite: immersionDetails.secteurActivite,
    dateDerniereConsultation: dateDerniereConsultation,
    fitForDisabledWorkers: immersionDetails.fitForDisabledWorkers,
    ville: immersionDetails.ville,
    address: immersionDetails.address,
    informationComplementaire: immersionDetails.informationComplementaire,
    website: immersionDetails.website,
    contactInformation: immersionDetails.address,
    withSecondaryCallToActions: secondaryCallToActions.isNotEmpty,
    secondaryCallToActions: secondaryCallToActions,
    onRetry: (immersionId) => _retry(store, immersionId),
    contactMode: immersionDetails.contactMode,
    modeDistanciel: immersionDetails.modeDistanciel,
  );
}

ImmersionDetailsViewModel _incompleteViewModel(
  Immersion immersion,
  Store<AppState> store,
  DateTime? dateDerniereConsultation,
) {
  return ImmersionDetailsViewModel._(
    displayState: ImmersionDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS,
    id: immersion.id,
    title: immersion.metier,
    companyName: immersion.nomEtablissement,
    secteurActivite: immersion.secteurActivite,
    dateDerniereConsultation: dateDerniereConsultation,
    fitForDisabledWorkers: immersion.fitForDisabledWorkers,
    ville: immersion.ville,
    onRetry: (immersionId) => _retry(store, immersionId),
    contactMode: ImmersionContactMode.INCONNU,
  );
}

ImmersionDetailsViewModel _viewModelForNotFound(ImmersionDetailsState state, Store<AppState> store) {
  return ImmersionDetailsViewModel._(
    displayState: _displayState(state),
    id: "",
    title: "",
    companyName: "",
    secteurActivite: "",
    fitForDisabledWorkers: false,
    ville: "",
    onRetry: (immersionId) => _retry(store, immersionId),
    isNotFound: true,
    contactMode: ImmersionContactMode.INCONNU,
  );
}

void _retry(Store<AppState> store, String immersionId) => store.dispatch(ImmersionDetailsRequestAction(immersionId));
