import 'package:pass_emploi_app/models/tutorial/tutorial_page.dart';

enum TutorialKind { generic, planAction }

abstract class TutorialState {}

class TutorialNotInitializedState extends TutorialState {}

class ShowTutorialState extends TutorialState {
  final List<TutorialPage> pages;
  final TutorialKind kind;

  ShowTutorialState(this.pages, {this.kind = TutorialKind.generic});
}
