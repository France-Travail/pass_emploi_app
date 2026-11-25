import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_form_change_notifier.dart';

const _vire = QuestionnaireCommune(code: '14762', nom: 'Vire Normandie', codePostal: '14500');
const _lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');
const _paris = QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75001');
const _paris15 = QuestionnaireCommune(code: '75115', nom: 'Paris 15e Arrondissement', codePostal: '75015');

void main() {
  test('prefilled with the questionnaire commune, no structure selected, submit disabled', () {
    final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire);

    expect(form.query, 'Vire Normandie (14500)');
    expect(form.commune, _vire);
    expect(form.origine, StructuresAccompagnementCommuneOrigine.questionnaire);
    expect(form.type, isNull);
    expect(form.canSubmit, isFalse);
    expect(form.submit(), isNull);
    expect(form.error, isNull);
  });

  test('empty when the questionnaire commune was skipped', () {
    final form = EtreAccompagneFormChangeNotifier();

    expect(form.query, isEmpty);
    expect(form.commune, isNull);
    expect(form.origine, StructuresAccompagnementCommuneOrigine.saisie);
  });

  test('typed text without choosing in the list shows an error', () {
    final form = EtreAccompagneFormChangeNotifier()
      ..updateQuery('Lille')
      ..selectType(StructureAccompagnementType.missionLocale);

    expect(form.canSubmit, isTrue);
    expect(form.submit(), isNull);
    expect(form.error, 'Choisis ta ville dans la liste.');
  });

  test('typing again clears the error and the previous choice', () {
    final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)
      ..selectType(StructureAccompagnementType.missionLocale)
      ..updateQuery('Vir');

    expect(form.commune, isNull);
    expect(form.submit(), isNull);

    form.updateQuery('Vire');

    expect(form.error, isNull);
  });

  test('a commune chosen in the list builds the search', () {
    final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)
      ..selectCommune(_lille, StructuresAccompagnementCommuneOrigine.saisie)
      ..selectType(StructureAccompagnementType.franceTravail);

    expect(form.query, 'Lille (59000)');
    expect(
      form.submit(),
      StructuresAccompagnementRequest(
        type: StructureAccompagnementType.franceTravail,
        commune: _lille,
        origine: StructuresAccompagnementCommuneOrigine.saisie,
      ),
    );
    expect(form.error, isNull);
  });

  test('a whole city with arrondissements asks for the arrondissement, then the search succeeds', () {
    final form = EtreAccompagneFormChangeNotifier(initialCommune: _paris)
      ..selectType(StructureAccompagnementType.missionLocale);

    expect(form.submit(), isNull);
    expect(form.error, 'Précise ton arrondissement.');

    form.selectCommune(_paris15, StructuresAccompagnementCommuneOrigine.saisie);

    expect(form.error, isNull);
    expect(form.submit()?.commune, _paris15);
  });

  test('geolocation: failure flag, then the commune found replaces the field', () {
    final form = EtreAccompagneFormChangeNotifier(initialCommune: _vire)..startGeolocation();

    expect(form.isGeolocating, isTrue);

    form.endGeolocation(failed: true);

    expect(form.isGeolocating, isFalse);
    expect(form.geolocationFailed, isTrue);

    form.startGeolocation();
    form.endGeolocation(failed: false);
    form.selectCommune(_lille, StructuresAccompagnementCommuneOrigine.geolocalisation);

    expect(form.geolocationFailed, isFalse);
    expect(form.query, 'Lille (59000)');
    expect(form.origine, StructuresAccompagnementCommuneOrigine.geolocalisation);
  });
}
