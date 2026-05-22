# Custom key Crashlytics `login_mode` — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Poser une custom key Crashlytics `login_mode` à chaque login réussi, pour rendre les déconnexions filtrables par IDP.

**Architecture:** Un seul point de changement, `CrashlyticsMiddleware`, qui intercepte déjà `LoginSuccessAction` pour `setUserIdentifier`. On ajoute un appel `setCustomKey` au même endroit. Aucun test n'existe pour ce middleware : on le crée.

**Tech Stack:** Flutter / Dart, Redux (`redux` package), tests `flutter_test` + `mocktail`.

---

## File Structure

- `lib/features/tech/crashlytics_middleware.dart` — middleware Redux existant. Modifié : ajout d'un `setCustomKey` dans le bloc `LoginSuccessAction`.
- `test/features/tech/crashlytics_middleware_test.dart` — **créé**. Premier test du middleware ; ne couvre que le nouveau comportement `login_mode` (YAGNI : pas de test rétro sur `last_actions`/`app_state`).

---

## Task 1 : Custom key `login_mode`

**Files:**
- Create: `test/features/tech/crashlytics_middleware_test.dart`
- Modify: `lib/features/tech/crashlytics_middleware.dart` (bloc `if (action is LoginSuccessAction)`, ligne ~21)

Référence — état actuel du bloc à modifier :

```dart
if (action is LoginSuccessAction) crashlytics.setUserIdentifier(action.user.id);
```

- [ ] **Step 1 : Écrire le test qui échoue**

Créer `test/features/tech/crashlytics_middleware_test.dart` :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/tech/crashlytics_middleware.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

import '../../doubles/fixtures.dart';

class MockCrashlytics extends Mock implements Crashlytics {}

class MockStore extends Mock implements Store<AppState> {}

void main() {
  test('sets login_mode custom key on LoginSuccessAction', () {
    // Given
    final crashlytics = MockCrashlytics();
    final store = MockStore();
    when(() => store.state).thenReturn(AppState.initialState());
    final middleware = CrashlyticsMiddleware(crashlytics);
    final action = LoginSuccessAction(mockUser(id: 'user-id', loginMode: LoginMode.POLE_EMPLOI));

    // When
    middleware.call(store, action, (_) {});

    // Then
    verify(() => crashlytics.setCustomKey('login_mode', 'POLE_EMPLOI')).called(1);
  });

  test('does not set login_mode custom key on a non-login action', () {
    // Given
    final crashlytics = MockCrashlytics();
    final store = MockStore();
    when(() => store.state).thenReturn(AppState.initialState());
    final middleware = CrashlyticsMiddleware(crashlytics);

    // When
    middleware.call(store, BootstrapAction(), (_) {});

    // Then
    verifyNever(() => crashlytics.setCustomKey('login_mode', any()));
  });
}
```

Note : l'import `BootstrapAction` est nécessaire pour le 2e test — ajouter en tête :
```dart
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
```

- [ ] **Step 2 : Lancer le test pour vérifier qu'il échoue**

Run: `flutter test test/features/tech/crashlytics_middleware_test.dart`
Expected: le 1er test échoue — `setCustomKey('login_mode', ...)` jamais appelé (seuls `last_actions` et `app_state` le sont). Le 2e test passe déjà.

- [ ] **Step 3 : Implémenter le changement minimal**

Dans `lib/features/tech/crashlytics_middleware.dart`, remplacer :

```dart
if (action is LoginSuccessAction) crashlytics.setUserIdentifier(action.user.id);
```

par :

```dart
if (action is LoginSuccessAction) {
  crashlytics.setUserIdentifier(action.user.id);
  crashlytics.setCustomKey("login_mode", action.user.loginMode.name);
}
```

Aucun import à ajouter : `LoginSuccessAction` est déjà importé et `.name` est natif sur l'enum.

- [ ] **Step 4 : Lancer les tests pour vérifier qu'ils passent**

Run: `flutter test test/features/tech/crashlytics_middleware_test.dart`
Expected: les 2 tests PASS.

- [ ] **Step 5 : Vérifier l'analyse statique**

Run: `flutter analyze lib/features/tech/crashlytics_middleware.dart test/features/tech/crashlytics_middleware_test.dart`
Expected: `No issues found!`

- [ ] **Step 6 : Commit**

```bash
git add lib/features/tech/crashlytics_middleware.dart test/features/tech/crashlytics_middleware_test.dart
git commit -m "feat(crashlytics): ajoute la custom key login_mode au login"
```

---

## Self-Review

- **Couverture du spec :** unique exigence (poser `login_mode` sur `LoginSuccessAction`, réel et démo) → Task 1. Le test utilise `POLE_EMPLOI` ; `mockUser` accepte n'importe quelle valeur de `LoginMode`, démo incluse — pas besoin d'un test par valeur (YAGNI).
- **Placeholders :** aucun.
- **Cohérence des types :** `setCustomKey(String, String)` conforme à l'interface `Crashlytics` ; `LoginMode.name` renvoie bien `"POLE_EMPLOI"` / `"MILO"` / `"DEMO_MILO"` / `"DEMO_PE"`.