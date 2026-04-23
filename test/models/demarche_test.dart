import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/demarche.dart';

void main() {
  group('demarche personnalisee', () {
    test('should use description attribute as title', () {
      final demarche = Demarche.fromJson({
        "id": "1",
        "codeDemarche": "eyJxdW9pIjoiUTAxIiwiY29tbWVudCI6IkMwMS4wNSJ9",
        "contenu": "Identification de ses compétences avec pole-emploi.fr",
        "dateModification": null,
        "statut": "EN_COURS",
        "dateFin": "2021-12-21T09:00:00.000Z",
        "label": "Mon (nouveau) métier",
        "titre": "Action issue de l'application CEJ",
        "sousTitre": "Par un autre moyen",
        "dateCreation": "2022-05-11T09:04:00.000Z",
        "attributs": [
          {"cle": "description", "valeur": "Rédiger mon CV"},
          {"cle": "ou", "valeur": "Paris"},
          {"cle": "autre", "valeur": "valeur ignorée"},
        ],
        "statutsPossibles": ["ANNULEE", "REALISEE", "A_FAIRE", "EN_COURS"],
        "modifieParConseiller": false,
        "creeeParConseiller": true,
        "promptIa": "Je suis un prompt IA",
      });
      expect(demarche.titre, "Rédiger mon CV");
      expect(demarche.attributs, [DemarcheAttribut(key: 'ou', value: 'Paris')]);
      expect(demarche.promptIa, null);
    });

    test('should have null title when description attribute is missing', () {
      final demarche = Demarche.fromJson({
        "id": "1",
        "contenu": null,
        "dateModification": null,
        "statut": "EN_COURS",
        "dateFin": null,
        "label": null,
        "titre": "Action issue de l'application CEJ",
        "sousTitre": null,
        "dateCreation": null,
        "attributs": [
          {"cle": "ou", "valeur": "Lyon"},
        ],
        "statutsPossibles": [],
        "modifieParConseiller": false,
        "creeeParConseiller": false,
      });
      expect(demarche.titre, isNull);
      expect(demarche.attributs, [DemarcheAttribut(key: 'ou', value: 'Lyon')]);
    });

    test('should have empty attributs when no ou attribute', () {
      final demarche = Demarche.fromJson({
        "id": "1",
        "contenu": null,
        "dateModification": null,
        "statut": "EN_COURS",
        "dateFin": null,
        "label": null,
        "titre": "Action issue de l'application CEJ",
        "sousTitre": null,
        "dateCreation": null,
        "attributs": [
          {"cle": "description", "valeur": "Appeler Pôle emploi"},
        ],
        "statutsPossibles": [],
        "modifieParConseiller": false,
        "creeeParConseiller": false,
      });
      expect(demarche.titre, "Appeler Pôle emploi");
      expect(demarche.attributs, isEmpty);
    });
  });
}
