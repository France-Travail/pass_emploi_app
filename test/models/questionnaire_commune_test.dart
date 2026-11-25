import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

void main() {
  group('communeEntiere', () {
    test('an arrondissement becomes its whole city, with the arrondissement code postal', () {
      const paris14 = QuestionnaireCommune(code: '75114', nom: 'Paris 14e Arrondissement', codePostal: '75014');
      const lyon3 = QuestionnaireCommune(code: '69383', nom: 'Lyon 3e Arrondissement', codePostal: '69003');
      const marseille8 = QuestionnaireCommune(code: '13208', nom: 'Marseille 8e Arrondissement', codePostal: '13008');

      expect(paris14.communeEntiere, const QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75014'));
      expect(lyon3.communeEntiere, const QuestionnaireCommune(code: '69123', nom: 'Lyon', codePostal: '69003'));
      expect(
        marseille8.communeEntiere,
        const QuestionnaireCommune(code: '13055', nom: 'Marseille', codePostal: '13008'),
      );
    });

    test('any other commune stays the same', () {
      const vire = QuestionnaireCommune(code: '14762', nom: 'Vire Normandie', codePostal: '14500');
      const albigny = QuestionnaireCommune(code: '69003', nom: 'Albigny-sur-Saône', codePostal: '69250');

      expect(vire.communeEntiere, vire);
      expect(albigny.communeEntiere, albigny);
    });
  });

  group('nomCourt', () {
    String nomCourt(String code, String nom, String? codePostal) =>
        QuestionnaireCommune(code: code, nom: nom, codePostal: codePostal).nomCourt;

    test('drops « Arrondissement »', () {
      expect(nomCourt('75114', 'Paris 14e Arrondissement', '75014'), 'Paris 14e');
    });

    test('a whole city with an arrondissement code postal names the arrondissement', () {
      expect(nomCourt('75056', 'Paris', '75001'), 'Paris 1er');
      expect(nomCourt('75056', 'Paris', '75018'), 'Paris 18e');
      expect(nomCourt('75056', 'Paris', '75116'), 'Paris 16e');
      expect(nomCourt('69123', 'Lyon', '69009'), 'Lyon 9e');
      expect(nomCourt('13055', 'Marseille', '13016'), 'Marseille 16e');
    });

    test('keeps the name otherwise', () {
      expect(nomCourt('75056', 'Paris', null), 'Paris');
      expect(nomCourt('75056', 'Paris', '75000'), 'Paris');
      expect(nomCourt('14762', 'Vire Normandie', '14500'), 'Vire Normandie');
    });
  });
}
