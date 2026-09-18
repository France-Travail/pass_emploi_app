import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/iterable_extensions.dart';
import 'package:redux/redux.dart';

class MotsClesViewModel extends Equatable {
  final List<MotsClesItem> motsCles;
  final bool containsMotsClesRecents;

  MotsClesViewModel({
    required this.motsCles,
    required this.containsMotsClesRecents,
  });

  factory MotsClesViewModel.create(Store<AppState> store) {
    final motsClesFromRechercheRecentes = _motsClesFromRechercheRecentes(store);
    return MotsClesViewModel(
      motsCles: motsClesFromRechercheRecentes,
      containsMotsClesRecents: motsClesFromRechercheRecentes.isNotEmpty,
    );
  }

  @override
  List<Object?> get props => [motsCles, containsMotsClesRecents];
}

abstract class MotsClesItem extends Equatable {}

class MotsClesTitleItem extends MotsClesItem {
  final String title;

  MotsClesTitleItem(this.title);

  @override
  List<Object?> get props => [title];
}

class MotsClesSuggestionItem extends MotsClesItem {
  final String text;
  final MotCleSource source;

  MotsClesSuggestionItem(this.text, this.source);

  @override
  List<Object?> get props => [text, source];
}

enum MotCleSource { dernieresRecherches }

List<MotsClesItem> _motsClesFromRechercheRecentes(Store<AppState> store) {
  final motCles = _derniersMotsCles(store);
  if (motCles.isEmpty) return [];
  final title = motCles.length == 1 ? Strings.derniereRecherche : Strings.dernieresRecherches;
  return [MotsClesTitleItem(title), ...motCles.map((e) => MotsClesSuggestionItem(e, MotCleSource.dernieresRecherches))];
}

List<String> _derniersMotsCles(Store<AppState> store) {
  return store.state.recherchesRecentesState.recentSearches
      .whereType<OffreEmploiAlerte>()
      .map((offre) => offre.keyword)
      .nonNulls
      .whereNot((keyword) => keyword.isEmpty)
      .distinct()
      .take(3)
      .toList();
}
