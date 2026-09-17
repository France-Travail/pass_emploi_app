import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class ChatEditMessagePage extends StatelessWidget {
  const ChatEditMessagePage(this.content);

  final String content;

  static Route<String?> route(String content) {
    return MaterialPageRoute(builder: (context) => ChatEditMessagePage(content));
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: content);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: SecondaryAppBar(title: Strings.chatEditMessageAppBar),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(DsfrSpacings.s2w),
                child: DsfrInput(
                  label: Strings.chatEditMessageAppBar,
                  controller: controller,
                  autofocus: true,
                  minLines: 5,
                  maxLines: 8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DsfrSpacings.s2w,
                DsfrSpacings.s1w,
                DsfrSpacings.s2w,
                DsfrSpacings.s2w,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: DsfrButton(
                    label: Strings.editMessageSave,
                    variant: DsfrButtonVariant.primary,
                    size: DsfrComponentSize.md,
                    onPressed: () => Navigator.of(context).pop(controller.text),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
