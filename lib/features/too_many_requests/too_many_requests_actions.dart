/// Une requête a été refusée parce que l'utilisateur a dépassé une limite de débit :
/// 429 de l'API, ou refresh du token refusé par connect.
class TooManyRequestsAction {
  final DateTime retryNotBefore;

  TooManyRequestsAction(this.retryNotBefore);

  @override
  String toString() => 'TooManyRequestsAction(retryNotBefore: $retryNotBefore)';
}
