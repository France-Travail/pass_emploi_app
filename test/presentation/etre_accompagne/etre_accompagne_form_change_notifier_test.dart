import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_form_change_notifier.dart';

const _vire = QuestionnaireCommune(code: '14762', nom: 'Vire Normandie', codePostal: '14500');
const _campagnolles = QuestionnaireCommune(code: '14127', nom: 'Campagnolles', codePostal: '14500');
const _lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');
const _paris = QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75001');
const _paris14 = QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75014');
const _paris15Arrondissement = QuestionnaireCommune(
  code: '75115',
  nom: 'Paris 15e Arrondissement',
  codePostal: '75015',
);

StructuresAccompagnementRequest _request(QuestionnaireCommune commune, StructuresAccompagnementCommuneOrigine origine) {
  return StructuresAccompagnementRequest(
    type: StructureAccompagnementType.missionLocale,
    commune: commune,
    origine: origine,
  );
}

void main() {
  group('pré-remplissage', () {
    test('code postal of the questionnaire commune, no structure selected, submit disabled', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire);

      expect(form.codePostal, '14500');
      expect(form.commune, _vire);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.questionnaire);
      expect(form.type, isNull);
      expect(form.canSubmit, isFalse);
      expect(form.submit(), isNull);
      expect(form.codePostalError, isNull);
    });

    test('an arrondissement is sent as its whole city with its code postal', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _paris15Arrondissement)
        ..selectType(StructureAccompagnementType.missionLocale);

      expect(form.codePostal, '75015');
      expect(
        form.submit(),
        _request(
          const QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75015'),
          StructuresAccompagnementCommuneOrigine.questionnaire,
        ),
      );
    });

    test('whole Paris has no reliable code postal: nothing is prefilled', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _paris);

      expect(form.codePostal, isEmpty);
      expect(form.commune, isNull);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.saisie);
    });

    test('empty when the questionnaire commune was skipped', () {
      final form = EtreAccompagneFormChangeNotifier();

      expect(form.codePostal, isEmpty);
      expect(form.commune, isNull);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.saisie);
    });

    test('offline: the questionnaire commune is used as is', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)
        ..selectType(StructureAccompagnementType.missionLocale)
        ..setCommunes('14500', null);

      expect(form.submit(), _request(_vire, StructuresAccompagnementCommuneOrigine.questionnaire));
    });

    test('several communes: the questionnaire one stays chosen', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)
        ..setCommunes('14500', [_campagnolles, _vire]);

      expect(form.showCommuneChoice, isTrue);
      expect(form.commune, _vire);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.questionnaire);
    });
  });

  group('saisie du code postal', () {
    test('Paris 75014: no arrondissement to choose, the whole city is sent with this code postal', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..updateCodePostal('75014')
        ..setCommunes('75014', [_paris14])
        ..selectType(StructureAccompagnementType.missionLocale);

      expect(form.showCommuneChoice, isFalse);
      expect(form.submit(), _request(_paris14, StructuresAccompagnementCommuneOrigine.saisie));
      expect(form.codePostalError, isNull);
    });

    test('less than 5 digits', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..updateCodePostal('5900')
        ..selectType(StructureAccompagnementType.missionLocale);

      expect(form.needsCommunes, isFalse);
      expect(form.submit(), isNull);
      expect(form.codePostalError, 'Saisis un code postal à 5 chiffres.');
    });

    test('unknown code postal', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..updateCodePostal('75000')
        ..setCommunes('75000', [])
        ..selectType(StructureAccompagnementType.missionLocale);

      expect(form.submit(), isNull);
      expect(form.codePostalError, 'Aucune commune ne correspond à ce code postal.');
    });

    test('communes could not be checked', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..updateCodePostal('59000')
        ..setCommunes('59000', null)
        ..selectType(StructureAccompagnementType.missionLocale);

      expect(form.needsCommunes, isTrue);
      expect(form.submit(), isNull);
      expect(form.codePostalError, 'Impossible de vérifier ce code postal. Vérifie ta connexion puis réessaie.');
    });

    test('several communes: one must be chosen', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..updateCodePostal('14500')
        ..setCommunes('14500', [_campagnolles, _vire])
        ..selectType(StructureAccompagnementType.franceTravail);

      expect(form.showCommuneChoice, isTrue);
      expect(form.commune, isNull);
      expect(form.submit(), isNull);
      expect(form.communeError, 'Choisis ta commune.');

      form.selectCommune(_campagnolles);

      expect(form.communeError, isNull);
      expect(form.submit()?.commune, _campagnolles);
    });

    test('a late answer for a previous code postal is ignored', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..updateCodePostal('14500')
        ..updateCodePostal('59000')
        ..setCommunes('14500', [_campagnolles, _vire]);

      expect(form.communes, isNull);
      expect(form.needsCommunes, isTrue);
    });

    test('typing again clears the errors, the communes and the choice', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)
        ..selectType(StructureAccompagnementType.missionLocale)
        ..updateCodePostal('1450');

      expect(form.commune, isNull);
      expect(form.submit(), isNull);
      expect(form.codePostalError, isNotNull);

      form.updateCodePostal('14500');

      expect(form.codePostalError, isNull);
      expect(form.communes, isNull);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.saisie);
    });
  });

  group('géolocalisation', () {
    test('failure flag, then the commune found replaces the code postal', () {
      final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)..startGeolocation();

      expect(form.isGeolocating, isTrue);

      form.endGeolocation(failed: true);

      expect(form.isGeolocating, isFalse);
      expect(form.geolocationFailed, isTrue);

      form
        ..startGeolocation()
        ..endGeolocation(failed: false)
        ..applyGeolocatedCommune(_lille);

      expect(form.geolocationFailed, isFalse);
      expect(form.codePostal, '59000');
      expect(form.commune, _lille);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.geolocalisation);
    });

    test('an arrondissement found gives its code postal and the whole city', () {
      final form = EtreAccompagneFormChangeNotifier()..applyGeolocatedCommune(_paris15Arrondissement);

      expect(form.codePostal, '75015');
      expect(form.commune, const QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75015'));
    });

    test('several communes: the geolocated one stays chosen', () {
      final form = EtreAccompagneFormChangeNotifier()
        ..applyGeolocatedCommune(_campagnolles)
        ..setCommunes('14500', [_campagnolles, _vire]);

      expect(form.commune, _campagnolles);
      expect(form.origine, StructuresAccompagnementCommuneOrigine.geolocalisation);
    });
  });
}
