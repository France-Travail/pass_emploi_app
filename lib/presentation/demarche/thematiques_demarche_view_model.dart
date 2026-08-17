import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/features/thematiques_demarche/thematiques_demarche_actions.dart';
import 'package:pass_emploi_app/features/thematiques_demarche/thematiques_demarche_state.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class ThematiqueDemarchePageViewModel extends Equatable {
  final DisplayState displayState;
  final List<ThematiqueDemarcheItem> thematiques;
  final void Function() onRetry;

  ThematiqueDemarchePageViewModel({required this.displayState, required this.thematiques, required this.onRetry});

  factory ThematiqueDemarchePageViewModel.create(Store<AppState> store) {
    final state = store.state.thematiquesDemarcheState;
    return ThematiqueDemarchePageViewModel(
      displayState: _displayState(state),
      thematiques: _thematiques(state),
      onRetry: () => store.dispatch(ThematiqueDemarcheRequestAction()),
    );
  }

  @override
  List<Object?> get props => [displayState, thematiques];
}

List<ThematiqueDemarcheItem> _thematiques(ThematiqueDemarcheState state) {
  if (state is ThematiqueDemarcheSuccessState) {
    final thematiques = state.thematiques
        .where((e) => e.demarches.isNotEmpty)
        .map((e) => ThematiqueDemarcheItem(id: e.code, title: e.libelle))
        .toList();

    final order = [
      "Mon (nouveau) métier",
      "Ma formation professionnelle",
      "Mes candidatures",
      "Mes entretiens d'embauche",
      "Ma création ou reprise d'entreprise",
      "Mes contraintes personnelles",
      "Mes entretiens avec un conseiller"
    ];

    thematiques.sort((a, b) => order.indexOf(a.title).compareTo(order.indexOf(b.title)));
    return thematiques;
  } else {
    return <ThematiqueDemarcheItem>[];
  }
}

DisplayState _displayState(ThematiqueDemarcheState state) {
  return switch (state) {
    ThematiqueDemarcheFailureState() => DisplayState.FAILURE,
    ThematiqueDemarcheSuccessState() => DisplayState.CONTENT,
    _ => DisplayState.LOADING,
  };
}

class ThematiqueDemarcheItem extends Equatable {
  final String id;
  final String title;
  final String emoji;
  final Color emojiBackground;

  ThematiqueDemarcheItem({required this.id, required this.title})
      : emoji = switch (title) {
          "Mon (nouveau) métier" => '💼',
          "Ma formation professionnelle" => '🎓',
          "Mes candidatures" => '📝️',
          "Mes entretiens d'embauche" => '🧑‍💼',
          "Ma création ou reprise d'entreprise" => '🚀',
          "Mes contraintes personnelles" => '⛑️',
          "Mes entretiens avec un conseiller" => '👥',
          _ => '📋',
        },
        emojiBackground = switch (title) {
          "Mon (nouveau) métier" => DsfrColors.success950,
          "Ma formation professionnelle" => DsfrColors.blueCumulus950,
          "Mes candidatures" => DsfrColors.pinkTuile925,
          "Mes entretiens d'embauche" => DsfrColors.greenTilleulVerveine950,
          "Ma création ou reprise d'entreprise" => DsfrColors.greenMenthe950,
          "Mes contraintes personnelles" => DsfrColors.brownCaramel950,
          "Mes entretiens avec un conseiller" => DsfrColors.purpleGlycine925,
          _ => DsfrColors.blueCumulus950,
        };

  @override
  List<Object?> get props => [id, title];
}
