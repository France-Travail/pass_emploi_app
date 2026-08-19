import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

class DateSuggestionListViewModel {
  final List<DateSuggestionViewModel> suggestions;

  factory DateSuggestionListViewModel.createFuture(DateTime now) {
    final yesterday = now.subtract(Duration(days: 1));
    final tomorrow = now.add(Duration(days: 1));
    return DateSuggestionListViewModel(suggestions: [
      DateSuggestionViewModel(
        Strings.dateSuggestionHier,
        "${Strings.dateSuggestionHier} (${yesterday.toDayWithFullMonth()})",
        yesterday,
      ),
      DateSuggestionViewModel(
        Strings.dateSuggestionAujourdhui,
        "${Strings.dateSuggestionAujourdhui} (${now.toDayWithFullMonth()})",
        now,
      ),
      DateSuggestionViewModel(
        Strings.dateSuggestionDemain,
        "${Strings.dateSuggestionDemain} (${tomorrow.toDayWithFullMonth()})",
        tomorrow,
      ),
    ]);
  }

  factory DateSuggestionListViewModel.createPast(DateTime now, DateTime? firstDate) {
    final yesterday = now.add(Duration(days: -1));

    bool isValid(DateTime date) {
      return firstDate == null || !date.isBefore(firstDate);
    }

    return DateSuggestionListViewModel(suggestions: [
      if (isValid(now))
        DateSuggestionViewModel(
          Strings.dateSuggestionAujourdhui,
          "${Strings.dateSuggestionAujourdhui} (${now.toDayWithFullMonth()})",
          now,
        ),
      if (isValid(yesterday))
        DateSuggestionViewModel(
          Strings.dateSuggestionHier,
          "${Strings.dateSuggestionHier} (${yesterday.toDayWithFullMonth()})",
          yesterday,
        ),
    ]);
  }

  DateSuggestionListViewModel({required this.suggestions});
}

class DateSuggestionViewModel {
  final String label;
  final String a11yLabel;
  final DateTime date;

  DateSuggestionViewModel(this.label, this.a11yLabel, this.date);
}
