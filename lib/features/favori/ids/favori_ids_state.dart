import 'package:collection/collection.dart';
import 'package:pass_emploi_app/repositories/favoris/favoris_repository.dart';

abstract class FavoriIdsState<T> {
  FavoriIdsState._();

  factory FavoriIdsState.notInitialized() = FavoriIdsNotInitialized;

  factory FavoriIdsState.success(Set<FavoriDto> favoris) => FavoriIdsSuccessState._(favoris);

  bool contains(String offreId);

  DateTime? datePostulationOf(String offreId);

  bool isFavoriNonPostule(String offreId);

  List<String> get nonPostuledOffreIds;
}

class FavoriIdsSuccessState<T> extends FavoriIdsState<T> {
  final Set<FavoriDto> favoris;

  FavoriIdsSuccessState._(this.favoris) : super._();

  @override
  bool contains(String offreId) => favoris.any((favori) => favori.id == offreId);

  @override
  DateTime? datePostulationOf(String offreId) =>
      favoris.firstWhereOrNull((favori) => favori.id == offreId)?.datePostulation;

  @override
  bool isFavoriNonPostule(String offreId) {
    return contains(offreId) && datePostulationOf(offreId) == null;
  }

  @override
  List<String> get nonPostuledOffreIds =>
      favoris.where((favori) => isFavoriNonPostule(favori.id)).map((favori) => favori.id).toList();
}

class FavoriIdsNotInitialized<T> extends FavoriIdsState<T> {
  FavoriIdsNotInitialized() : super._();

  @override
  bool contains(String offreId) => false;

  @override
  DateTime? datePostulationOf(String offreId) => null;

  @override
  bool isFavoriNonPostule(String offreId) => false;

  @override
  List<String> get nonPostuledOffreIds => [];
}
