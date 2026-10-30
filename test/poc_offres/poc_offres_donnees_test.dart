import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';

void main() {
  Location commune(String nom) => pocCommunes.firstWhere((commune) => commune.libelle == nom);

  PocCriteresMetier criteres(String codeRome, String ville, {int rayon = 30}) {
    return PocCriteresMetier(metier: pocMetierParCode(codeRome)!, lieu: commune(ville), rayon: rayon);
  }

  group('Alternance', () {
    test('boulanger à Lille dans 30 km : les 3 offres de la maquette, puis 4 entreprises', () {
      final offres = pocRechercherOffres(criteres("D1102", "Lille"), const PocFiltresNiveau());

      expect(offres.map((offre) => offre.entreprise), ["BWL", "Desher", "La Boulange"]);
      expect(pocRechercherEntreprises(criteres("D1102", "Lille")), hasLength(4));
    });

    test('élargir le rayon à 50 km ajoute l’offre d’Arras', () {
      final offres = pocRechercherOffres(criteres("D1102", "Lille", rayon: 50), const PocFiltresNiveau());

      expect(offres.map((offre) => offre.lieu.ville), contains("Arras"));
    });

    test('un métier et une ville sans données de démo affichent les exemples de boulanger autour de Lille', () {
      final offres = pocRechercherOffres(criteres("D1202", "Nantes"), const PocFiltresNiveau());

      expect(offres, hasLength(3));
    });

    test('le filtre de niveau s’applique vraiment', () {
      final offres = pocRechercherOffres(criteres("D1102", "Lille"), const PocFiltresNiveau({PocNiveau.bac5}));

      expect(offres, isEmpty);
    });
  });

  group('Formation', () {
    test('boulanger à Lille : 4 formations, dont une sans rendez-vous en ligne', () {
      final formations = pocRechercherFormations(criteres("D1102", "Lille"), const PocFiltresNiveau());

      expect(formations, hasLength(4));
      expect(formations.where((formation) => !formation.rendezVousPossible), hasLength(1));
    });
  });

  group('Bénévolat', () {
    test('« Depuis chez moi » ne garde que les missions à distance', () {
      final missions = pocRechercherMissions(
        PocCriteresBenevolat(activite: null, lieu: commune("Lille")),
        const PocFiltresBenevolat(types: {PocTypeMission.depuisChezMoi}),
      );

      expect(missions.every((mission) => mission.aDistance), isTrue);
      expect(missions, hasLength(3));
    });

    test('chaque activité de la liste donne au moins une mission', () {
      for (final activite in pocActivites) {
        final missions = pocRechercherMissions(
          PocCriteresBenevolat(activite: activite, lieu: commune("Lille")),
          const PocFiltresBenevolat(),
        );

        expect(missions, isNotEmpty, reason: activite);
      }
    });

    test('une ville loin de Lille donne les mêmes missions que Lille', () {
      final aParis = pocRechercherMissions(PocCriteresBenevolat(activite: null, lieu: commune("Paris")), const PocFiltresBenevolat());
      final aLille = pocRechercherMissions(PocCriteresBenevolat(activite: null, lieu: commune("Lille")), const PocFiltresBenevolat());

      expect(aParis, aLille);
    });
  });

  group('Liste de métiers', () {
    test('« commerce » propose les métiers de la vente', () {
      expect(pocMetiersCorrespondants("commerce").map((metier) => metier.codeRome), contains("D1106"));
    });

    test('la saisie ignore les accents', () {
      expect(pocMetiersCorrespondants("boulangere").map((metier) => metier.codeRome), ["D1102"]);
    });
  });
}
