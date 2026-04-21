import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/metier.dart';

class ImmersionCriteresRecherche extends Equatable {
  final Metier? metier;
  final String? appellationCode;
  final Location location;

  ImmersionCriteresRecherche({
    this.metier,
    this.appellationCode,
    required this.location,
  }) : assert(metier != null || appellationCode != null, 'metier or appellationCode must be provided');

  @override
  List<Object?> get props => [metier, appellationCode, location];
}
