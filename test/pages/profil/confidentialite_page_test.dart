import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/pages/profil/confidentialite_page.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  final liens = {
    Strings.legalNoticeLabel: Strings.legalNoticeUrl,
    Strings.termsOfUseLabel: Strings.termsOfServiceUrl,
    Strings.privacyPolicyLabel: Strings.privacyPolicyUrl,
    Strings.accessibilityLevelLabel: Strings.accessibilityUrl,
  };

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('A11y 5.1 ($platform) : les tuiles sont des liens, sans « navigateur » dans le nom', (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(const MaterialApp(home: ConfidentialitePage()));

      for (final entry in liens.entries) {
        final data = tester.getSemantics(find.bySemanticsLabel(entry.key)).getSemanticsData();
        expect(data.flagsCollection.isLink, isTrue, reason: entry.key);
        expect(data.flagsCollection.isButton, isFalse, reason: entry.key);
        expect(data.label.toLowerCase(), isNot(contains('navigateur')), reason: entry.key);
        expect(data.hint.toLowerCase(), isNot(contains('navigateur')), reason: entry.key);
        if (platform == TargetPlatform.android) {
          expect(data.linkUrl, Uri.parse(entry.value), reason: entry.key);
        }
      }
      await tester.pump(const Duration(seconds: 1));
      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });
  }
}
