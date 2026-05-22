# Custom key Crashlytics `login_mode`

> Date : 2026-05-22
> Repo : pass_emploi_app
> Statut : design validé

## Contexte

Investigation en cours sur les déconnexions intempestives des jeunes. Le suspect
n°1 est spécifique à l'IDP MiLo (token IDP « couche B » rotatif et mort côté
`connect` alors que le token app↔connect reste valide). Aujourd'hui, dans
Crashlytics, on ne peut pas filtrer une remontée de déconnexion par IDP.

L'app est déjà correctement instrumentée par ailleurs : `CrashlyticsMiddleware`
trace les 20 dernières actions Redux et l'`app_state` en custom keys,
`setUserIdentifier` est posé au login, et le logout logge déjà sa raison. Le seul
trou pertinent ici est l'absence d'un axe de filtrage par IDP.

## Objectif

Rendre les déconnexions filtrables par IDP dans Crashlytics, sans toucher au flow
d'authentification. Quick win : un changement d'une ligne fonctionnelle.

## Changement

Dans `CrashlyticsMiddleware.call()`, à l'endroit où `LoginSuccessAction` est déjà
intercepté pour `setUserIdentifier` :

```dart
if (action is LoginSuccessAction) {
  crashlytics.setUserIdentifier(action.user.id);
  crashlytics.setCustomKey("login_mode", action.user.loginMode.name);
}
```

## Comportement

- La custom key est posée à chaque login réussi, réel **et** démo — distinguer
  `DEMO_MILO` / `DEMO_PE` est utile, pas un défaut.
- Valeurs possibles : `MILO`, `POLE_EMPLOI`, `DEMO_MILO`, `DEMO_PE` (enum
  `LoginMode`).
- Pas de reset au logout : la prochaine connexion écrase la valeur. Entre-temps
  la clé reflète le dernier IDP utilisé — exactement ce qu'on veut pour
  investiguer une déconnexion.

## Hors périmètre

- Filet de sécurité au niveau du refresh et `refreshTokenFailureLog()` (travail
  non commité existant) : traité séparément.
- Corrélateur `trace.id` app ↔ connect : nécessite un changement coordonné des
  deux côtés, hors d'un quick win.

## Tests

`test/features/tech/crashlytics_middleware_test.dart` : un cas vérifiant que
`setCustomKey("login_mode", <valeur>)` est appelé avec la bonne valeur sur
`LoginSuccessAction`.

## Vérification

- `flutter analyze`
- `flutter test test/features/tech/crashlytics_middleware_test.dart`