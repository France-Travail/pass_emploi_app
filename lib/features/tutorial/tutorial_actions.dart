import 'package:pass_emploi_app/features/tutorial/tutorial_state.dart';
import 'package:pass_emploi_app/models/tutorial/tutorial_page.dart';

class TutorialSuccessAction {
  final List<TutorialPage> pages;
  final TutorialKind kind;

  TutorialSuccessAction(this.pages, {this.kind = TutorialKind.generic});
}

class TutorialDoneAction {}

class TutorialDelayedAction {}
