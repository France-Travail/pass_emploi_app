import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

void main() {
  group('CriteresRechercheUtilisateur.fromOnboardingAnswers', () {
    test('should map domaine, ville and rayon', () {
      final answers = OnboardingQuestionnaireAnswers(
        domaine: 'Boulanger',
        villeRecherche: const QuestionnaireCommune(
          code: '59350',
          nom: 'Lille',
          codePostal: '59000',
          latitude: 50.63,
          longitude: 3.06,
        ),
        rayonKm: 30,
      );

      final criteres = CriteresRechercheUtilisateur.fromOnboardingAnswers(answers);

      expect(criteres.metier, MetierTexteLibreCritere('Boulanger'));
      expect(
        criteres.location,
        Location(
          libelle: 'Lille',
          code: '59350',
          type: LocationType.COMMUNE,
          codePostal: '59000',
          latitude: 50.63,
          longitude: 3.06,
        ),
      );
      expect(criteres.rayon, 30);
      expect(criteres.hasAny, isTrue);
    });

    test('should ignore domaine when domaineInconnu', () {
      final answers = const OnboardingQuestionnaireAnswers(
        domaine: 'Boulanger',
        domaineInconnu: true,
        villeRecherche: QuestionnaireCommune(code: '59350', nom: 'Lille'),
      );

      final criteres = CriteresRechercheUtilisateur.fromOnboardingAnswers(answers);

      expect(criteres.metier, isNull);
      expect(criteres.location?.libelle, 'Lille');
    });

    test('should ignore blank domaine', () {
      final answers = const OnboardingQuestionnaireAnswers(domaine: '   ');

      final criteres = CriteresRechercheUtilisateur.fromOnboardingAnswers(answers);

      expect(criteres.metier, isNull);
      expect(criteres.hasAny, isFalse);
    });

    test('should not set rayon without ville', () {
      final answers = const OnboardingQuestionnaireAnswers(domaine: 'Boulanger', rayonKm: 40);

      final criteres = CriteresRechercheUtilisateur.fromOnboardingAnswers(answers);

      expect(criteres.metier, MetierTexteLibreCritere('Boulanger'));
      expect(criteres.location, isNull);
      expect(criteres.rayon, isNull);
    });
  });

  group('CriteresRechercheUtilisateur.copyWith', () {
    test('can clear nullable fields', () {
      final criteres = CriteresRechercheUtilisateur(
        metier: MetierTexteLibreCritere('Boulanger'),
        location: Location(libelle: 'Lille', code: '59350', type: LocationType.COMMUNE),
        rayon: 30,
      );

      final cleared = criteres.copyWith(
        metier: () => null,
        location: () => null,
        rayon: () => null,
      );

      expect(cleared.metier, isNull);
      expect(cleared.location, isNull);
      expect(cleared.rayon, isNull);
    });

    test('keeps fields when callbacks are omitted', () {
      final criteres = CriteresRechercheUtilisateur(
        metier: MetierTexteLibreCritere('Boulanger'),
        location: Location(libelle: 'Lille', code: '59350', type: LocationType.COMMUNE),
        rayon: 30,
      );

      final updated = criteres.copyWith(rayon: () => 50);

      expect(updated.metier, MetierTexteLibreCritere('Boulanger'));
      expect(updated.location?.libelle, 'Lille');
      expect(updated.rayon, 50);
    });
  });
}
