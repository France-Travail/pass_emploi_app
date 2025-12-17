part of '../create_demarche_form_change_notifier.dart';

class CreateDemarcheFromThematiqueStep2ViewModel extends CreateDemarcheViewModel {
  final DemarcheDuReferentielCardViewModel? selectedDemarcheVm;
  CreateDemarcheFromThematiqueStep2ViewModel({this.selectedDemarcheVm});

  @override
  List<Object?> get props => [selectedDemarcheVm];

  CreateDemarcheFromThematiqueStep2ViewModel copyWith({DemarcheDuReferentielCardViewModel? demarcheCardViewModel}) {
    return CreateDemarcheFromThematiqueStep2ViewModel(selectedDemarcheVm: demarcheCardViewModel ?? selectedDemarcheVm);
  }
}
