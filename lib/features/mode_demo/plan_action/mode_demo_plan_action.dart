import 'package:dio/dio.dart';
import 'package:pass_emploi_app/features/mode_demo/plan_action/mode_demo_plan_action_data.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

// Le plan de la démo ne dépend pas des réponses. L'app n'envoie la demande de génération qu'avec une situation et au
// moins un objectif : ceux du jeune fictif remplacent les étapes passées, pour la demande seulement.
OnboardingQuestionnaireAnswers answersForDemoGeneration(OnboardingQuestionnaireAnswers answers) {
  if (answers.canGenerateActionPlan) return answers;
  return answers.copyWith(
    situation: answers.situation ?? QuestionnaireSituation.autre,
    objectifs: answers.objectifs.isEmpty
        ? {QuestionnaireObjectif.decouvrirMetiers, QuestionnaireObjectif.engager}
        : answers.objectifs,
  );
}

// Répond à la place de l'API du plan d'action en mode démo. Coches et suppressions restent en mémoire jusqu'à la
// prochaine entrée en démo : rien n'est envoyé à un serveur.
class ModeDemoPlanAction {
  ModeDemoPlanAction._() {
    start(missionLocale: false);
  }

  static final instance = ModeDemoPlanAction._();

  static const planId = "mode-demo-plan-action";

  // L'écran de génération ne passe à l'accueil qu'après avoir vu le plan « en cours » : la démo prend le temps d'une
  // vraie génération, sinon le plan reviendrait entre deux vérifications de l'écran.
  static const generationDuration = Duration(seconds: 2);

  static final _plan = RegExp(r'/jeunes/[^/]+/plan-action$');
  static final _task = RegExp(r'/jeunes/[^/]+/plan-action/taches/([^/]+)$');
  static final _questionnaire = RegExp(r'/jeunes/[^/]+/questionnaire$');

  bool _missionLocale = false;
  final _doneTaskIds = <String>{};
  final _deletedTaskIds = <String>{};

  void start({required bool missionLocale}) {
    _missionLocale = missionLocale;
    _doneTaskIds
      ..clear()
      ..addAll([
        for (final objective in demoPlanObjectives)
          for (final task in objective.tasks)
            if (task.doneAtStart) task.id,
      ]);
    _deletedTaskIds.clear();
  }

  bool isGeneration(RequestOptions options) => options.method == "POST" && _plan.hasMatch(options.uri.path);

  Response<dynamic>? respond(RequestOptions options) {
    final path = options.uri.path;
    final task = _task.firstMatch(path);
    if (task != null) {
      _updateTask(task.group(1)!, options);
      return Response(requestOptions: options, statusCode: 200);
    }
    // Le POST du bouton « Modifier » rend le même plan : comme l'API pour des objectifs inchangés, il garde les tâches
    // cochées et supprimées.
    if (_plan.hasMatch(path)) {
      return Response(requestOptions: options, data: planJson(), statusCode: options.method == "POST" ? 201 : 200);
    }
    if (_questionnaire.hasMatch(path)) {
      return Response(requestOptions: options, data: demoQuestionnaire, statusCode: 200);
    }
    return null;
  }

  Map<String, dynamic> planJson() {
    return {
      "id": planId,
      "objectives": [
        for (final objective in demoPlanObjectives)
          if (objective.tasks.any((task) => !_deletedTaskIds.contains(task.id)))
            {
              "id": objective.id,
              "titre": objective.title,
              "theme": objective.theme,
              "actions": [
                for (final task in objective.tasks)
                  if (!_deletedTaskIds.contains(task.id)) _taskJson(task),
              ],
            },
      ],
    };
  }

  void _updateTask(String id, RequestOptions options) {
    if (options.method == "DELETE") {
      _deletedTaskIds.add(id);
      return;
    }
    final data = options.data;
    if (options.method != "PATCH" || data is! Map) return;
    if (data["terminee"] == true) _doneTaskIds.add(id);
    if (data["terminee"] == false) _doneTaskIds.remove(id);
  }

  // Comme pour un vrai jeune accompagné, cocher ouvre la fenêtre de déclaration, avec la thématique de la démarche
  // France Travail ou la catégorie de l'action Mission Locale.
  Map<String, dynamic> _taskJson(DemoPlanTask task) {
    final categorie = _missionLocale ? task.missionLocaleCategory : task.franceTravailTheme;
    return {
      "id": task.id,
      "libelle": task.label,
      "type": task.type,
      "terminee": _doneTaskIds.contains(task.id),
      "declarationRequise": true,
      "url": ?task.url,
      "ecranApp": ?task.appScreen,
      "nomService": ?task.serviceName,
      "categorie": ?categorie,
    };
  }
}
