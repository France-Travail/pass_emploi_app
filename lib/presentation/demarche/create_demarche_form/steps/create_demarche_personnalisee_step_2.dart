part of '../create_demarche_form_change_notifier.dart';

class CreateDemarchePersonnaliseeStep2ViewModel extends CreateDemarcheViewModel {
  final String description;
  CreateDemarchePersonnaliseeStep2ViewModel({this.description = ''});

  static int maxLength = 255;

  @override
  List<Object?> get props => [description];

  CreateDemarchePersonnaliseeStep2ViewModel copyWith({String? description}) {
    return CreateDemarchePersonnaliseeStep2ViewModel(description: description ?? this.description);
  }
}
