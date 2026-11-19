import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Le parcours en 3 temps : trouver des idées, faire le tri, avancer sur ses pistes.
enum EtapeParcours { idees, tri, avancer }

// L'accueil met en avant une seule étape :
// - rien à trier et aucune piste : trouver des idées ;
// - des métiers à trier et encore aucune piste : faire le tri ;
// - au moins une piste : avancer. Les métiers qui arrivent ensuite (test, conseiller, voisins d'une piste) sont
//   signalés par un rappel, sans changer d'étape.
EtapeParcours etapeDuParcours({required int aTrier, required int pistes}) {
  if (pistes > 0) return EtapeParcours.avancer;
  if (aTrier > 0) return EtapeParcours.tri;
  return EtapeParcours.idees;
}

class ProchaineEtape {
  const ProchaineEtape(this.piste, this.action);

  final Piste piste;
  final ActionPiste action;
}

// La piste à faire avancer : la plus avancée, puis la plus récente ; null quand toutes les étapes sont faites.
ProchaineEtape? prochaineEtape(MesPistesEtat etat) {
  final pistes = etat.quiTentent;
  final enCours = [
    for (var i = pistes.length - 1; i >= 0; i--)
      if (pistes[i].prochaineAction != null) pistes[i],
  ];
  if (enCours.isEmpty) return null;
  var choisie = enCours.first;
  for (final piste in enCours) {
    if (piste.nombreFaites > choisie.nombreFaites) choisie = piste;
  }
  return ProchaineEtape(choisie, choisie.prochaineAction!);
}

// « tirés de tes favoris, de tes recherches et des conseils de ton conseiller » : les trois premières origines.
String originesDeLaListe(List<PisteProposee> aTrier) {
  final sources = {for (final piste in aTrier) ...piste.raisons.map((raison) => raison.source)}.toList()
    ..sort((a, b) => a.index.compareTo(b.index));
  return PocOrientationStrings.listeNaturelle(sources.take(3).map(PocOrientationStrings.origine).toList());
}

// Quand tous les métiers à trier sont des voisins de pistes aimées : « voisins de Boulanger ». Sinon, rien.
List<String> voisinsDe(List<PisteProposee> aTrier, MesPistesEtat etat, MarcheTravail? marche) {
  if (aTrier.isEmpty || marche == null) return const [];
  final queDesVoisins = aTrier.every(
    (piste) => piste.raisons.every((raison) => raison.source == SourcePiste.metierProche),
  );
  if (!queDesVoisins) return const [];
  final codes = {for (final piste in aTrier) piste.metier.code};
  return [
    for (final piste in etat.quiTentent)
      if ((marche.metiersProches[piste.code] ?? const <RomeMetierResume>[]).any((proche) => codes.contains(proche.code)))
        motCleDuMetier(piste.metier.libelle),
  ];
}

// En entrant dans le tri depuis le test (ou ce que le jeune aime), ses métiers passent devant les autres.
List<PisteProposee> mettreDevant(List<PisteProposee> aTrier, SourcePiste? source) {
  if (source == null) return aTrier;
  bool vient(PisteProposee piste) => piste.raisons.any((raison) => raison.source == source);
  return [...aTrier.where(vient), ...aTrier.where((piste) => !vient(piste))];
}

// Le test et ce que le jeune aime ajoutent chacun au plus 8 métiers au tri.
const metiersAjoutesAuTri = 8;

// Les métiers les plus proches du profil, sans ceux déjà triés (dans les pistes ou mis de côté).
List<RomeMetierResume> metiersDuTest(RiasecProfil profil, List<RomeMetierResume> metiers, MesPistesEtat etat) {
  return profil
      .metiersCorrespondants(metiers)
      .where((metier) => etat.piste(metier.code) == null)
      .take(metiersAjoutesAuTri)
      .toList();
}

// Les métiers liés au plus grand nombre de centres d'intérêt choisis d'abord, puis dans l'ordre de ROME.
List<RomeMetierResume> metiersDesCentres(List<List<RomeMetierResume>> parCentre, MesPistesEtat etat) {
  final metiers = <String, RomeMetierResume>{};
  final enCommun = <String, int>{};
  for (final liste in parCentre) {
    for (final metier in liste) {
      metiers.putIfAbsent(metier.code, () => metier);
      enCommun[metier.code] = (enCommun[metier.code] ?? 0) + 1;
    }
  }
  final ordre = metiers.keys.toList();
  final rang = {for (var i = 0; i < ordre.length; i++) ordre[i]: i};
  final candidats = ordre.where((code) => etat.piste(code) == null).toList()
    ..sort((a, b) {
      final ecart = enCommun[b]!.compareTo(enCommun[a]!);
      return ecart != 0 ? ecart : rang[a]!.compareTo(rang[b]!);
    });
  return [for (final code in candidats.take(metiersAjoutesAuTri)) metiers[code]!];
}
