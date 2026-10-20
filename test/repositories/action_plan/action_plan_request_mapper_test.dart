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
    test(
      'maps answers to questionnaire request body, age computed from date of birth',
      () {
        final request = mapper.toQuestionnaireRequest(
          OnboardingQuestionnaireAnswers(
            prenom: 'Malik',
            dateNaissance: DateTime(2006, 4, 12),
            situation: QuestionnaireSituation.lycee,
            objectifs: {QuestionnaireObjectif.alternance},
            domaine: 'mécanique',
            freins: {QuestionnaireFrein.pasDeTransport},
          ),
          etapeCourante: 'freins',
          now: DateTime(2026, 4, 11),
        );

        expect(request, {
          'etapeCourante': 'freins',
          'age': 19,
          'situation': 'LYCEE',
          'goals': ['ALTERNANCE'],
          'domaine': 'mécanique',
          'obstacles': ['PAS_DE_TRANSPORT'],
        });
      },
    );

    test('empty answers are sent as empty, domaine omitted', () {
      final request = mapper.toQuestionnaireRequest(
        const OnboardingQuestionnaireAnswers(),
        etapeCourante: 'freins',
      );

      expect(request, {
        'etapeCourante': 'freins',
        'goals': <String>[],
        'obstacles': <String>[],
      });
    });

    test(
      '"je ne sais pas" domaine is sent as null, unlike an unanswered one',
      () {
        final request = mapper.toQuestionnaireRequest(
          const OnboardingQuestionnaireAnswers(domaineInconnu: true),
          etapeCourante: 'freins',
        );

        expect(request.containsKey('domaine'), isTrue);
        expect(request['domaine'], isNull);
      },
    );

    test(
      'restores contract answers and keeps local ones unknown to the API',
      () {
        final restored = mapper.fromQuestionnaireResponse(
          {
            'dateMiseAJour': '2026-10-20T10:00:00.000Z',
            'age': 19,
            'situation': 'EMPLOI',
            'goals': ['EMPLOI', 'FORMER'],
            'domaine': null,
            'obstacles': ['RIEN_NE_ME_BLOQUE'],
          },
          const OnboardingQuestionnaireAnswers(prenom: 'Malik', rayonKm: 30),
        );

        expect(
          restored,
          const OnboardingQuestionnaireAnswers(
            prenom: 'Malik',
            rayonKm: 30,
            situation: QuestionnaireSituation.emploi,
            objectifs: {
              QuestionnaireObjectif.emploi,
              QuestionnaireObjectif.former,
            },
            domaineInconnu: true,
            freins: {QuestionnaireFrein.rienNeMeBloque},
          ),
        );
      },
    );

    test('restores a domaine and an absent one stays unanswered', () {
      final withDomaine = mapper.fromQuestionnaireResponse(
        {
          'situation': 'LYCEE',
          'goals': <String>[],
          'domaine': 'mécanique',
          'obstacles': <String>[],
        },
        const OnboardingQuestionnaireAnswers(),
      );
      final withoutDomaine = mapper.fromQuestionnaireResponse(
        {'situation': 'LYCEE', 'goals': <String>[], 'obstacles': <String>[]},
        const OnboardingQuestionnaireAnswers(),
      );

      expect(withDomaine.domaine, 'mécanique');
      expect(withDomaine.domaineInconnu, isFalse);
      expect(withoutDomaine.isDomaineAnswered, isFalse);
    });
  });
}
