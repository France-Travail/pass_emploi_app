import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

enum AvisMetier { meTente, pasPourMoi }

enum RaisonPasPourMoi {
  interet('Ça ne m’intéresse pas'),
  conditions('Les conditions de travail (horaires, efforts…)'),
  formation('La formation est trop longue'),
  salaire('Le salaire'),
  teste('Je l’ai testé et ça ne m’a pas plu'),
  autre('Une autre raison');

  const RaisonPasPourMoi(this.libelle);

  final String libelle;
}

// Les étapes choisies pour l'orientation : découvrir, tester, se former (les idées viennent du test et des centres
// d'intérêt, et « se lancer » renvoie vers les offres).
enum EtapePiste { decouvrir, tester, seFormer }

enum ActionPiste {
  lireFiche(EtapePiste.decouvrir),
  voirVideo(EtapePiste.decouvrir),
  echangerAvecUnPro(EtapePiste.tester),
  faireUneImmersion(EtapePiste.tester),
  regarderLesFormations(EtapePiste.seFormer);

  const ActionPiste(this.etape);

  final EtapePiste etape;

  // Après un échange avec un pro ou une immersion, on demande au jeune si le métier le tente toujours.
  bool get estUnTest => etape == EtapePiste.tester;
}

class Piste extends Equatable {
  const Piste({required this.metier, required this.avis, this.raisons = const {}, this.faites = const {}});

  final RomeMetierResume metier;
  final AvisMetier avis;
  final Set<RaisonPasPourMoi> raisons;
  final Set<ActionPiste> faites;

  static int get nombreActions => ActionPiste.values.length;

  String get code => metier.code;

  int get nombreFaites => faites.length;

  ActionPiste? get prochaineAction => ActionPiste.values.where((action) => !faites.contains(action)).firstOrNull;

  // null quand toutes les étapes sont faites : il reste à se lancer.
  EtapePiste? get etapeEnCours => prochaineAction?.etape;

  Piste copyWith({AvisMetier? avis, Set<RaisonPasPourMoi>? raisons, Set<ActionPiste>? faites}) {
    return Piste(
      metier: metier,
      avis: avis ?? this.avis,
      raisons: raisons ?? this.raisons,
      faites: faites ?? this.faites,
    );
  }

  Map<String, dynamic> toJson() => {
    'metier': {
      'code': metier.code,
      'libelle': metier.libelle,
      'riasecMajeur': metier.riasecMajeur,
      'riasecMineur': metier.riasecMineur,
      'grandDomaine': metier.grandDomaine,
    },
    'avis': avis.name,
    'raisons': [for (final raison in raisons) raison.name],
    'faites': [for (final action in faites) action.name],
  };

  // Lecture tolérante : une valeur inconnue (version précédente du POC) est ignorée plutôt que de tout perdre.
  static Piste? fromJson(dynamic json) {
    final metier = json is Map ? json['metier'] : null;
    final avis = AvisMetier.values.where((valeur) => valeur.name == json?['avis']).firstOrNull;
    if (metier is! Map || metier['code'] is! String || metier['libelle'] is! String || avis == null) return null;
    return Piste(
      metier: RomeMetierResume(
        code: metier['code'] as String,
        libelle: metier['libelle'] as String,
        riasecMajeur: metier['riasecMajeur'] as String?,
        riasecMineur: metier['riasecMineur'] as String?,
        grandDomaine: metier['grandDomaine'] as String?,
      ),
      avis: avis,
      raisons: _valeurs(RaisonPasPourMoi.values, json['raisons']),
      faites: _valeurs(ActionPiste.values, json['faites']),
    );
  }

  static Set<T> _valeurs<T extends Enum>(List<T> valeurs, dynamic noms) {
    if (noms is! List) return {};
    return {for (final nom in noms) ...valeurs.where((valeur) => valeur.name == nom)};
  }

  @override
  List<Object?> get props => [metier, avis, raisons, faites];
}

class MesPistesEtat extends Equatable {
  const MesPistesEtat({this.pistes = const [], this.scoresRiasec, this.centresInteret = const []});

  final List<Piste> pistes;
  final Map<Riasec, int>? scoresRiasec;
  final List<String> centresInteret;

  List<Piste> get quiTentent => pistes.where((piste) => piste.avis == AvisMetier.meTente).toList();

  List<Piste> get misDeCote => pistes.where((piste) => piste.avis == AvisMetier.pasPourMoi).toList();

  Piste? piste(String code) => pistes.where((piste) => piste.code == code).firstOrNull;

  RiasecProfil? get profilRiasec => scoresRiasec == null ? null : RiasecProfil.depuisScores(scoresRiasec!);

  bool get aQuelqueChoseAPartager => pistes.isNotEmpty || (profilRiasec != null && !profilRiasec!.estPlat);

  MesPistesEtat copyWith({List<Piste>? pistes, Map<Riasec, int>? scoresRiasec, List<String>? centresInteret}) {
    return MesPistesEtat(
      pistes: pistes ?? this.pistes,
      scoresRiasec: scoresRiasec ?? this.scoresRiasec,
      centresInteret: centresInteret ?? this.centresInteret,
    );
  }

  Map<String, dynamic> toJson() => {
    'pistes': [for (final piste in pistes) piste.toJson()],
    if (scoresRiasec case final scores?)
      'riasec': {for (final entree in scores.entries) entree.key.lettre: entree.value},
    'centresInteret': centresInteret,
  };

  static MesPistesEtat lire(String? brut) {
    if (brut == null || brut.isEmpty) return const MesPistesEtat();
    try {
      final json = jsonDecode(brut);
      final riasec = json['riasec'];
      return MesPistesEtat(
        pistes: [for (final piste in (json['pistes'] as List? ?? const [])) ?Piste.fromJson(piste)],
        scoresRiasec: riasec is Map
            ? {
                for (final type in Riasec.values)
                  if (riasec[type.lettre] case final int score) type: score,
              }
            : null,
        centresInteret: [
          for (final centre in (json['centresInteret'] as List? ?? const []))
            if (centre is String) centre,
        ],
      );
    } catch (_) {
      return const MesPistesEtat();
    }
  }

  @override
  List<Object?> get props => [pistes, scoresRiasec, centresInteret];
}

// Les pistes du jeune : gardées sur son téléphone, au nom de son compte, jamais envoyées à un serveur (sauf s'il les
// partage à son conseiller). En mode démo, rien n'est écrit sur le téléphone et tout repart de zéro à chaque entrée.
class MesPistes extends ValueNotifier<MesPistesEtat> {
  MesPistes._() : super(const MesPistesEtat());

  static final instance = MesPistes._();

  static const _prefixeCle = 'poc_orientation_mes_pistes_';

  FlutterSecureStorage? _stockage;
  String? _jeune;
  bool _demo = false;

  void utiliser(FlutterSecureStorage stockage) => _stockage = stockage;

  void demarrerDemo() {
    _demo = true;
    _jeune = null;
    value = const MesPistesEtat();
  }

  // Appelée à l'ouverture des écrans du POC : recharge les pistes quand le compte a changé.
  Future<void> ouvrirSession({required String? jeune, required bool demo}) async {
    if (demo) {
      if (!_demo) demarrerDemo();
      return;
    }
    if (jeune == null || (!_demo && _jeune == jeune)) return;
    _demo = false;
    _jeune = jeune;
    value = const MesPistesEtat();
    final brut = await _stockage?.read(key: '$_prefixeCle$jeune');
    if (_jeune == jeune) value = MesPistesEtat.lire(brut);
  }

  void meTente(RomeMetierResume metier) {
    _modifier(
      metier,
      (piste) =>
          piste.copyWith(avis: AvisMetier.meTente, raisons: {}, faites: {...piste.faites, ActionPiste.lireFiche}),
    );
  }

  void pasPourMoi(RomeMetierResume metier, Set<RaisonPasPourMoi> raisons) {
    _modifier(metier, (piste) => piste.copyWith(avis: AvisMetier.pasPourMoi, raisons: raisons));
  }

  void oublier(String code) {
    _changer(value.copyWith(pistes: value.pistes.where((piste) => piste.code != code).toList()));
  }

  void marquer(String code, ActionPiste action, {required bool faite}) {
    final piste = value.piste(code);
    if (piste == null) return;
    final faites = faite ? {...piste.faites, action} : piste.faites.where((autre) => autre != action).toSet();
    _remplacer(piste.copyWith(faites: faites));
  }

  void enregistrerProfilRiasec(Map<Riasec, int> scores) => _changer(value.copyWith(scoresRiasec: {...scores}));

  void enregistrerCentresInteret(List<String> centres) => _changer(value.copyWith(centresInteret: [...centres]));

  void _modifier(RomeMetierResume metier, Piste Function(Piste piste) modification) {
    final existante = value.piste(metier.code) ?? Piste(metier: metier, avis: AvisMetier.meTente);
    _remplacer(modification(existante));
  }

  // Une piste garde sa place dans la liste quand on la modifie ; une nouvelle arrive en dernier.
  void _remplacer(Piste piste) {
    final dejaLa = value.piste(piste.code) != null;
    _changer(
      value.copyWith(
        pistes: dejaLa
            ? [for (final autre in value.pistes) autre.code == piste.code ? piste : autre]
            : [...value.pistes, piste],
      ),
    );
  }

  void _changer(MesPistesEtat etat) {
    value = etat;
    if (_demo || _jeune == null) return;
    _stockage?.write(key: '$_prefixeCle$_jeune', value: jsonEncode(etat.toJson()));
  }

  @visibleForTesting
  void reinitialiser() {
    _stockage = null;
    _jeune = null;
    _demo = false;
    value = const MesPistesEtat();
  }
}
