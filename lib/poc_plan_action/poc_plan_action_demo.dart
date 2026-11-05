import 'package:dio/dio.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/poc_plan_action/poc_plan_action_donnees.dart';

// Le serveur de démo ignore les réponses et rend toujours le même plan. L'app n'envoie la demande qu'avec une situation
// et au moins un objectif : ceux du jeune fictif remplacent les étapes passées, pour la demande seulement.
OnboardingQuestionnaireAnswers pocReponsesPourGenerer(OnboardingQuestionnaireAnswers answers) {
  if (answers.canGenerateActionPlan) return answers;
  return answers.copyWith(
    situation: answers.situation ?? QuestionnaireSituation.autre,
    objectifs: answers.objectifs.isEmpty
        ? {QuestionnaireObjectif.decouvrirMetiers, QuestionnaireObjectif.engager}
        : answers.objectifs,
  );
}

// Répond à la place de l'API du plan d'action en mode démo. Coches et suppressions restent en mémoire jusqu'à
// la prochaine entrée en démo : rien n'est envoyé à un serveur.
class PocPlanActionDemo {
  PocPlanActionDemo._() {
    demarrer(missionLocale: false);
  }

  static final instance = PocPlanActionDemo._();

  static const idPlan = "poc-plan-action";

  static final _plan = RegExp(r'/jeunes/[^/]+/plan-action$');
  static final _tache = RegExp(r'/jeunes/[^/]+/plan-action/taches/([^/]+)$');
  static final _questionnaire = RegExp(r'/jeunes/[^/]+/questionnaire$');

  bool _missionLocale = false;
  final _terminees = <String>{};
  final _supprimees = <String>{};

  void demarrer({required bool missionLocale}) {
    _missionLocale = missionLocale;
    _terminees
      ..clear()
      ..addAll([
        for (final objectif in pocPlanActionObjectifs)
          for (final tache in objectif.taches)
            if (tache.termineeAuDepart) tache.id,
      ]);
    _supprimees.clear();
  }

  Response<dynamic>? repondre(RequestOptions options) {
    final path = options.uri.path;
    final tache = _tache.firstMatch(path);
    if (tache != null) {
      _modifierTache(tache.group(1)!, options);
      return Response(requestOptions: options, statusCode: 200);
    }
    // Le POST du bouton « Modifier » renvoie le même plan : comme l'API pour des objectifs inchangés, il garde les
    // tâches cochées et supprimées.
    if (_plan.hasMatch(path)) {
      return Response(requestOptions: options, data: planJson(), statusCode: options.method == "POST" ? 201 : 200);
    }
    if (_questionnaire.hasMatch(path)) {
      return Response(requestOptions: options, data: pocPlanActionQuestionnaire, statusCode: 200);
    }
    return null;
  }

  Map<String, dynamic> planJson() {
    return {
      "id": idPlan,
      "objectives": [
        for (final objectif in pocPlanActionObjectifs)
          if (objectif.taches.any((tache) => !_supprimees.contains(tache.id)))
            {
              "id": objectif.id,
              "titre": objectif.titre,
              "theme": objectif.theme,
              "actions": [
                for (final tache in objectif.taches)
                  if (!_supprimees.contains(tache.id)) _tacheJson(tache),
              ],
            },
      ],
    };
  }

  void _modifierTache(String id, RequestOptions options) {
    if (options.method == "DELETE") {
      _supprimees.add(id);
      return;
    }
    final data = options.data;
    if (options.method != "PATCH" || data is! Map) return;
    if (data["terminee"] == true) _terminees.add(id);
    if (data["terminee"] == false) _terminees.remove(id);
  }

  // Comme pour un vrai jeune accompagné, cocher ouvre la fenêtre de déclaration, avec la thématique de la démarche
  // France Travail ou la catégorie de l'action Mission Locale.
  Map<String, dynamic> _tacheJson(PocPlanTache tache) {
    final categorie = _missionLocale ? tache.categorieMissionLocale : tache.thematiqueFranceTravail;
    return {
      "id": tache.id,
      "libelle": tache.libelle,
      "type": tache.type,
      "terminee": _terminees.contains(tache.id),
      "declarationRequise": true,
      "url": ?tache.url,
      "ecranApp": ?tache.ecranApp,
      "nomService": ?tache.nomService,
      "categorie": ?categorie,
    };
  }
}
