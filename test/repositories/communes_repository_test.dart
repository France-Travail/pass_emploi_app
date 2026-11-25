import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late CommunesRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://geo.api.gouv.fr'));
    adapter = DioAdapter(dio: dio);
    repository = CommunesRepository(httpClient: dio);
  });

  test('searchByName returns empty when query shorter than 3 chars', () async {
    final result = await repository.searchByName('Li');
    expect(result, isEmpty);
  });

  test('searchByName maps communes', () async {
    adapter.onGet(
      '/communes',
      (server) => server.reply(200, [
        {
          'nom': 'Lille',
          'code': '59350',
          'codesPostaux': ['59000'],
          'centre': {
            'type': 'Point',
            'coordinates': [3.057, 50.629],
          },
        },
      ]),
      queryParameters: {
        'nom': 'Lil',
        'boost': 'population',
        'limit': 8,
        'fields': 'nom,code,codesPostaux,centre',
      },
    );

    final result = await repository.searchByName('Lil');

    expect(result.length, 1);
    expect(result.first.nom, 'Lille');
    expect(result.first.code, '59350');
    expect(result.first.codePostal, '59000');
    expect(result.first.latitude, 50.629);
    expect(result.first.longitude, 3.057);
  });

  test('searchByCodePostal maps communes with preferred code postal', () async {
    adapter.onGet(
      '/communes',
      (server) => server.reply(200, [
        {
          'nom': 'Lille',
          'code': '59350',
          'codesPostaux': ['59000', '59160', '59800'],
          'centre': {
            'type': 'Point',
            'coordinates': [3.057, 50.629],
          },
        },
      ]),
      queryParameters: {
        'codePostal': '59160',
        'limit': 8,
        'fields': 'nom,code,codesPostaux,centre',
      },
    );

    final result = await repository.searchByCodePostal('59160');

    expect(result.length, 1);
    expect(result.first.nom, 'Lille');
    expect(result.first.codePostal, '59160');
  });

  test('search routes digits to code postal and text to name', () async {
    adapter.onGet(
      '/communes',
      (server) => server.reply(200, [
        {
          'nom': 'Paris',
          'code': '75056',
          'codesPostaux': ['75001'],
        },
      ]),
      queryParameters: {
        'codePostal': '75001',
        'limit': 8,
        'fields': 'nom,code,codesPostaux,centre',
      },
    );
    adapter.onGet(
      '/communes',
      (server) => server.reply(200, [
        {
          'nom': 'Lille',
          'code': '59350',
          'codesPostaux': ['59000'],
        },
      ]),
      queryParameters: {
        'nom': 'Lil',
        'boost': 'population',
        'limit': 8,
        'fields': 'nom,code,codesPostaux,centre',
      },
    );

    final byCodePostal = await repository.search('75 001');
    final byName = await repository.search('Lil');
    final incompleteCodePostal = await repository.search('590');

    expect(byCodePostal.first.nom, 'Paris');
    expect(byCodePostal.first.codePostal, '75001');
    expect(byName.first.nom, 'Lille');
    expect(incompleteCodePostal, isEmpty);
  });

  test('findByCoordinates returns first commune', () async {
    adapter.onGet(
      '/communes',
      (server) => server.reply(200, [
        {
          'nom': 'Lille',
          'code': '59350',
          'codesPostaux': ['59000'],
        },
      ]),
      queryParameters: {
        'lat': 50.6,
        'lon': 3.0,
        'fields': 'nom,code,codesPostaux,centre',
      },
    );

    final result = await repository.findByCoordinates(
      latitude: 50.6,
      longitude: 3.0,
    );

    expect(result?.nom, 'Lille');
  });

  group('arrondissements', () {
    void givenParis([String query = 'Paris']) {
      adapter.onGet(
        '/communes',
        (server) => server.reply(200, [
          {
            'nom': 'Paris',
            'code': '75056',
            'codesPostaux': ['75001', '75014'],
          },
        ]),
        queryParameters: {
          'nom': query,
          'boost': 'population',
          'limit': 8,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
      adapter.onGet(
        '/communes',
        (server) => server.reply(200, [
          {
            'nom': 'Paris 14e Arrondissement',
            'code': '75114',
            'codesPostaux': ['75014'],
          },
          {
            'nom': 'Paris 2e Arrondissement',
            'code': '75102',
            'codesPostaux': ['75002'],
          },
        ]),
        queryParameters: {
          'nom': 'Paris',
          'type': 'arrondissement-municipal',
          'limit': 20,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
    }

    test('searchByName adds the arrondissements after Paris', () async {
      givenParis();

      final result = await repository.searchByName('Paris');

      expect(result.map((c) => c.code), ['75056', '75102', '75114']);
    });

    test(
      'searchByName keeps only the requested arrondissement when a number is typed',
      () async {
        givenParis('Paris 14');

        final result = await repository.searchByName('Paris 14');

        expect(result.map((c) => c.code), ['75056', '75114']);
      },
    );
  });

  group('communesDuCodePostal', () {
    void givenCommunes(String codePostal, int status, [Object? body]) {
      adapter.onGet(
        '/communes',
        (server) => server.reply(status, body),
        queryParameters: {'codePostal': codePostal, 'fields': 'nom,code,codesPostaux,centre'},
      );
    }

    test('returns the communes of the code postal, sorted by name, with this code postal', () async {
      givenCommunes('14500', 200, [
        {
          'nom': 'Vire Normandie',
          'code': '14762',
          'codesPostaux': ['14500'],
        },
        {
          'nom': 'Écouché-les-Vallées',
          'code': '61153',
          'codesPostaux': ['61150', '14500'],
        },
        {
          'nom': 'Campagnolles',
          'code': '14127',
          'codesPostaux': ['14500'],
        },
      ]);

      final result = await repository.communesDuCodePostal('14500');

      expect(result?.map((c) => c.nom), ['Campagnolles', 'Écouché-les-Vallées', 'Vire Normandie']);
      expect(result?.map((c) => c.codePostal), everyElement('14500'));
    });

    test('Paris code postal gives the whole city, never the arrondissement', () async {
      givenCommunes('75014', 200, [
        {
          'nom': 'Paris',
          'code': '75056',
          'codesPostaux': ['75001', '75014'],
        },
      ]);

      final result = await repository.communesDuCodePostal('75014');

      expect(result?.single.code, '75056');
      expect(result?.single.codePostal, '75014');
      expect(result?.single.nomCourt, 'Paris 14e');
    });

    test('unknown code postal gives an empty list', () async {
      givenCommunes('75000', 200, []);

      expect(await repository.communesDuCodePostal('75000'), isEmpty);
    });

    test('failure gives null, to tell it from an unknown code postal', () async {
      givenCommunes('14500', 500);

      expect(await repository.communesDuCodePostal('14500'), isNull);
    });

    test('not 5 digits: empty, without calling the API', () async {
      expect(await repository.communesDuCodePostal('1450'), isEmpty);
    });
  });

  group('findByCoordinates with preferArrondissement', () {
    void givenCommuneAt(Map<String, dynamic> commune, {String? type}) {
      adapter.onGet(
        '/communes',
        (server) => server.reply(200, [commune]),
        queryParameters: {
          'lat': 48.83,
          'lon': 2.32,
          'type': ?type,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
    }

    test('returns the arrondissement in Paris', () async {
      givenCommuneAt({
        'nom': 'Paris',
        'code': '75056',
        'codesPostaux': ['75001'],
      });
      givenCommuneAt({
        'nom': 'Paris 14e Arrondissement',
        'code': '75114',
        'codesPostaux': ['75014'],
      }, type: 'arrondissement-municipal');

      final result = await repository.findByCoordinates(latitude: 48.83, longitude: 2.32, preferArrondissement: true);

      expect(result?.code, '75114');
      expect(result?.codePostal, '75014');
      expect(result?.nomCourt, 'Paris 14e');
    });

    test('returns the commune elsewhere, and in Paris by default', () async {
      givenCommuneAt({
        'nom': 'Paris',
        'code': '75056',
        'codesPostaux': ['75001'],
      });

      final result = await repository.findByCoordinates(latitude: 48.83, longitude: 2.32);

      expect(result?.code, '75056');
    });
  });
}
