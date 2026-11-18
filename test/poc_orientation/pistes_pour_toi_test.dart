import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/suggestion_recherche.dart';
import 'package:pass_emploi_app/poc_orientation/conseils_freins.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/romeo_simule.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';
import 'package:pass_emploi_app/repositories/alerte/alerte_json_extractor.dart';
import 'package:pass_emploi_app/repositories/alerte/alerte_response.dart';

dynamic _demo(String fichier) => jsonDecode(File('assets/mode_demo/$fichier.json').readAsStringSync());

// Les données de Paul, le jeune de la démo 1J1S, lues comme l'app les lit.
final _questionnaireDePaul = ActionPlanRequestMapper().fromQuestionnaireResponse(
  _demo('plan_action_questionnaire') as Map<String, dynamic>,
  const OnboardingQuestionnaireAnswers(),
);
final _favorisDePaul = [for (final json in _demo('cej/favoris') as List) ?Favori.fromJson(json)];
final _recherchesDePaul = [
  for (final json in _demo('cej/alertes') as List) ?AlerteJsonExtractor().extract(AlerteResponse.fromJson(json)),
];
final _suggestionsDePaul = [
  for (final json in _demo('cej/suggestions_recherche') as List) SuggestionRecherche.fromJson(json),
];
final _parcoursDePaul = [
  for (final json in _demo('poc_orientation_profil_ft')['experiences'] as List) ExperienceFranceTravail.fromJson(json),
];
final _marcheDeLille = MarcheTravail.fromJson(_demo('poc_orientation_marche_travail'));

ContexteJeune _paul({OnboardingQuestionnaireAnswers? questionnaire, bool franceTravail = true}) => ContexteJeune(
  questionnaire: questionnaire ?? _questionnaireDePaul,
  favoris: _favorisDePaul,
  alertes: _recherchesDePaul,
  suggestions: _suggestionsDePaul,
  experiencesFranceTravail: franceTravail ? _parcoursDePaul : const [],
);

List<String> _codes(List<PisteProposee> pistes) => [for (final piste in pistes) piste.metier.code];

void main() {
  group('ROMEO simulé', () {
    test('retrouve le métier ROME des intitulés de la démo, sans tenir compte des accents ni de (H/F)', () {
      expect(romeoSimule('Employé / Employée de rayon libre-service (H/F)')?.code, 'D1507');
      expect(romeoSimule('Employé Libre-Service')?.code, 'D1507');
      expect(romeoSimule('Management/gestion de rayon produits alimentaires')?.code, 'D1502');
      expect(romeoSimule('Vendeur / Vendeuse en électroménager   (H/F)')?.code, 'D1212');
      expect(romeoSimule('Conducteur / Conductrice d’engins d’exploitations agricoles')?.code, 'A1101');
      expect(romeoSimule('BOULANGERIE')?.code, 'D1102');
    });

    test('écarte un intitulé trop vague ou inconnu', () {
      expect(romeoSimule('Vendeur'), isNull);
      expect(romeoSimule('solidarite-insertion'), isNull);
      expect(romeoSimule(null), isNull);
    });
  });

  group('Des pistes pour toi', () {
    test('Paul, en démo France Travail, se voit proposer 8 métiers tirés de ce qu’il a déjà fait', () {
      final pistes = proposerDesPistes(_paul(), const MesPistesEtat(), marche: _marcheDeLille);

      expect(_codes(pistes), ['D1502', 'D1507', 'D1401', 'C1201', 'A1101', 'G1603', 'D1212', 'D1202']);
      expect(pistes.first.raisons, const [
        RaisonProposition(SourcePiste.favori, 'Tu as mis une offre en favori'),
        RaisonProposition(SourcePiste.recherche, 'Tu as enregistré une recherche'),
      ]);
      expect(
        pistes.firstWhere((piste) => piste.metier.code == 'G1603').raisons.single.texte,
        'Ton parcours France Travail : Équipier polyvalent en restauration rapide, 8 mois',
      );
      expect(
        pistes.last.raisons.single,
        const RaisonProposition(SourcePiste.diagoriente, 'Tu l’avais aimé sur Diagoriente'),
      );
    });

    test('sans parcours France Travail (démo Mission Locale), la piste qui en vient disparaît', () {
      final pistes = proposerDesPistes(_paul(franceTravail: false), const MesPistesEtat());

      expect(_codes(pistes), isNot(contains('G1603')));
      expect(pistes.length, 7);
    });

    test('un métier déjà trié n’est plus proposé, et les métiers proches d’une piste arrivent', () {
      const boulanger = RomeMetierResume(code: 'D1102', libelle: 'Boulanger / Boulangère');
      final mesPistes = MesPistesEtat(
        pistes: const [
          Piste(metier: boulanger, avis: AvisMetier.meTente),
          Piste(
            metier: RomeMetierResume(code: 'D1507', libelle: 'Employé'),
            avis: AvisMetier.pasPourMoi,
          ),
        ],
      );

      final pistes = proposerDesPistes(_paul(), mesPistes, marche: _marcheDeLille);

      expect(_codes(pistes), isNot(contains('D1507')));
      expect(_codes(pistes), containsAll(['D1101', 'D1108', 'D1106', 'D1104', 'D1301']));
      expect(
        pistes.firstWhere((piste) => piste.metier.code == 'D1101').raisons.single.texte,
        'Proche de « Boulanger / Boulangère », qui te tente',
      );
    });

    test('le « métier ou secteur » tapé au questionnaire devient une piste', () {
      final questionnaire = _questionnaireDePaul.copyWith(domaine: 'Boulangerie', domaineInconnu: false);

      final pistes = proposerDesPistes(_paul(questionnaire: questionnaire), const MesPistesEtat());

      expect(
        pistes.firstWhere((piste) => piste.metier.code == 'D1102').raisons.single.texte,
        'Tu as écrit « Boulangerie » dans ton questionnaire',
      );
    });
  });

  group('Ça recrute près de chez toi', () {
    test('les chiffres de Lille disent quels métiers recrutent (au moins 100 offres en un an)', () {
      expect(_marcheDeLille.caRecrute('D1102'), isTrue);
      expect(_marcheDeLille.caRecrute('C1201'), isFalse);
      expect(_marcheDeLille.chiffres('D1102')!.principalesOrigines, [
        'Conditions de travail',
        'Lien formation - métier',
      ]);
      expect(_marcheDeLille.chiffres('D1102')!.difficulte, DifficulteRecrutement.moyenne);
    });

    test('le lien Data Emploi vise le métier sur le territoire, et le département se déduit du code Insee', () {
      expect(
        _marcheDeLille.lienDataEmploi('D1102'),
        'https://dataemploi.francetravail.fr/emploi/metier/chiffres-cles/EPCI/200093201/D1102',
      );
      expect(departementDe('59350'), '59');
      expect(departementDe('2A004'), '2A');
      expect(departementDe('97411'), '974');
      expect(departementDe(null), isNull);
    });

    test('en démo, chaque métier proposé a sa propre fiche ; les autres gardent celle du boulanger', () {
      expect(pocOrientationFicheDeDemo('D1507'), 'poc_orientation_fiche_D1507');
      expect(pocOrientationFicheDeDemo('M1805'), 'poc_orientation_fiche_metier');
      for (final code in ['D1507', 'D1502', 'D1212', 'C1201', 'D1401', 'A1101', 'D1202', 'G1603', 'D1101']) {
        expect(File('assets/mode_demo/poc_orientation_fiche_$code.json').existsSync(), isTrue, reason: code);
      }
    });
  });

  group('Conseils selon les freins', () {
    test('les freins de Paul (permis, fins de mois, santé) donnent un conseil sous trois étapes', () {
      expect(conseilsPourEtape(EtapePiste.decouvrir, _questionnaireDePaul, sansDiplome: false), [
        'Pense à ta santé : regarde bien les conditions de travail plus haut, et parles-en à ton conseiller.',
      ]);
      expect(conseilsPourEtape(EtapePiste.tester, _questionnaireDePaul, sansDiplome: false), [
        'Sans permis ou sans voiture : cherche une immersion à moins de 20 km de Lille, proche des transports en commun.',
      ]);
      expect(conseilsPourEtape(EtapePiste.seFormer, _questionnaireDePaul, sansDiplome: false), [
        'En alternance, tu es payé pendant ta formation.',
      ]);
    });

    test('« pas de diplôme » dit si le métier est accessible sans diplôme, sinon parle de formations courtes', () {
      final reponses = const OnboardingQuestionnaireAnswers(freins: {QuestionnaireFrein.pasDeDiplome});

      expect(conseilsPourEtape(EtapePiste.seFormer, reponses, sansDiplome: true), [
        'Bonne nouvelle : ce métier est accessible sans diplôme.',
      ]);
      expect(
        conseilsPourEtape(EtapePiste.seFormer, reponses, sansDiplome: false).single,
        startsWith('Pas de diplôme ?'),
      );
      expect(conseilsPourEtape(EtapePiste.tester, null, sansDiplome: false), isEmpty);
    });
  });
}
