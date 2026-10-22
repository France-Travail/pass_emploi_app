import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/version.dart';
import 'package:pass_emploi_app/utils/log.dart';
import 'package:pass_emploi_app/wrappers/package_info_wrapper.dart';

enum Flavor { STAGING, PROD }

class Configuration extends Equatable {
  final Version? version;
  final Flavor flavor;
  final Brand brand;
  final String serverBaseUrl;
  final String matomoBaseUrl;
  final String matomoSiteId;
  final String matomoDimensionProduitId;
  final String matomoDimensionAvecConnexionId;
  final String authClientId;
  final String authLoginRedirectUrl;
  final String authLogoutRedirectUrl;
  final String authIssuer;
  final List<String> authScopes;
  final String authClientSecret;
  final String iSRGX1CertificateForOldDevices;
  final String actualisationPoleEmploiUrl;
  final String fuseauHoraire;

  Configuration(
    this.version,
    this.flavor,
    this.brand,
    this.serverBaseUrl,
    this.matomoBaseUrl,
    this.matomoSiteId,
    this.matomoDimensionProduitId,
    this.matomoDimensionAvecConnexionId,
    this.authClientId,
    this.authLoginRedirectUrl,
    this.authLogoutRedirectUrl,
    this.authIssuer,
    this.authScopes,
    this.authClientSecret,
    this.iSRGX1CertificateForOldDevices,
    this.actualisationPoleEmploiUrl,
    this.fuseauHoraire,
  );

  static Future<Configuration> build() async {
    final currentVersion = Version.fromString(await PackageInfoWrapper.getVersion());
    final packageName = await PackageInfoWrapper.getPackageName();
    final flavor = packageName.contains("staging") ? Flavor.STAGING : Flavor.PROD;
    Log.i("Flavor = $flavor");
    final brand = Brand.brand;
    final serverBaseUrl = String.fromEnvironment('SERVER_BASE_URL');
    final matomoBaseUrl = String.fromEnvironment('MATOMO_BASE_URL');
    final matomoSiteId = String.fromEnvironment('MATOMO_SITE_ID');
    final matomoDimensionProduitId = String.fromEnvironment('MATOMO_DIMENSION_PRODUIT_ID');
    final matomoDimensionAvecConnexionId = String.fromEnvironment('MATOMO_DIMENSION_AVEC_CONNEXION_ID');
    final authClientId = String.fromEnvironment('AUTH_CLIENT_ID');
    final authLoginRedirectUrl = String.fromEnvironment('AUTH_LOGIN_URL');
    final authLogoutRedirectUrl = String.fromEnvironment('AUTH_LOGOUT_URL');
    final authIssuer = String.fromEnvironment('AUTH_ISSUER');
    final authScopes = String.fromEnvironment('AUTH_SCOPE').split(' ').toList(growable: false);
    final authClientSecret = String.fromEnvironment('AUTH_CLIENT_SECRET');
    final iSRGX1CertificateForOldDevices = utf8.decode(base64Decode(String.fromEnvironment('ISRGX1_CERT_FOR_OLD_DEVICES')));
    final actualisationPoleEmploiUrl = String.fromEnvironment('ACTUALISATION_PE_URL');
    final fuseauHoraire = await FlutterTimezone.getLocalTimezone();
    return Configuration(
      currentVersion,
      flavor,
      brand,
      serverBaseUrl,
      matomoBaseUrl,
      matomoSiteId,
      matomoDimensionProduitId,
      matomoDimensionAvecConnexionId,
      authClientId,
      authLoginRedirectUrl,
      authLogoutRedirectUrl,
      authIssuer,
      authScopes,
      authClientSecret,
      iSRGX1CertificateForOldDevices,
      actualisationPoleEmploiUrl,
      fuseauHoraire,
    );
  }


  @override
  List<Object?> get props => [
        version,
        flavor,
        brand,
        serverBaseUrl,
        matomoBaseUrl,
        matomoSiteId,
        matomoDimensionProduitId,
        authClientId,
        authLoginRedirectUrl,
        authLogoutRedirectUrl,
        authIssuer,
        authScopes,
        authClientSecret,
        iSRGX1CertificateForOldDevices,
        actualisationPoleEmploiUrl,
        fuseauHoraire,
      ];

  Configuration copyWith({
    Version? version,
    Flavor? flavor,
    Brand? brand,
    String? serverBaseUrl,
    String? matomoBaseUrl,
    String? matomoSiteId,
    String? matomoDimensionProduitId,
    String? matomoDimensionAvecConnexionId,
    String? authClientId,
    String? authLoginRedirectUrl,
    String? authLogoutRedirectUrl,
    String? authIssuer,
    List<String>? authScopes,
    String? authClientSecret,
    String? iSRGX1CertificateForOldDevices,
    String? actualisationPoleEmploiUrl,
    String? fuseauHoraire,
  }) {
    return Configuration(
      version ?? this.version,
      flavor ?? this.flavor,
      brand ?? this.brand,
      serverBaseUrl ?? this.serverBaseUrl,
      matomoBaseUrl ?? this.matomoBaseUrl,
      matomoSiteId ?? this.matomoSiteId,
      matomoDimensionProduitId ?? this.matomoDimensionProduitId,
      matomoDimensionAvecConnexionId ?? this.matomoDimensionAvecConnexionId,
      authClientId ?? this.authClientId,
      authLoginRedirectUrl ?? this.authLoginRedirectUrl,
      authLogoutRedirectUrl ?? this.authLogoutRedirectUrl,
      authIssuer ?? this.authIssuer,
      authScopes ?? this.authScopes,
      authClientSecret ?? this.authClientSecret,
      iSRGX1CertificateForOldDevices ?? this.iSRGX1CertificateForOldDevices,
      actualisationPoleEmploiUrl ?? this.actualisationPoleEmploiUrl,
      fuseauHoraire ?? this.fuseauHoraire,
    );
  }
}
