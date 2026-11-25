import 'package:pass_emploi_app/models/structure_accompagnement.dart';

class StructuresAccompagnementRequestAction {
  final StructuresAccompagnementRequest request;

  StructuresAccompagnementRequestAction(this.request);
}

class StructuresAccompagnementLoadingAction {
  final StructuresAccompagnementRequest request;

  StructuresAccompagnementLoadingAction(this.request);
}

class StructuresAccompagnementSuccessAction {
  final StructuresAccompagnementRequest request;
  final List<StructureAccompagnement> result;

  StructuresAccompagnementSuccessAction(this.request, this.result);
}

class StructuresAccompagnementFailureAction {
  final StructuresAccompagnementRequest request;

  StructuresAccompagnementFailureAction(this.request);
}

class StructuresAccompagnementResetAction {}
