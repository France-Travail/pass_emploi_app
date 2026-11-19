import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/models/suggestion_recherche.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/romeo_simule.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Ordre de priorité quand deux pistes ont autant de raisons : ce que dit le conseiller passe d'abord.
enum SourcePiste {
  conseiller,
  franceTravail,
  parcoursFranceTravail,
  questionnaire,
  test,
  centresInteret,
  favori,
  recherche,
  diagoriente,
  metierProche,
}

class RaisonProposition extends Equatable {
  const RaisonProposition(this.source, this.texte);

  final SourcePiste source;
  final String texte;

  @override
  List<Object?> get props => [source, texte];
}

class PisteProposee extends Equatable {
  const PisteProposee(this.metier, this.raisons);

  final RomeMetierResume metier;
  final List<RaisonProposition> raisons;

  @override
  List<Object?> get props => [metier, raisons];
}

const _typesMetier = {OffreType.emploi, OffreType.alternance, OffreType.immersion};

// « Des métiers pour toi », la liste à trier : tout ce que l'app sait du jeune (son activité, son conseiller, son test,
// ses centres d'intérêt, les voisins de ses pistes), chaque métier avec ses raisons. Un métier déjà trié (dans ses pistes
// ou mis de côté) n'est plus proposé.
List<PisteProposee> proposerDesPistes(ContexteJeune contexte, MesPistesEtat mesPistes, {MarcheTravail? marche}) {
  final metiers = <String, RomeMetierResume>{};
  final raisons = <String, Map<SourcePiste, List<String>>>{};

  void ajouter(RomeMetierResume? metier, SourcePiste source, String detail) {
    if (metier == null) return;
    metiers.putIfAbsent(metier.code, () => metier);
    raisons.putIfAbsent(metier.code, () => {}).putIfAbsent(source, () => []).add(detail);
  }

  final questionnaire = contexte.questionnaire;
  final domaine = questionnaire?.domaine?.trim();
  if (questionnaire != null && !questionnaire.domaineInconnu && domaine != null && domaine.isNotEmpty) {
    ajouter(romeoSimule(domaine), SourcePiste.questionnaire, domaine);
  }
  for (final suggestion in contexte.suggestions.where((suggestion) => _typesMetier.contains(suggestion.type))) {
    final source = switch (suggestion.source) {
      SuggestionSource.conseiller => SourcePiste.conseiller,
      SuggestionSource.poleEmploi => SourcePiste.franceTravail,
      SuggestionSource.diagoriente => SourcePiste.diagoriente,
      null => null,
    };
    if (source != null) ajouter(romeoSimule(suggestion.metier ?? suggestion.titre), source, suggestion.titre);
  }
  for (final ajout in mesPistes.ajouts) {
    ajouter(ajout.metier, switch (ajout.source) {
      SourceAjout.test => SourcePiste.test,
      SourceAjout.centresInteret => SourcePiste.centresInteret,
    }, ajout.detail);
  }
  for (final experience in contexte.experiencesFranceTravail) {
    ajouter(
      metierConnu(experience.codeRome, libelle: experience.libelleRome),
      SourcePiste.parcoursFranceTravail,
      PocOrientationStrings.raisonParcoursDetail(experience.intitule, experience.dureeMois),
    );
  }
  for (final favori in contexte.favoris.where((favori) => _typesMetier.contains(favori.type))) {
    ajouter(romeoSimule(favori.titre), SourcePiste.favori, favori.titre);
  }
  for (final alerte in contexte.alertes) {
    final metier = switch (alerte) {
      ImmersionAlerte() => metierConnu(alerte.codeRome, libelle: alerte.metier),
      OffreEmploiAlerte() => romeoSimule(alerte.metier ?? alerte.keyword ?? alerte.title),
      _ => null,
    };
    ajouter(metier, SourcePiste.recherche, alerte.getTitle());
  }
  for (final piste in mesPistes.quiTentent) {
    for (final proche in marche?.metiersProches[piste.code] ?? const <RomeMetierResume>[]) {
      ajouter(proche, SourcePiste.metierProche, piste.metier.libelle);
    }
  }

  final proposees = [
    for (final entree in metiers.entries)
      if (mesPistes.piste(entree.key) == null)
        PisteProposee(entree.value, [
          for (final source in SourcePiste.values)
            if (raisons[entree.key]![source] case final details?) RaisonProposition(source, _texte(source, details)),
        ]),
  ];
  return proposees..sort((a, b) {
    final nombre = b.raisons.length.compareTo(a.raisons.length);
    if (nombre != 0) return nombre;
    final priorite = a.raisons.first.source.index.compareTo(b.raisons.first.source.index);
    return priorite != 0 ? priorite : a.metier.libelle.compareTo(b.metier.libelle);
  });
}

String _texte(SourcePiste source, List<String> details) => switch (source) {
  SourcePiste.conseiller => PocOrientationStrings.raisonConseiller,
  SourcePiste.franceTravail => PocOrientationStrings.raisonFranceTravail,
  SourcePiste.parcoursFranceTravail => PocOrientationStrings.raisonParcours(details.first),
  SourcePiste.questionnaire => PocOrientationStrings.raisonQuestionnaire(details.first),
  SourcePiste.test => PocOrientationStrings.raisonTest(details.first),
  SourcePiste.centresInteret => PocOrientationStrings.raisonCentres,
  SourcePiste.favori => PocOrientationStrings.raisonFavori(details.length),
  SourcePiste.recherche => PocOrientationStrings.raisonRecherche(details.length),
  SourcePiste.diagoriente => PocOrientationStrings.raisonDiagoriente,
  SourcePiste.metierProche => PocOrientationStrings.raisonProche(details.toSet().join(" et ")),
};
