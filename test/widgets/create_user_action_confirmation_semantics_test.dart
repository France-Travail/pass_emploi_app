import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/user_action/create/user_action_create_state.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_confirmation_page.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  const accessibilityChannel = BasicMessageChannel<dynamic>('flutter/accessibility', StandardMessageCodec());

  Future<void> pump(WidgetTester tester, {bool multipleActions = false}) async {
    final Store<AppState> store = StoreSpy.withState(
      givenState().loggedInMiloUser().copyWith(
        userActionCreateState: UserActionCreateSuccessState('id', actionContent: 'Mon action'),
      ),
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: CreateUserActionConfirmationPage(
            source: UserActionStateSource.monSuivi,
            multipleActions: multipleActions,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  SemanticsNode? findNode(WidgetTester tester, bool Function(SemanticsNode) test) {
    SemanticsNode? found;
    void visit(SemanticsNode node) {
      if (found != null) return;
      if (test(node)) {
        found = node;
        return;
      }
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
    return found;
  }

  for (final multipleActions in [false, true]) {
    testWidgets('A11y 5.4 / 7.1 : le focus arrive sur le titre, en-tête (multipleActions: $multipleActions)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final focusedNodeIds = <int>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(accessibilityChannel, (
        message,
      ) async {
        if (message is Map && message['type'] == 'focus') focusedNodeIds.add(message['nodeId'] as int);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler(accessibilityChannel, null));

      await pump(tester, multipleActions: multipleActions);
      await tester.pump(const Duration(milliseconds: 200));

      final titleNode = findNode(tester, (n) => n.getSemanticsData().label.contains('Bravo'));
      expect(titleNode, isNotNull);
      expect(titleNode!.getSemanticsData().flagsCollection.isHeader, isTrue);

      // Un seul focus est demandé : sur le titre, jamais sur un bouton.
      expect(focusedNodeIds.length, 1);
      var parent = titleNode.parent;
      final candidates = {titleNode.id};
      while (parent != null && candidates.length < 3) {
        candidates.add(parent.id);
        parent = parent.parent;
      }
      expect(candidates.contains(focusedNodeIds.single), isTrue);
      expect(
        find.bySemanticsLabel(Strings.userActionConfirmationSeeDetailButton),
        multipleActions ? findsNothing : findsOneWidget,
      );
      handle.dispose();
    });
  }
}
