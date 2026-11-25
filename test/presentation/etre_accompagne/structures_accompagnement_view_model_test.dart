import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_actions.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_tracking.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/structures_accompagnement_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:redux/redux.dart';

import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

const _lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');
const _paris18 = QuestionnaireCommune(code: '75118', nom: 'Paris 18e Arrondissement', codePostal: '75018');

StructuresAccompagnementRequest _request(
  StructureAccompagnementType type, {
  QuestionnaireCommune commune = _lille,
  StructuresAccompagnementCommuneOrigine origine = StructuresAccompagnementCommuneOrigine.questionnaire,
}) => StructuresAccompagnementRequest(type: type, commune: commune, origine: origine);

final _missionLocaleRequest = _request(StructureAccompagnementType.missionLocale);
final _franceTravailRequest = _request(StructureAccompagnementType.franceTravail);

const _missionLocale = StructureAccompagnement(
  nom: 'Mission Locale de Lille',
  adresse: StructureAccompagnementAdresse(ligne: '5 Bd du Maréchal Vaillant', codePostal: '59800', ville: 'Lille'),
  telephone: '03 20 00 00 00',
);

const _agence = StructureAccompagnement(
  nom: 'Agence France Travail Lille Vaucanson',
  adresse: StructureAccompagnementAdresse(ligne: '21 Rue Vaucanson', codePostal: '59800', ville: 'Lille'),
  telephone: '39-49',
  horaires: ['Lun–mer · 8h30 – 12h30', 'Jeu · 8h30 – 12h30'],
  horairesAlt: 'Lundi à mercredi ouvert de 8h30 à 12h30, et jeudi ouvert de 8h30 à 12h30.',
);

Store<AppState> _store(StructuresAccompagnementState state) {
  return givenState() //
      .loggedInUser(loginMode: LoginMode.INVITE)
      .copyWith(structuresAccompagnementState: state)
      .store();
}

StructuresAccompagnementViewModel _viewModel(
  Store<AppState> store,
  StructuresAccompagnementRequest request, {
  Platform platform = Platform.ANDROID,
}) {
  return StructuresAccompagnementViewModel.create(store, request, platform: platform);
}

void main() {
  group('display state', () {
    test('loading while the search is pending', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementLoadingState(_missionLocaleRequest)),
        _missionLocaleRequest,
      );

      expect(viewModel.displayState, DisplayState.LOADING);
      expect(viewModel.subtitle, isNull);
      expect(viewModel.intro, isNull);
      expect(viewModel.resultEvent, isNull);
    });

    test('loading while the state belongs to another search', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_franceTravailRequest, [_agence])),
        _missionLocaleRequest,
      );

      expect(viewModel.displayState, DisplayState.LOADING);
      expect(viewModel.items, isEmpty);
    });

    test('failure tracks an error, without the city', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementFailureState(_franceTravailRequest)),
        _franceTravailRequest,
      );

      expect(viewModel.displayState, DisplayState.FAILURE);
      expect(
        viewModel.resultEvent,
        EtreAccompagneTrackingEvent(
          AnalyticsEventNames.etreAccompagneErreurAction('France Travail'),
          name: 'Questionnaire',
        ),
      );
    });

    test('retry dispatches the same search again', () {
      final store = StoreSpy.withState(
        givenState().copyWith(
          structuresAccompagnementState: StructuresAccompagnementFailureState(_missionLocaleRequest),
        ),
      );

      _viewModel(store, _missionLocaleRequest).onRetry();

      expect(store.dispatchedAction, isA<StructuresAccompagnementRequestAction>());
      expect((store.dispatchedAction as StructuresAccompagnementRequestAction).request, _missionLocaleRequest);
    });

    test('empty shows the code postal and tracks 0 result', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_missionLocaleRequest, [])),
        _missionLocaleRequest,
      );

      expect(viewModel.displayState, DisplayState.EMPTY);
      expect(viewModel.emptyTitle, 'Aucune structure trouvée pour le 59000');
      expect(viewModel.emptyMessage, contains('pas de Mission Locale'));
      expect(
        viewModel.resultEvent,
        EtreAccompagneTrackingEvent(
          AnalyticsEventNames.etreAccompagneRechercheAction('Mission Locale'),
          name: 'Questionnaire',
          value: 0,
        ),
      );
    });
  });

  group('Mission Locale', () {
    test('one Mission Locale: title, subtitle, intro and tile without horaires', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_missionLocaleRequest, [_missionLocale])),
        _missionLocaleRequest,
      );

      expect(viewModel.displayState, DisplayState.CONTENT);
      expect(viewModel.title, 'Mission locale');
      expect(viewModel.subtitle, 'La Mission Locale de Lille');
      expect(viewModel.intro, contains('tu peux contacter ta Mission Locale'));
      expect(viewModel.withContact3949, isFalse);
      expect(viewModel.items, [
        StructureAccompagnementItem(
          nom: 'Mission Locale de Lille',
          adresse: '5 Bd du Maréchal Vaillant, 59800 Lille',
          horaires: [],
          horairesA11yLabel: null,
          callLabel: 'Appelle le 03\u00A020\u00A000\u00A000\u00A000',
          callA11yLabel: 'Appelle le 03 20 00 00 00, Mission Locale de Lille',
          callUri: Uri.parse('tel:0320000000'),
          itineraireA11yLabel: 'Voir l’itinéraire vers Mission Locale de Lille',
          itineraireUri: Uri.parse('geo:0,0?q=5%20Bd%20du%20Mar%C3%A9chal%20Vaillant%2C%2059800%20Lille'),
        ),
      ]);
      expect(
        viewModel.resultEvent,
        EtreAccompagneTrackingEvent(
          AnalyticsEventNames.etreAccompagneRechercheAction('Mission Locale'),
          name: 'Questionnaire',
          value: 1,
        ),
      );
    });

    test('several sites of an arrondissement use its short name', () {
      final request = _request(StructureAccompagnementType.missionLocale, commune: _paris18);
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(request, [_missionLocale, _missionLocale])),
        request,
      );

      expect(viewModel.subtitle, 'La Mission Locale de Paris 18e');
      expect(viewModel.intro, startsWith('Deux sites reçoivent les jeunes de Paris 18e.'));
      expect(viewModel.items.length, 2);
    });

    test('whole Paris searched with an arrondissement code postal names the arrondissement', () {
      const paris18 = QuestionnaireCommune(code: '75056', nom: 'Paris', codePostal: '75018');
      final request = _request(StructureAccompagnementType.missionLocale, commune: paris18);
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(request, [_missionLocale])),
        request,
      );

      expect(viewModel.subtitle, 'La Mission Locale de Paris 18e');
    });

    test('without telephone: no call button, itinerary kept', () {
      const sansTelephone = StructureAccompagnement(
        nom: 'Mission Locale sans téléphone',
        adresse: StructureAccompagnementAdresse(ligne: '1 rue', codePostal: '69003', ville: 'Lyon'),
      );
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_missionLocaleRequest, [sansTelephone])),
        _missionLocaleRequest,
      );

      final item = viewModel.items.single;
      expect(item.callLabel, isNull);
      expect(item.callUri, isNull);
      expect(item.itineraireUri, Uri.parse('geo:0,0?q=1%20rue%2C%2069003%20Lyon'));
    });

    test('without address: itinerary searches the structure name', () {
      const sansAdresse = StructureAccompagnement(
        nom: 'Mission Locale de Lyon',
        adresse: StructureAccompagnementAdresse(),
      );
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_missionLocaleRequest, [sansAdresse])),
        _missionLocaleRequest,
        platform: Platform.IOS,
      );

      final item = viewModel.items.single;
      expect(item.adresse, isNull);
      expect(item.itineraireUri, Uri.https('maps.apple.com', '/maps', {'q': 'Mission Locale de Lyon'}));
    });
  });

  group('France Travail', () {
    test('agences with horaires line by line, 3949 always offered', () {
      final request = _request(
        StructureAccompagnementType.franceTravail,
        origine: StructuresAccompagnementCommuneOrigine.geolocalisation,
      );
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(request, [_agence, _agence, _agence])),
        request,
      );

      expect(viewModel.title, 'France Travail');
      expect(viewModel.subtitle, '3 structures près de Lille');
      expect(viewModel.intro, contains('l’une de ces structures'));
      expect(viewModel.withContact3949, isTrue);
      expect(viewModel.contact3949Uri, Uri.parse('tel:3949'));
      expect(viewModel.items.first.horaires, ['Lun–mer · 8h30 – 12h30', 'Jeu · 8h30 – 12h30']);
      expect(
        viewModel.items.first.horairesA11yLabel,
        'Horaires : Lundi à mercredi ouvert de 8h30 à 12h30, et jeudi ouvert de 8h30 à 12h30.',
      );
      // Pas de bouton d'appel par agence : le 3949 est proposé au-dessus.
      expect(viewModel.items.first.callLabel, isNull);
      expect(viewModel.items.first.callUri, isNull);
      expect(
        viewModel.resultEvent,
        EtreAccompagneTrackingEvent(
          AnalyticsEventNames.etreAccompagneRechercheAction('France Travail'),
          name: 'Géolocalisation',
          value: 3,
        ),
      );
    });

    test('without horairesAlt: screen readers get the displayed lines', () {
      const sansAlt = StructureAccompagnement(
        nom: 'Agence France Travail Lille Vaucanson',
        adresse: StructureAccompagnementAdresse(ligne: '21 Rue Vaucanson', codePostal: '59800', ville: 'Lille'),
        horaires: ['Lun–ven · 9h – 17h'],
      );
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_franceTravailRequest, [sansAlt])),
        _franceTravailRequest,
      );

      expect(viewModel.items.single.horairesA11yLabel, 'Horaires : Lun–ven · 9h – 17h');
    });

    test('3949 stays visible on loading failure', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementFailureState(_franceTravailRequest)),
        _franceTravailRequest,
      );

      expect(viewModel.displayState, DisplayState.FAILURE);
      expect(viewModel.withContact3949, isTrue);
    });

    test('one agence uses the singular', () {
      final viewModel = _viewModel(
        _store(StructuresAccompagnementSuccessState(_franceTravailRequest, [_agence])),
        _franceTravailRequest,
      );

      expect(viewModel.subtitle, '1 structure près de Lille');
      expect(viewModel.intro, contains('cette structure'));
    });
  });
}
