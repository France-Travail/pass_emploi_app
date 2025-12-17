part of '../create_demarche_form_change_notifier.dart';

class CreateDemarchePersonnaliseeStep3ViewModel extends CreateDemarcheViewModel {
  final DateInputSource dateSource;
  CreateDemarchePersonnaliseeStep3ViewModel({DateInputSource? initialDateInput})
    : dateSource = initialDateInput ?? DateNotInitialized();

  @override
  List<Object?> get props => [dateSource];

  CreateDemarchePersonnaliseeStep3ViewModel copyWith({DateInputSource? dateSource}) {
    return CreateDemarchePersonnaliseeStep3ViewModel(initialDateInput: dateSource ?? this.dateSource);
  }
}
