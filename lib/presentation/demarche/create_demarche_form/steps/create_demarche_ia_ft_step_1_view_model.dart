part of '../create_demarche_form_change_notifier.dart';

class CreateDemarcheIaFtStep1ViewModel extends CreateDemarcheViewModel {
  CreateDemarcheIaFtStep1ViewModel({this.description = ''});
  final String description;

  static int maxLength = 1000;

  @override
  List<Object?> get props => [description];

  CreateDemarcheIaFtStep1ViewModel copyWith({String? description}) {
    return CreateDemarcheIaFtStep1ViewModel(description: description ?? this.description);
  }
}
