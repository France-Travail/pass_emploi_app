import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/location.dart';

// POC « bénévolat, alternance et formation » : données en dur, utilisées en mode démo seulement.
// Les champs reprennent ce que renvoient l'API Engagement (missions) et l'API de La bonne alternance.

class PocMetier extends Equatable {
  final String codeRome;
  final String libelle;
  final List<String> motsCles;

  const PocMetier({required this.codeRome, required this.libelle, this.motsCles = const []});

  bool correspond(String saisie) {
    final mots = sansAccents(saisie).split(RegExp(r'\s+')).where((mot) => mot.isNotEmpty);
    final texte = sansAccents([libelle, ...motsCles].join(' '));
    return mots.every(texte.contains);
  }

  @override
  List<Object?> get props => [codeRome];
}

class PocLieu {
  final String adresse;
  final String codePostal;
  final String ville;
  final double latitude;
  final double longitude;

  const PocLieu({
    required this.adresse,
    required this.codePostal,
    required this.ville,
    required this.latitude,
    required this.longitude,
  });

  String get codePostalEtVille => "$codePostal $ville";

  String get adresseComplete => "$adresse, $codePostal $ville";

  double distanceDepuis(Location location) {
    return distanceKm(latitude, longitude, location.latitude ?? latitude, location.longitude ?? longitude);
  }
}

enum PocNiveau {
  cap("CAP, BEP (Infrabac)"),
  bac("Bac, Bac pro, BP (Bac)"),
  bac2("BTS, DEUST (Bac+2)"),
  bac3("Licence, BUT, Licence pro (Bac+3)"),
  bac5("Master, titre ingénieur, grande école (Bac+5)");

  final String libelle;

  const PocNiveau(this.libelle);
}

enum PocTypeMission { presDeChezMoi, depuisChezMoi }

class PocMission {
  final String id;
  final String titre;
  final String organisation;
  final String organisationDescription;
  final String domaine;
  final String activite;
  final PocLieu? lieu;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String? engagement;
  final String rythme;
  final String? rythmeDetail;
  final int places;
  final List<String> prerequis;
  final List<String> publicAide;
  final bool ouverteAuxMineurs;
  final bool accessiblePmr;
  final List<String> description;
  final String? accroche;
  final String url;

  const PocMission({
    required this.id,
    required this.titre,
    required this.organisation,
    required this.organisationDescription,
    required this.domaine,
    required this.activite,
    required this.lieu,
    required this.dateDebut,
    this.dateFin,
    this.engagement,
    required this.rythme,
    this.rythmeDetail,
    required this.places,
    this.prerequis = const [],
    required this.publicAide,
    required this.ouverteAuxMineurs,
    required this.accessiblePmr,
    required this.description,
    this.accroche,
    required this.url,
  });

  bool get aDistance => lieu == null;
}

class PocOffreAlternance {
  final String id;
  final String codeRome;
  final String titre;
  final String entreprise;
  final PocLieu lieu;
  final String typeContrat;
  final String debut;
  final String duree;
  final PocNiveau niveau;
  final List<String> description;
  final List<String> qualites;
  final List<String> competencesAcquises;
  final List<String> domainesTechniques;
  final String accessibleA;
  final String tailleEntreprise;
  final String secteur;
  final String? siteWeb;

  // Sans candidature simplifiée (offre France Travail reprise par La bonne alternance, par exemple),
  // le jeune postule sur le site de l'offre.
  final bool candidatureSimplifiee;
  final String? urlPostulation;

  const PocOffreAlternance({
    required this.id,
    required this.codeRome,
    required this.titre,
    required this.entreprise,
    required this.lieu,
    required this.typeContrat,
    required this.debut,
    required this.duree,
    required this.niveau,
    required this.description,
    required this.qualites,
    required this.competencesAcquises,
    required this.domainesTechniques,
    required this.accessibleA,
    required this.tailleEntreprise,
    required this.secteur,
    this.siteWeb,
    required this.candidatureSimplifiee,
    this.urlPostulation,
  });
}

class PocEntreprise {
  final String id;
  final List<String> codesRome;
  final String nom;
  final String secteur;
  final String taille;
  final PocLieu lieu;
  final bool candidatureSimplifiee;
  final String? telephone;

  const PocEntreprise({
    required this.id,
    required this.codesRome,
    required this.nom,
    required this.secteur,
    required this.taille,
    required this.lieu,
    required this.candidatureSimplifiee,
    this.telephone,
  });
}

class PocFormation {
  final String id;
  final List<String> codesRome;
  final String intitule;
  final String diplome;
  final PocNiveau niveau;
  final String organisme;
  final PocLieu lieu;
  final String debut;
  final String duree;
  final List<String> competences;
  final List<String> objectifs;
  final String telephone;
  final String email;
  final bool rendezVousPossible;

  const PocFormation({
    required this.id,
    required this.codesRome,
    required this.intitule,
    required this.diplome,
    required this.niveau,
    required this.organisme,
    required this.lieu,
    required this.debut,
    required this.duree,
    required this.competences,
    required this.objectifs,
    required this.telephone,
    required this.email,
    required this.rendezVousPossible,
  });
}

class PocCriteresBenevolat extends Equatable {
  final String? activite;
  final Location lieu;

  const PocCriteresBenevolat({required this.activite, required this.lieu});

  String get libelle => activite != null ? "$activite - ${lieu.libelle}" : lieu.libelle;

  @override
  List<Object?> get props => [activite, lieu];
}

class PocCriteresMetier extends Equatable {
  final PocMetier metier;
  final Location lieu;
  final int rayon;

  const PocCriteresMetier({required this.metier, required this.lieu, required this.rayon});

  String get libelle => "${metier.libelle} - ${lieu.libelle}";

  String get libelleAvecRayon => "$libelle ($rayon km)";

  @override
  List<Object?> get props => [metier, lieu, rayon];
}

class PocFiltresBenevolat extends Equatable {
  final Set<PocTypeMission> types;
  final Set<String> domaines;
  final bool ouverteAuxMineurs;
  final bool accessiblePmr;
  final DateTime? aPartirDu;

  const PocFiltresBenevolat({
    this.types = const {},
    this.domaines = const {},
    this.ouverteAuxMineurs = false,
    this.accessiblePmr = false,
    this.aPartirDu,
  });

  int get nombre =>
      types.length + domaines.length + (ouverteAuxMineurs ? 1 : 0) + (accessiblePmr ? 1 : 0) + (aPartirDu != null ? 1 : 0);

  @override
  List<Object?> get props => [types, domaines, ouverteAuxMineurs, accessiblePmr, aPartirDu];
}

class PocFiltresNiveau extends Equatable {
  final Set<PocNiveau> niveaux;

  const PocFiltresNiveau([this.niveaux = const {}]);

  int get nombre => niveaux.length;

  bool accepte(PocNiveau niveau) => niveaux.isEmpty || niveaux.contains(niveau);

  @override
  List<Object?> get props => [niveaux];
}

String sansAccents(String texte) {
  const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ’';
  const sans = 'aaaaaaceeeeiiiinooooouuuuyyoe\'';
  final buffer = StringBuffer();
  for (final caractere in texte.toLowerCase().split('')) {
    final index = avec.indexOf(caractere);
    buffer.write(index >= 0 ? sans[index] : caractere);
  }
  return buffer.toString();
}

double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const rayonTerre = 6371.0;
  double radians(double degres) => degres * math.pi / 180;
  final dLat = radians(lat2 - lat1);
  final dLon = radians(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(radians(lat1)) * math.cos(radians(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return rayonTerre * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
