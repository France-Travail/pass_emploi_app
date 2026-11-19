import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

import '../doubles/spies.dart';

const _boulanger = RomeMetierResume(code: 'D1102', libelle: 'Boulanger / Boulangère', riasecMajeur: 'R');
const _estheticien = RomeMetierResume(code: 'D1208', libelle: 'Esthéticien / Esthéticienne');

void main() {
  late FlutterSecureStorageSpy stockage;
  final pistes = MesPistes.instance;

  setUp(() {
    stockage = FlutterSecureStorageSpy(delay: Duration.zero);
    pistes.reinitialiser();
    pistes.utiliser(stockage);
  });

  group('Avis sur un métier', () {
    test('« Ça me tente » crée une piste dont la fiche est déjà lue', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);

      pistes.meTente(_boulanger);

      final piste = pistes.value.piste('D1102')!;
      expect(piste.avis, AvisMetier.meTente);
      expect(piste.faites, {ActionPiste.lireFiche});
      expect(piste.etapeEnCours, EtapePiste.decouvrir);
      expect(piste.prochaineAction, ActionPiste.voirVideo);
      expect(pistes.value.quiTentent, [piste]);
    });

    test('les étapes avancent quand le jeune coche, jusqu’à « se lancer »', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      pistes.meTente(_boulanger);

      pistes.marquer('D1102', ActionPiste.voirVideo, faite: true);
      expect(pistes.value.piste('D1102')!.etapeEnCours, EtapePiste.tester);

      pistes.marquer('D1102', ActionPiste.echangerAvecUnPro, faite: true);
      pistes.marquer('D1102', ActionPiste.faireUneImmersion, faite: true);
      expect(pistes.value.piste('D1102')!.etapeEnCours, EtapePiste.seFormer);
      expect(pistes.value.piste('D1102')!.nombreFaites, 4);

      pistes.marquer('D1102', ActionPiste.regarderLesFormations, faite: true);
      expect(pistes.value.piste('D1102')!.etapeEnCours, isNull);
      expect(pistes.value.piste('D1102')!.prochaineAction, isNull);

      pistes.marquer('D1102', ActionPiste.voirVideo, faite: false);
      expect(pistes.value.piste('D1102')!.prochaineAction, ActionPiste.voirVideo);
    });

    test('« Pas pour moi » met le métier de côté avec ses raisons, sans perdre les étapes faites', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      pistes.meTente(_boulanger);
      pistes.marquer('D1102', ActionPiste.faireUneImmersion, faite: true);

      pistes.pasPourMoi(_boulanger, {RaisonPasPourMoi.teste, RaisonPasPourMoi.conditions});

      final piste = pistes.value.piste('D1102')!;
      expect(piste.avis, AvisMetier.pasPourMoi);
      expect(piste.raisons, {RaisonPasPourMoi.teste, RaisonPasPourMoi.conditions});
      expect(piste.faites, {ActionPiste.lireFiche, ActionPiste.faireUneImmersion});
      expect(pistes.value.quiTentent, isEmpty);
      expect(pistes.value.misDeCote, [piste]);
    });

    test('changer d’avis efface les raisons, et une piste garde sa place dans la liste', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      pistes.pasPourMoi(_boulanger, {RaisonPasPourMoi.salaire});
      pistes.meTente(_estheticien);

      pistes.meTente(_boulanger);

      expect(pistes.value.pistes.map((piste) => piste.code), ['D1102', 'D1208']);
      expect(pistes.value.piste('D1102')!.raisons, isEmpty);
      expect(pistes.value.quiTentent.length, 2);
    });

    test('un second appui retire l’avis', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      pistes.meTente(_boulanger);

      pistes.oublier('D1102');

      expect(pistes.value.pistes, isEmpty);
    });
  });

  test('un nouveau test remplace les métiers que le précédent avait ajoutés au tri, pas ceux des centres', () async {
    await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
    pistes.ajouterAuTri(SourceAjout.centresInteret, [_boulanger], 'Cuisiner');
    pistes.ajouterAuTri(SourceAjout.test, [_estheticien], 'Social et Artiste');

    pistes.ajouterAuTri(SourceAjout.test, [_boulanger], 'Réaliste et Social');

    expect(pistes.value.ajouts, const [
      AjoutAuTri(metier: _boulanger, source: SourceAjout.centresInteret, detail: 'Cuisiner'),
      AjoutAuTri(metier: _boulanger, source: SourceAjout.test, detail: 'Réaliste et Social'),
    ]);
  });

  group('Mémoire sur le téléphone', () {
    test('les pistes, le profil et les centres d’intérêt sont gardés au nom du jeune', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      pistes.meTente(_boulanger);
      pistes.pasPourMoi(_estheticien, {RaisonPasPourMoi.interet});
      pistes.enregistrerProfilRiasec({Riasec.social: 9, Riasec.realiste: 7});
      pistes.enregistrerCentresInteret(['Cuisiner']);
      pistes.ajouterAuTri(SourceAjout.test, [_boulanger], 'Social et Réaliste');
      final avant = pistes.value;
      await Future<void>.delayed(Duration.zero);

      pistes.reinitialiser();
      pistes.utiliser(stockage);
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);

      expect(pistes.value, avant);
      expect(pistes.value.profilRiasec!.dominants, [Riasec.social, Riasec.realiste]);
    });

    test('un autre compte sur le même téléphone ne voit pas les pistes du premier', () async {
      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      pistes.meTente(_boulanger);
      await Future<void>.delayed(Duration.zero);

      await pistes.ouvrirSession(jeune: 'jeune-2', demo: false);
      expect(pistes.value.pistes, isEmpty);

      await pistes.ouvrirSession(jeune: 'jeune-1', demo: false);
      expect(pistes.value.pistes.single.code, 'D1102');
    });

    test('en démo, rien n’est écrit sur le téléphone et tout repart de zéro à chaque entrée', () async {
      pistes.demarrerDemo();
      await pistes.ouvrirSession(jeune: 'DEMO', demo: true);
      pistes.meTente(_boulanger);
      await Future<void>.delayed(Duration.zero);

      expect(await stockage.read(key: 'poc_orientation_mes_pistes_DEMO'), isNull);
      expect(pistes.value.pistes, isNotEmpty);

      pistes.demarrerDemo();
      expect(pistes.value.pistes, isEmpty);
    });

    test('une donnée abîmée ou d’une ancienne version ne bloque pas le POC', () {
      expect(MesPistesEtat.lire('pas du json'), const MesPistesEtat());
      final etat = MesPistesEtat.lire(
        jsonEncode({
          'pistes': [
            {
              'metier': {'code': 'D1102', 'libelle': 'Boulanger / Boulangère'},
              'avis': 'meTente',
              'faites': ['lireFiche', 'actionDisparue'],
            },
            {'avis': 'meTente'},
          ],
          'riasec': {'S': 6, 'X': 3},
        }),
      );

      expect(etat.pistes.single.faites, {ActionPiste.lireFiche});
      expect(etat.scoresRiasec, {Riasec.social: 6});
    });
  });

  test('le profil RIASEC gardé redonne le même classement que le test', () {
    final reponses = [
      for (final question in riasecQuestions)
        question.type == Riasec.social ? RiasecReponse.jaime : RiasecReponse.caDepend,
    ];
    final profil = RiasecProfil.depuis(reponses);

    final retrouve = RiasecProfil.depuisScores(profil.scores);

    expect(retrouve.ordre, profil.ordre);
    expect(retrouve.dominants, profil.dominants);
  });
}
