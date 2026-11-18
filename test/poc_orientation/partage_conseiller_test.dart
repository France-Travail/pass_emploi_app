import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/partage_conseiller.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

void main() {
  test('le message résume les pistes, ce qui est mis de côté et le profil, en vouvoyant le conseiller', () {
    final etat = MesPistesEtat(
      pistes: [
        Piste(
          metier: const RomeMetierResume(code: 'D1102', libelle: 'Boulanger / Boulangère'),
          avis: AvisMetier.meTente,
          faites: {ActionPiste.lireFiche, ActionPiste.voirVideo, ActionPiste.echangerAvecUnPro},
        ),
        const Piste(
          metier: RomeMetierResume(code: 'K2111', libelle: 'Animateur / Animatrice petite enfance'),
          avis: AvisMetier.meTente,
          faites: {ActionPiste.lireFiche},
        ),
        const Piste(
          metier: RomeMetierResume(code: 'D1208', libelle: 'Esthéticien / Esthéticienne'),
          avis: AvisMetier.pasPourMoi,
          raisons: {RaisonPasPourMoi.conditions, RaisonPasPourMoi.teste},
        ),
      ],
      scoresRiasec: {Riasec.social: 9, Riasec.realiste: 7, Riasec.artiste: 2},
      centresInteret: ['Cuisiner', 'Aider les autres'],
    );

    expect(
      messagePourLeConseiller(etat),
      'Bonjour, je vous partage où j’en suis dans mes pistes de métiers.\n'
      '\n'
      'Les métiers qui me tentent :\n'
      '- Boulanger / Boulangère : je le teste (3 étapes sur 5)\n'
      '- Animateur / Animatrice petite enfance : je le découvre (1 étape sur 5)\n'
      '\n'
      'Les métiers que j’ai mis de côté :\n'
      '- Esthéticien / Esthéticienne : les conditions de travail (horaires, efforts…) ; je l’ai testé et ça ne m’a pas plu\n'
      '\n'
      'Mon profil au test RIASEC : Social et Réaliste.\n'
      'Mes centres d’intérêt : Cuisiner, Aider les autres.\n'
      '\n'
      'Pourrons-nous en parler ensemble ?',
    );
  });

  test('sans profil ni centres d’intérêt, le message ne parle que des pistes', () {
    const etat = MesPistesEtat(
      pistes: [
        Piste(
          metier: RomeMetierResume(code: 'D1102', libelle: 'Boulanger / Boulangère'),
          avis: AvisMetier.meTente,
          faites: {
            ActionPiste.lireFiche,
            ActionPiste.voirVideo,
            ActionPiste.echangerAvecUnPro,
            ActionPiste.faireUneImmersion,
            ActionPiste.regarderLesFormations,
          },
        ),
      ],
    );

    expect(
      messagePourLeConseiller(etat),
      'Bonjour, je vous partage où j’en suis dans mes pistes de métiers.\n'
      '\n'
      'Les métiers qui me tentent :\n'
      '- Boulanger / Boulangère : j’ai fait toutes les étapes (5 étapes sur 5)\n'
      '\n'
      'Pourrons-nous en parler ensemble ?',
    );
  });

  test('en démo, le message partagé s’ajoute à la messagerie fictive, puis repart de zéro', () {
    PocMessagesDemo.vider();

    PocMessagesDemo.ajouter('Bonjour');

    expect(PocMessagesDemo.messages.single.content, 'Bonjour');
    PocMessagesDemo.vider();
    expect(PocMessagesDemo.messages, isEmpty);
  });
}
