import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';

sealed class CreateDemarcheDisplayState {
  static int get stepsTotalCount => 3;

  int? index();
}

// step 1

sealed class CreateDemarcheStep1 extends CreateDemarcheDisplayState {}

class CreateDemarcheStep1Thematique extends CreateDemarcheStep1 {
  @override
  int? index() => 0;
}

class CreateDemarcheIaFtStep1 extends CreateDemarcheStep1 {
  @override
  int? index() => null;
}

// step 2
sealed class CreateDemarcheStep2 extends CreateDemarcheDisplayState {}

class CreateDemarcheFromThematiqueStep2 extends CreateDemarcheStep2 {
  @override
  int? index() => 1;
}

class CreateDemarchePersonnaliseeStep2 extends CreateDemarcheStep2 {
  @override
  int? index() => 1;
}

class CreateDemarcheIaFtStep2 extends CreateDemarcheStep2 {
  @override
  int? index() => null;
}

// step 3
sealed class CreateDemarcheStep3 extends CreateDemarcheDisplayState {
  @override
  int? index() => 2;
}

class CreateDemarcheFromThematiqueStep3 extends CreateDemarcheStep3 {
  @override
  int? index() => 2;
}

class CreateDemarchePersonnaliseeStep3 extends CreateDemarcheStep3 {
  @override
  int? index() => 2;
}

// confirmation
sealed class CreateDemarcheSubmitted extends CreateDemarcheDisplayState {}

class CreateDemarcheFromThematiqueSubmitted extends CreateDemarcheSubmitted {
  @override
  int? index() => 2;
}

class CreateDemarchePersonnaliseeSubmitted extends CreateDemarcheSubmitted {
  @override
  int? index() => 2;
}

class CreateDemarcheIaFtSubmitted extends CreateDemarcheSubmitted {
  @override
  int? index() => null;

  final List<CreateDemarcheRequestAction> createRequests;

  CreateDemarcheIaFtSubmitted({required this.createRequests});
}
