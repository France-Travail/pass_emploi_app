import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/date_consultation_actualite_mission_locale_repository.dart';
import 'package:redux/redux.dart';

class DateConsultationActualiteMissionLocaleMiddleware extends MiddlewareClass<AppState> {
  final DateConsultationActualiteMissionLocaleRepository _repository;

  DateConsultationActualiteMissionLocaleMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is ActualiteMissionLocaleRequestAction) {
      final result = await _repository.get();
      store.dispatch(DateConsultationActualiteMissionLocaleSuccessAction(result));
    }

    if (action is DateConsultationActualiteMissionLocaleWriteAction) {
      await _repository.save(action.date);
      store.dispatch(DateConsultationActualiteMissionLocaleSuccessAction(action.date));
    }
  }
}
