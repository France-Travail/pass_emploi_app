import 'package:equatable/equatable.dart';

class DateConsultationActualiteMissionLocaleState extends Equatable {
  DateConsultationActualiteMissionLocaleState({this.date});

  final DateTime? date;

  @override
  List<Object?> get props => [date];
}
