import 'package:equatable/equatable.dart';

sealed class InvitePrenomState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InvitePrenomNotInitializedState extends InvitePrenomState {}

class InvitePrenomLoadingState extends InvitePrenomState {}

class InvitePrenomFailureState extends InvitePrenomState {}

class InvitePrenomSuccessState extends InvitePrenomState {
  final String prenom;

  InvitePrenomSuccessState(this.prenom);

  @override
  List<Object?> get props => [prenom];
}

/// Prénom mis à jour avec succès. Le parcours invité s'arrête ici pour le
/// moment : la suite des écrans reste à développer.
class InvitePrenomUpdatedState extends InvitePrenomState {
  final String prenom;

  InvitePrenomUpdatedState(this.prenom);

  @override
  List<Object?> get props => [prenom];
}

class InvitePrenomUpdateFailureState extends InvitePrenomState {
  final String prenom;

  InvitePrenomUpdateFailureState(this.prenom);

  @override
  List<Object?> get props => [prenom];
}
