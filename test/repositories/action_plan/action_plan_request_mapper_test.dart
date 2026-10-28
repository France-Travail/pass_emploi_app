import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';

void main() {
  const mapper = ActionPlanRequestMapper();

  test('maps questionnaire answers to plan-action request body', () {
    final request = mapper.toRequest(
      OnboardingQuestionnaireAnswers(
        prenom: 'Malik',
        dateNaissance: DateTime(2006, 4, 12),
        habitation: const QuestionnaireCommune(code: '76540', nom: 'Rouen'),
        situation: QuestionnaireSituation.lycee,
        objectifs: {
          QuestionnaireObjectif.alternance,
          QuestionnaireObjectif.decouvrirMetiers,
        },
        domaine: 'mécanique',
        villeRecherche: const QuestionnaireCommune(code: '76540', nom: 'Rouen'),
        rayonKm: 30,
        freins: {
          QuestionnaireFrein.pasDeTransport,
          QuestionnaireFrein.manqueConfiance,
        },
      ),
    );

    expect(request, {
      'dateNaissance': '2006-04-12',
      'situation': 'LYCEE',
      'goals': ['ALTERNANCE', 'DECOUVRIR_METIERS'],
      'domaine': 'mécanique',
      'habitation': {'codeInsee': '76540', 'nom': 'Rouen'},
      'villeRecherche': {'codeInsee': '76540', 'nom': 'Rouen'},
      'rayonKm': 30,
      'obstacles': ['PAS_DE_TRANSPORT', 'MANQUE_CONFIANCE'],
    });
  });

  test('maps domaine inconnu to null', () {
    final request = mapper.toRequest(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.autre,
        objectifs: {QuestionnaireObjectif.emploi},
        domaineInconnu: true,
      ),
    );

    expect(request['domaine'], isNull);
  });

  test('maps rienNeMeBloque as exclusive obstacle', () {
    final request = mapper.toRequest(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.autre,
        objectifs: {QuestionnaireObjectif.emploi},
        freins: {
          QuestionnaireFrein.rienNeMeBloque,
          QuestionnaireFrein.pasDePermis,
        },
      ),
    );

    expect(request['obstacles'], ['RIEN_NE_ME_BLOQUE']);
  });

  test('maps all situations, goals and obstacles', () {
    expect(
      mapper.toRequest(
        const OnboardingQuestionnaireAnswers(
          situation: QuestionnaireSituation.college,
          objectifs: {QuestionnaireObjectif.orienter},
          freins: {QuestionnaireFrein.pasDeDiplome},
        ),
      )['situation'],
      'COLLEGE',
    );
    expect(
      mapper.toRequest(
        const OnboardingQuestionnaireAnswers(
          situation: QuestionnaireSituation.etudesSuperieures,
          objectifs: {
            QuestionnaireObjectif.former,
            QuestionnaireObjectif.stageImmersion,
            QuestionnaireObjectif.engager,
            QuestionnaireObjectif.mobiliteInternationale,
            QuestionnaireObjectif.accompagne,
            QuestionnaireObjectif.creerActivite,
            QuestionnaireObjectif.vieQuotidienne,
          },
          freins: {
            QuestionnaireFrein.pasDePermis,
            QuestionnaireFrein.pasDeLogement,
            QuestionnaireFrein.finDeMois,
            QuestionnaireFrein.gardeEnfant,
            QuestionnaireFrein.numerique,
            QuestionnaireFrein.handicap,
            QuestionnaireFrein.sante,
            QuestionnaireFrein.peuExperience,
            QuestionnaireFrein.francais,
          },
        ),
      ),
      {
        'situation': 'ETUDES_SUPERIEURES',
        'goals': [
          'FORMER',
          'STAGE_IMMERSION',
          'ENGAGER',
          'MOBILITE_INTERNATIONALE',
          'ACCOMPAGNE',
          'CREER_ACTIVITE',
          'VIE_QUOTIDIENNE',
        ],
        'domaine': null,
        'obstacles': [
          'PAS_DE_PERMIS',
          'PAS_DE_LOGEMENT',
          'FIN_DE_MOIS',
          'GARDE_ENFANT',
          'NUMERIQUE',
          'HANDICAP',
          'SANTE',
          'PEU_EXPERIENCE',
          'FRANCAIS',
        ],
      },
    );
  });

  group('questionnaire', () {
    test('restores every answer known to the API and keeps the local prenom', () {
      final restored = mapper.fromQuestionnaireResponse(
        {
          'situation': 'EMPLOI',
          'goals': ['EMPLOI', 'ORIENTER'],
          'obstacles': ['PAS_DE_PERMIS'],
          'dateNaissance': '2005-03-14',
          'habitation': {'codeInsee': '75056', 'nom': 'Paris'},
          'villeRecherche': {'codeInsee': '69123', 'nom': 'Lyon'},
          'domaine': 'Informatique',
          'rayonKm': 10,
        },
        const OnboardingQuestionnaireAnswers(prenom: 'Malik'),
      );

      expect(
        restored,
        OnboardingQuestionnaireAnswers(
          prenom: 'Malik',
          dateNaissance: DateTime(2005, 3, 14),
          habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
          situation: QuestionnaireSituation.emploi,
          objectifs: {QuestionnaireObjectif.emploi, QuestionnaireObjectif.orienter},
          domaine: 'Informatique',
          villeRecherche: const QuestionnaireCommune(code: '69123', nom: 'Lyon'),
          rayonKm: 10,
          freins: {QuestionnaireFrein.pasDePermis},
        ),
      );
    });

    test('optional answers absent from the API stay unanswered', () {
      final restored = mapper.fromQuestionnaireResponse(
        {
          'situation': 'LYCEE',
          'goals': ['ALTERNANCE'],
          'obstacles': <String>[],
        },
        const OnboardingQuestionnaireAnswers(),
      );

      expect(
        restored,
        const OnboardingQuestionnaireAnswers(
          situation: QuestionnaireSituation.lycee,
          objectifs: {QuestionnaireObjectif.alternance},
        ),
      );
      expect(restored.isDomaineAnswered, isFalse);
    });

    test('maps back what the plan generation request sends', () {
      final answers = OnboardingQuestionnaireAnswers(
        dateNaissance: DateTime(2006, 4, 12),
        habitation: const QuestionnaireCommune(code: '76540', nom: 'Rouen'),
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.alternance},
        domaine: 'mécanique',
        villeRecherche: const QuestionnaireCommune(code: '76540', nom: 'Rouen'),
        rayonKm: 30,
        freins: {QuestionnaireFrein.pasDeTransport},
      );

      final restored = mapper.fromQuestionnaireResponse(
        mapper.toRequest(answers),
        const OnboardingQuestionnaireAnswers(),
      );

      expect(restored, answers);
    });
  });

  group('précision de la situation « Autre »', () {
    const autre = OnboardingQuestionnaireAnswers(
      situation: QuestionnaireSituation.autre,
      situationAutre: 'En service civique',
      objectifs: {QuestionnaireObjectif.orienter},
    );

    test('is sent with the situation AUTRE', () {
      final request = mapper.toRequest(autre);

      expect(request['situation'], 'AUTRE');
      expect(request['precisionAutre'], 'En service civique');
    });

    test('is not sent without precision, nor with another situation', () {
      final sansPrecision = mapper.toRequest(autre.copyWith(clearSituationAutre: true));
      final autreSituation = mapper.toRequest(autre.copyWith(situation: QuestionnaireSituation.lycee));

      expect(sansPrecision.containsKey('precisionAutre'), isFalse);
      expect(autreSituation.containsKey('precisionAutre'), isFalse);
    });

    test('is restored from the questionnaire saved on server', () {
      final restored = mapper.fromQuestionnaireResponse(
        {
          'situation': 'AUTRE',
          'precisionAutre': 'En service civique',
          'goals': ['ORIENTER'],
          'obstacles': <String>[],
        },
        const OnboardingQuestionnaireAnswers(),
      );

      expect(restored, autre);
    });

    test('is ignored with another situation, and absent when the server has none', () {
      final autreSituation = mapper.fromQuestionnaireResponse(
        {
          'situation': 'LYCEE',
          'precisionAutre': 'En service civique',
          'goals': ['ORIENTER'],
          'obstacles': <String>[],
        },
        const OnboardingQuestionnaireAnswers(),
      );
      final sansPrecision = mapper.fromQuestionnaireResponse(
        {
          'situation': 'AUTRE',
          'goals': ['ORIENTER'],
          'obstacles': <String>[],
        },
        const OnboardingQuestionnaireAnswers(situationAutre: 'Ancienne précision'),
      );

      expect(autreSituation.situationAutre, isNull);
      expect(sansPrecision.situationAutre, isNull);
    });
  });
}
