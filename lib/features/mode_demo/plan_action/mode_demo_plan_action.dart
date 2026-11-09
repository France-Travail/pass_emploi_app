import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/utils/asset_bundle_extensions.dart';

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
  ModeDemoPlanAction._();

  static final instance = ModeDemoPlanAction._();

  static const planId = "mode-demo-plan-action";

  // L'écran de génération ne passe à l'accueil qu'après avoir vu le plan « en cours » : la démo prend le temps d'une
  // vraie génération, sinon le plan reviendrait entre deux vérifications de l'écran.
  static const generationDuration = Duration(seconds: 2);

  // Plan recopié de l'export du Grist « Référentiel pour plan d'action » (table Solutions, 05/11/2026) : les tâches
  // visibles pour un jeune de 21 ans en « Autre situation », dans l'ordre du Grist. Chaque tâche porte la thématique de
  // la démarche France Travail et la catégorie de l'action Mission Locale.
  static const _planFile = "plan_action";

  // Réponses du jeune fictif, au format de GET /jeunes/:id/questionnaire : elles rendent le questionnaire complet
  // (sous-titre et bouton « Modifier » de l'accueil) et le préremplissent quand on le rouvre.
  static const _questionnaireFile = "plan_action_questionnaire";

  static final _plan = RegExp(r'/jeunes/[^/]+/plan-action$');
  static final _task = RegExp(r'/jeunes/[^/]+/plan-action/taches/([^/]+)$');
  static final _questionnaire = RegExp(r'/jeunes/[^/]+/questionnaire$');

  bool _missionLocale = false;
  final _checkedTasks = <String, bool>{};
  final _deletedTaskIds = <String>{};

  // Chaque entrée en démo repart du plan des captures.
  void start({required bool missionLocale}) {
    _missionLocale = missionLocale;
    _checkedTasks.clear();
    _deletedTaskIds.clear();
  }

  bool isGeneration(RequestOptions options) => options.method == "POST" && _plan.hasMatch(options.uri.path);

  Future<Response<dynamic>?> respond(RequestOptions options) async {
    final path = options.uri.path;
    final task = _task.firstMatch(path);
    if (task != null) {
      _updateTask(task.group(1)!, options);
      return Response(requestOptions: options, statusCode: 200);
    }
    // Le POST du bouton « Modifier » rend le même plan : comme l'API pour des objectifs inchangés, il garde les tâches
    // cochées et supprimées.
    if (_plan.hasMatch(path)) {
      return Response(
        requestOptions: options,
        data: await planJson(),
        statusCode: options.method == "POST" ? 201 : 200,
      );
    }
    if (_questionnaire.hasMatch(path)) {
      return Response(requestOptions: options, data: await _load(_questionnaireFile), statusCode: 200);
    }
    return null;
  }

  Future<Map<String, dynamic>> planJson() async {
    final plan = await _load(_planFile) as Map<String, dynamic>;
    return {
      "id": planId,
      "objectives": [
        for (final objective in (plan["objectives"] as List).cast<Map<String, dynamic>>())
          if (_remainingTasks(objective).isNotEmpty)
            {
              ...objective,
              "actions": [for (final task in _remainingTasks(objective)) _taskJson(task)],
            },
      ],
    };
  }

  Future<dynamic> _load(String file) async => jsonDecode(await rootBundle.loadDemoAsset(file));

  List<Map<String, dynamic>> _remainingTasks(Map<String, dynamic> objective) {
    return [
      for (final task in (objective["actions"] as List).cast<Map<String, dynamic>>())
        if (!_deletedTaskIds.contains(task["id"])) task,
    ];
  }

  void _updateTask(String id, RequestOptions options) {
    if (options.method == "DELETE") {
      _deletedTaskIds.add(id);
      return;
    }
    final data = options.data;
    if (options.method != "PATCH" || data is! Map) return;
    final done = data["terminee"];
    if (done is bool) _checkedTasks[id] = done;
  }

  // Comme pour un vrai jeune accompagné, cocher ouvre la fenêtre de déclaration, avec la thématique de la démarche
  // France Travail ou la catégorie de l'action Mission Locale.
  Map<String, dynamic> _taskJson(Map<String, dynamic> task) {
    final categorie = task[_missionLocale ? "categorieMissionLocale" : "categorieFranceTravail"] as String?;
    return {
      for (final entry in task.entries)
        if (entry.key != "categorieMissionLocale" && entry.key != "categorieFranceTravail") entry.key: entry.value,
      "terminee": _checkedTasks[task["id"]] ?? (task["terminee"] == true),
      "declarationRequise": true,
      "categorie": ?categorie,
    };
  }
}
