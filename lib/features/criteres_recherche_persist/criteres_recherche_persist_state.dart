import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

sealed class CriteresRecherchePersistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CriteresRecherchePersistNotInitializedState extends CriteresRecherchePersistState {}

class CriteresRecherchePersistSuccessState extends CriteresRecherchePersistState {
  final CriteresRechercheUtilisateur criteres;

  CriteresRecherchePersistSuccessState(this.criteres);

  @override
  List<Object?> get props => [criteres];
}

extension AppStateCriteresRecherchePersistExt on Store<AppState> {
  CriteresRechercheUtilisateur get criteresRechercheUtilisateur {
    final state = this.state.criteresRecherchePersistState;
    if (state is CriteresRecherchePersistSuccessState) return state.criteres;
    return CriteresRechercheUtilisateur();
  }

  Location? getLastLocationSelected({bool allowDepartment = false}) {
    final location = criteresRechercheUtilisateur.location;
    if (location?.type == LocationType.DEPARTMENT && !allowDepartment) return null;
    return location;
  }
}
