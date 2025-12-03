import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class GenericSuccessPage extends StatelessWidget {
  const GenericSuccessPage({super.key, required this.title, required this.content});
  final String title;
  final String? content;

  static Route<dynamic> route({required String title, String? content}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => GenericSuccessPage(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SecondaryAppBar(title: title, backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: SizedBox(height: 130, width: 130, child: Image.asset(Drawables.success))),
                SizedBox(height: Margins.spacing_xl),
                Text(title, textAlign: TextAlign.center, style: TextStyles.textMBold),
                if (content != null) ...[
                  SizedBox(height: Margins.spacing_m),
                  Text(content!, textAlign: TextAlign.center, style: TextStyles.textSRegular()),
                ],
                SizedBox(height: Margins.spacing_m),
                PrimaryActionButton(label: Strings.close, onPressed: () => Navigator.pop(context)),
                SizedBox(height: Margins.spacing_xx_huge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
