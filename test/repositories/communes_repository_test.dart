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

    final result = await repository.findByCoordinates(latitude: 50.6, longitude: 3.0);

    expect(result?.nom, 'Lille');
  });
}
