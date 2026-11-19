import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/parcours.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

dynamic _demo(String fichier) => jsonDecode(File('assets/mode_demo/$fichier.json').readAsStringSync());

final _metiersDeLaDemo = [for (final json in _demo('poc_orientation_metiers') as List) RomeMetierResume.fromJson(json)];
final _marcheDeLille = MarcheTravail.fromJson(_demo('poc_orientation_marche_travail'));

const _boulanger = RomeMetierResume(code: 'D1102', libelle: 'Boulanger / Boulangère');
const _boucher = RomeMetierResume(code: 'D1101', libelle: 'Boucher / Bouchère');
const _patissier = RomeMetierResume(code: 'D1104', libelle: 'Pâtissier / Pâtissière');
const _infirmier = RomeMetierResume(code: 'J1506', libelle: 'Infirmier / Infirmière');

Piste _piste(
  RomeMetierResume metier, {
  AvisMetier avis = AvisMetier.meTente,
  Set<ActionPiste> faites = const {ActionPiste.lireFiche},
}) {
  return Piste(metier: metier, avis: avis, faites: faites);
}

PisteProposee _proposee(RomeMetierResume metier, List<SourcePiste> sources) {
  return PisteProposee(metier, [for (final source in sources) RaisonProposition(source, '')]);
}

void main() {
  group('L’étape mise en avant sur l’accueil', () {
    test('rien à trier et aucune piste : trouver des idées', () {
      expect(etapeDuParcours(aTrier: 0, pistes: 0), EtapeParcours.idees);
    });

    test('des métiers à trier et encore aucune piste : faire le tri', () {
      expect(etapeDuParcours(aTrier: 8, pistes: 0), EtapeParcours.tri);
    });

    test('dès une piste, on avance, même si de nouveaux métiers attendent le tri', () {
      expect(etapeDuParcours(aTrier: 5, pistes: 1), EtapeParcours.avancer);
      expect(etapeDuParcours(aTrier: 0, pistes: 2), EtapeParcours.avancer);
    });
  });

  group('La prochaine étape', () {
    test('vient de la piste la plus avancée ; à égalité, de la plus récente', () {
      final etat = MesPistesEtat(
        pistes: [
          _piste(_boulanger, faites: {ActionPiste.lireFiche, ActionPiste.voirVideo}),
          _piste(_boucher),
          _piste(_patissier),
        ],
      );

      final prochaine = prochaineEtape(etat)!;

      expect(prochaine.piste.code, 'D1102');
      expect(prochaine.action, ActionPiste.echangerAvecUnPro);
      expect(prochaineEtape(MesPistesEtat(pistes: [_piste(_boulanger), _piste(_boucher)]))!.piste.code, 'D1101');
    });

    test('laisse de côté les métiers mis de côté et les pistes terminées', () {
      final terminee = _piste(_boulanger, faites: ActionPiste.values.toSet());
      final misDeCote = _piste(_boucher, avis: AvisMetier.pasPourMoi);

      expect(prochaineEtape(MesPistesEtat(pistes: [terminee, misDeCote])), isNull);
      expect(prochaineEtape(MesPistesEtat(pistes: [terminee, _piste(_patissier)]))!.piste.code, 'D1104');
    });
  });

  group('Ce qui remplit le tri', () {
    test('le test ajoute ses 8 métiers les plus proches du profil, sans ceux déjà triés', () {
      final profil = RiasecProfil.depuisScores({Riasec.social: 10, Riasec.realiste: 8, Riasec.artiste: 2});
      final proches = profil.metiersCorrespondants(_metiersDeLaDemo);
      expect(proches.length, greaterThan(10));
      final etat = MesPistesEtat(pistes: [_piste(proches[0], avis: AvisMetier.pasPourMoi), _piste(proches[2])]);

      final ajoutes = metiersDuTest(profil, _metiersDeLaDemo, etat);

      expect(ajoutes, [proches[1], ...proches.sublist(3, 10)]);
    });

    test('ce que le jeune aime : les métiers communs à plusieurs centres d’abord, puis dans l’ordre de ROME', () {
      final etat = MesPistesEtat(pistes: [_piste(_patissier)]);

      final ajoutes = metiersDesCentres([
        [_boulanger, _patissier, _boucher],
        [_boucher, _patissier],
      ], etat);

      expect(ajoutes, [_boucher, _boulanger]);
      final beaucoup = [for (var i = 0; i < 12; i++) RomeMetierResume(code: 'X$i', libelle: 'Métier $i')];
      expect(metiersDesCentres([beaucoup], const MesPistesEtat()), beaucoup.take(8).toList());
    });

    test('les métiers du test et de ce que le jeune aime arrivent dans le tri avec leur raison', () {
      const etat = MesPistesEtat(
        ajouts: [
          AjoutAuTri(metier: _boucher, source: SourceAjout.centresInteret, detail: 'Cuisiner'),
          AjoutAuTri(metier: _boulanger, source: SourceAjout.test, detail: 'Réaliste et Social'),
          AjoutAuTri(metier: _boulanger, source: SourceAjout.centresInteret, detail: 'Cuisiner'),
        ],
      );

      final aTrier = proposerDesPistes(const ContexteJeune(), etat);

      expect([for (final piste in aTrier) piste.metier.code], ['D1102', 'D1101']);
      expect([for (final raison in aTrier.first.raisons) raison.texte], [
        'D’après ton test : tu es plutôt Réaliste et Social',
        'D’après tes centres d’intérêt',
      ]);
    });

    test('un métier trié ne revient pas dans le tri, même ajouté de nouveau par le test', () {
      final etat = MesPistesEtat(
        pistes: [_piste(_boulanger, avis: AvisMetier.pasPourMoi)],
        ajouts: const [AjoutAuTri(metier: _boulanger, source: SourceAjout.test, detail: 'Réaliste')],
      );

      expect(proposerDesPistes(const ContexteJeune(), etat), isEmpty);
    });

    test('en arrivant du test, ses métiers passent devant les autres', () {
      final favori = _proposee(_boucher, [SourcePiste.favori]);
      final duTest = _proposee(_boulanger, [SourcePiste.recherche, SourcePiste.test]);

      expect(mettreDevant([favori, duTest], SourcePiste.test), [duTest, favori]);
      expect(mettreDevant([favori, duTest], null), [favori, duTest]);
    });

    test('en démo, seuls les métiers dont la fiche est dans la démo peuvent rejoindre le tri', () {
      expect(aUneFicheDeDemo('D1102'), isTrue);
      expect(aUneFicheDeDemo('D1507'), isTrue);
      expect(aUneFicheDeDemo('J1506'), isFalse);
    });
  });

  group('Les textes de l’accueil', () {
    test('« tirés de… » cite les 3 premières origines, dans l’ordre de priorité', () {
      final aTrier = [
        _proposee(_boulanger, [SourcePiste.favori, SourcePiste.recherche]),
        _proposee(_boucher, [SourcePiste.conseiller, SourcePiste.diagoriente]),
      ];

      expect(
        PocOrientationStrings.heroTriTexte(aTrier.length, originesDeLaListe(aTrier)),
        '2 métiers pour toi, tirés des conseils de ton conseiller, de tes favoris et de tes recherches.',
      );
    });

    test('les voisins d’une piste sont annoncés comme nouveaux ; les autres métiers à trier, non', () {
      final etat = MesPistesEtat(pistes: [_piste(_boulanger)]);
      final voisins = [
        for (final proche in _marcheDeLille.metiersProches['D1102']!) _proposee(proche, [SourcePiste.metierProche]),
      ];
      final melange = [...voisins, _proposee(_infirmier, [SourcePiste.test])];

      expect(
        PocOrientationStrings.rappelATrier(voisins.length, voisinsDe(voisins, etat, _marcheDeLille)),
        '${voisins.length} nouveaux métiers à trier, voisins de Boulanger',
      );
      expect(
        PocOrientationStrings.rappelATrier(melange.length, voisinsDe(melange, etat, _marcheDeLille)),
        '${melange.length} métiers à trier',
      );
      expect(PocOrientationStrings.rappelATrier(1, const []), '1 métier à trier');
    });
  });
}
