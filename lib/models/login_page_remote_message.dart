class LoginPageRemoteMessage {
  String title;
  String description;

  LoginPageRemoteMessage({
    required this.title,
    required this.description,
  });

  static LoginPageRemoteMessage? fromJson(Map<String, dynamic> json) {
    final dateDebut = DateTime.fromMillisecondsSinceEpoch(json['dateDebut'] as int);
    final dateFin = DateTime.fromMillisecondsSinceEpoch(json['dateFin'] as int);

    if (dateDebut.isAfter(DateTime.now()) || dateFin.isBefore(DateTime.now())) {
      return null;
    }

    return LoginPageRemoteMessage(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}
