import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/chat/chat_content.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/default_animated_switcher.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/preview_file_invisible_handler.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class ChatScaffold extends StatelessWidget {
  final DisplayState displayState;
  final VoidCallback onRetry;
  final ChatContent content;
  final String title;
  final bool withAppBar;
  final bool withScaffold;

  const ChatScaffold({
    required this.displayState,
    required this.onRetry,
    required this.content,
    this.title = Strings.menuChat,
    this.withAppBar = true,
    this.withScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    final body = ColoredBox(
      color: backgroundColor,
      child: ConnectivityContainer(
        child: Column(
          children: [
            Expanded(
              child: DefaultAnimatedSwitcher(
                child: _Body(
                  displayState: displayState,
                  content: content,
                  onRetry: onRetry,
                ),
              ),
            ),
            PreviewFileInvisibleHandler(),
          ],
        ),
      ),
    );

    if (!withScaffold) return body;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: withAppBar ? PrimaryAppBar(title: title) : null,
      body: body,
    );
  }
}

class _Body extends StatelessWidget {
  final DisplayState displayState;
  final ChatContent content;
  final VoidCallback onRetry;

  const _Body({
    required this.displayState,
    required this.content,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (displayState) {
      DisplayState.CONTENT => content,
      DisplayState.LOADING => Center(child: CircularProgressIndicator()),
      _ => Retry(Strings.chatError, () => onRetry()),
    };
  }
}
