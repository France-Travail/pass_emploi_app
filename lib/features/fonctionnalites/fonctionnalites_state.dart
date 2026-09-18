import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/fonctionnalite.dart';

sealed class FonctionnalitesState extends Equatable {
  Set<Fonctionnalite> get actives => const {};

  bool get isResolved => true;

  @override
  List<Object?> get props => [];
}

class FonctionnalitesNotInitializedState extends FonctionnalitesState {
  @override
  bool get isResolved => false;
}

class FonctionnalitesLoadingState extends FonctionnalitesState {
  @override
  bool get isResolved => false;
}

class FonctionnalitesFailureState extends FonctionnalitesState {}

class FonctionnalitesSuccessState extends FonctionnalitesState {
  @override
  final Set<Fonctionnalite> actives;

  FonctionnalitesSuccessState(this.actives);

  @override
  List<Object?> get props => [actives];
}
