import 'package:equatable/equatable.dart';

class FeatureFlip extends Equatable {
  final bool useCvm;
  final bool withCampagneRecrutement;
  final String? withMonSuiviDemarchesKoMessage;
  final AbTestingIaFt abTestingIaFt;

  FeatureFlip({
    required this.useCvm,
    required this.withCampagneRecrutement,
    required this.withMonSuiviDemarchesKoMessage,
    required this.abTestingIaFt,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      useCvm: false,
      withCampagneRecrutement: false,
      withMonSuiviDemarchesKoMessage: null,
      abTestingIaFt: AbTestingIaFt.versionA,
    );
  }

  FeatureFlip copyWith({
    bool? useCvm,
    bool? withCampagneRecrutement,
    String? withMonSuiviDemarchesKoMessage,
    AbTestingIaFt? abTestingIaFt,
  }) {
    return FeatureFlip(
      useCvm: useCvm ?? this.useCvm,
      withCampagneRecrutement: withCampagneRecrutement ?? this.withCampagneRecrutement,
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      abTestingIaFt: abTestingIaFt ?? this.abTestingIaFt,
    );
  }

  @override
  List<Object?> get props => [
        useCvm,
        withCampagneRecrutement,
        withMonSuiviDemarchesKoMessage,
        abTestingIaFt,
      ];
}

enum AbTestingIaFt {
  versionA,
  versionB;

  factory AbTestingIaFt.fromJson(String json) => switch (json) {
        "A" => AbTestingIaFt.versionA,
        "B" => AbTestingIaFt.versionB,
        _ => AbTestingIaFt.versionA,
      };
}
