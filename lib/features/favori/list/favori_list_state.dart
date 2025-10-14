import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/favori.dart';

abstract class FavoriListState extends Equatable {
  @override
  List<Object?> get props => [];

  Favori? favoriOrNull(String offreId) {
    if (this is! FavoriListSuccessState) {
      return null;
    }

    return (this as FavoriListSuccessState).results.firstWhereOrNull((favori) => favori.id == offreId);
  }

  List<String> nonPostuledOffreIdsAfter(Duration duration) {
    if (this is! FavoriListSuccessState) {
      return [];
    }

    return (this as FavoriListSuccessState)
        .results
        .where((favori) {
          final isPostulated = favori.datePostulation != null;
          final dateCreationOffset = favori.dateDeCreation.add(duration);
          final isBeforeNow = dateCreationOffset.isBefore(DateTime.now());
          return !isPostulated && isBeforeNow;
        })
        .map((favori) => favori.id)
        .toList();
  }

  bool isFavoriNonPostule(String offreId) {
    if (this is! FavoriListSuccessState) {
      return false;
    }

    return favoriOrNull(offreId)?.datePostulation == null;
  }
}

class FavoriListNotInitializedState extends FavoriListState {}

class FavoriListLoadingState extends FavoriListState {}

class FavoriListFailureState extends FavoriListState {}

class FavoriListSuccessState extends FavoriListState {
  final List<Favori> results;

  FavoriListSuccessState(this.results);

  @override
  List<Object?> get props => [results];
}
