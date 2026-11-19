import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/poc_orientation/conseils_freins.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/resume_metier.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

RomeFicheMetier _fiche(String fichier) {
  return RomeFicheMetier.fromJson(jsonDecode(File('assets/mode_demo/$fichier.json').readAsStringSync()));
}

void main() {
  final boulanger = _fiche('poc_orientation_fiche_metier');
  final chefDeRayon = _fiche('poc_orientation_fiche_D1502');

  test('le résumé dit ce qu’on fait au quotidien plutôt que la définition générale', () {
    expect(
      phraseDuMetier(boulanger),
      'Prépare et réalise des produits de boulangerie et de viennoiserie selon les règles d\'hygiène et de sécurité '
      'alimentaires',
    );
  });

  test('l’accès garde la première phrase, sans « Cet emploi est accessible avec »', () {
    expect(resumeAcces(boulanger), 'un CAP Boulanger ou un Brevet Professionnel Boulanger');
    expect(
      resumeAcces(chefDeRayon),
      'un diplôme de niveau Bac +2 à Bac + 3 dans le domaine du commerce, un titre professionnel Responsable de '
      'rayon peut également être pertinent',
    );
  });

  test('les conditions qui comptent passent en premier, 3 au plus, avec des mots courts', () {
    expect(conditionsMarquantes(boulanger), ['Travail de nuit', 'Week-ends et jours fériés', 'Charges lourdes']);
    expect(conditionsMarquantes(chefDeRayon), ['Week-ends et jours fériés', 'Charges lourdes', 'Debout longtemps']);
  });

  test('le conseil santé nomme les vrais efforts du métier', () {
    final efforts = effortsPhysiques(boulanger);
    expect(efforts, ['porter des charges lourdes', 'rester debout longtemps', 'travailler la nuit']);

    const reponses = OnboardingQuestionnaireAnswers(freins: {QuestionnaireFrein.sante});
    expect(
      conseilsPourEtape(EtapePiste.decouvrir, reponses, sansDiplome: false, efforts: efforts),
      [
        'Ce métier demande de porter des charges lourdes, rester debout longtemps et travailler la nuit. Pense à ta '
            'santé, et parles-en à ton conseiller.',
      ],
    );
  });

  test('chaque fiche de la démo donne un résumé lisible', () {
    final fichiers = Directory('assets/mode_demo')
        .listSync()
        .map((fichier) => fichier.uri.pathSegments.last)
        .where((nom) => nom.startsWith('poc_orientation_fiche_'))
        .map((nom) => nom.replaceAll('.json', ''));
    for (final fichier in fichiers) {
      final fiche = _fiche(fichier);
      expect(phraseDuMetier(fiche), isNotEmpty, reason: fichier);
      final acces = resumeAcces(fiche);
      expect(acces, isNotNull, reason: fichier);
      expect(acces, isNot(contains('accessible')), reason: '$fichier : $acces');
      expect(acces, isNot(endsWith('.')), reason: '$fichier : $acces');
    }
  });
}
