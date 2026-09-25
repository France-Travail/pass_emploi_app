import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/theme.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/chat_piece_jointe_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/chat/chat_text_field.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  late List<String> sent;

  Future<void> pumpChatTextField(WidgetTester tester, {bool jeunePjEnabled = true}) async {
    sent = [];
    await tester.pumpWidget(
      StoreProvider(
        store: givenState().store(),
        child: MaterialApp(
          theme: PassEmploiTheme.data,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ChatTextField(
                controller: TextEditingController(),
                focusNode: FocusNode(),
                jeunePjEnabled: jeunePjEnabled,
                onSendMessage: (message) => sent.add("message:$message"),
                onSendImage: (path) => sent.add("image:$path"),
                onSendFile: (path) => sent.add("file:$path"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectPieceJointe(WidgetTester tester, ChatPieceJointeBottomSheetResult result) async {
    await tester.tap(find.byTooltip(Strings.sendAttachmentTooltip));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(ChatPieceJointeBottomSheet))).pop(result);
    await tester.pumpAndSettle();
  }

  Future<void> tapSend(WidgetTester tester) async {
    await tester.tap(find.byTooltip(Strings.sendMessageTooltip));
    await tester.pumpAndSettle();
  }

  bool isVisible(WidgetTester tester, String tooltip) {
    final crossFade = tester.widget<AnimatedCrossFade>(
      find.ancestor(of: find.byTooltip(tooltip), matching: find.byType(AnimatedCrossFade)),
    );
    return crossFade.crossFadeState == CrossFadeState.showSecond;
  }

  testWidgets('pièce jointe reste disponible quand un message est en cours de saisie', (tester) async {
    // Given
    await pumpChatTextField(tester);

    // When
    await tester.enterText(find.byType(EditableText), "Bonjour");
    await tester.pumpAndSettle();

    // Then
    expect(isVisible(tester, Strings.sendAttachmentTooltip), isTrue);
    expect(isVisible(tester, Strings.sendMessageTooltip), isTrue);
  });

  testWidgets('pièce jointe sélectionnée est gardée en brouillon et non envoyée', (tester) async {
    // Given
    await pumpChatTextField(tester);

    // When
    await selectPieceJointe(tester, ChatPieceJointeBottomSheetFileResult("/tmp/mon_cv.pdf"));

    // Then
    expect(sent, isEmpty);
    expect(find.text("mon_cv.pdf"), findsOneWidget);
    expect(isVisible(tester, Strings.sendAttachmentTooltip), isFalse);
    expect(isVisible(tester, Strings.sendMessageTooltip), isTrue);
  });

  testWidgets('envoi du message et du fichier en brouillon', (tester) async {
    // Given
    await pumpChatTextField(tester);
    await tester.enterText(find.byType(EditableText), "Voici mon CV");
    await selectPieceJointe(tester, ChatPieceJointeBottomSheetFileResult("/tmp/mon_cv.pdf"));

    // When
    await tapSend(tester);

    // Then
    expect(sent, ["message:Voici mon CV", "file:/tmp/mon_cv.pdf"]);
    expect(find.text("mon_cv.pdf"), findsNothing);
    expect(find.text("Voici mon CV"), findsNothing);
    expect(isVisible(tester, Strings.sendAttachmentTooltip), isTrue);
  });

  testWidgets('envoi d’une image en brouillon sans message', (tester) async {
    // Given
    await pumpChatTextField(tester);
    await selectPieceJointe(tester, ChatPieceJointeBottomSheetImageResult("/tmp/photo.jpg"));

    // When
    await tapSend(tester);

    // Then
    expect(sent, ["image:/tmp/photo.jpg"]);
  });

  testWidgets('pièce jointe retirée du brouillon n’est pas envoyée', (tester) async {
    // Given
    await pumpChatTextField(tester);
    await tester.enterText(find.byType(EditableText), "Bonjour");
    await selectPieceJointe(tester, ChatPieceJointeBottomSheetFileResult("/tmp/mon_cv.pdf"));

    // When
    await tester.tap(find.bySemanticsLabel(Strings.chatPieceJointeBrouillonRemove));
    await tester.pumpAndSettle();
    await tapSend(tester);

    // Then
    expect(sent, ["message:Bonjour"]);
  });

  testWidgets('pas de bouton pièce jointe quand la fonctionnalité est désactivée', (tester) async {
    // Given
    await pumpChatTextField(tester, jeunePjEnabled: false);

    // Then
    expect(isVisible(tester, Strings.sendAttachmentTooltip), isFalse);
  });
}
