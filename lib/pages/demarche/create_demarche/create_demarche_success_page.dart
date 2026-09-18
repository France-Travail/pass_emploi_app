import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche_form_page.dart';
import 'package:pass_emploi_app/pages/demarche/demarche_detail_page.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_success_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';
import 'package:pass_emploi_app/widgets/in_app_feedback.dart';
import 'package:pass_emploi_app/widgets/success/creation_confirmation_body.dart';
import 'package:pass_emploi_app/widgets/success/success_dialog_app_bar.dart';

enum CreateDemarcheSource { personnalisee, fromReferentiel, iaFt, duplicate }

String? _feedbackFeatureForSource(CreateDemarcheSource source) {
  switch (source) {
    case CreateDemarcheSource.personnalisee:
      return "create-demarche-personnalisee";
    case CreateDemarcheSource.fromReferentiel:
      return "create-demarche-referentiel";
    case CreateDemarcheSource.duplicate:
      return "create-demarche-duplicate";
    case CreateDemarcheSource.iaFt:
      return null;
  }
}

class CreateDemarcheSuccessPage extends StatelessWidget {
  const CreateDemarcheSuccessPage({super.key, required this.source});
  final CreateDemarcheSource source;

  static Route<dynamic> route(CreateDemarcheSource source) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => CreateDemarcheSuccessPage(source: source),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWrapper(
      builder: (context, confettiController) {
        return StoreConnector<AppState, CreateDemarcheSuccessViewModel>(
          builder: (context, viewModel) => Tracker(
            tracking: switch (source) {
              CreateDemarcheSource.personnalisee => AnalyticsScreenNames.createDemarchePersonnaliseeSuccess,
              CreateDemarcheSource.fromReferentiel => AnalyticsScreenNames.createDemarcheFromReferentielSuccess,
              CreateDemarcheSource.iaFt => AnalyticsScreenNames.createDemarcheIaFtSuccess,
              CreateDemarcheSource.duplicate => AnalyticsScreenNames.createDemarcheDuplicateSuccess,
            },
            child: _Content(viewModel, source),
          ),
          converter: (store) => CreateDemarcheSuccessViewModel.create(store, source),
          distinct: true,
          onDispose: (store) => store.dispatch(CreateDemarcheResetAction()),
          onInit: (_) => confettiController.play(),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.viewModel, this.source);
  final CreateDemarcheSuccessViewModel viewModel;
  final CreateDemarcheSource source;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _Body(viewModel, source),
      DisplayState.FAILURE => _Scaffold(
        appBarTitle: viewModel.appBarTitle,
        body: Center(child: ErrorText(Strings.genericCreationError)),
      ),
      _ => _Scaffold(
        appBarTitle: viewModel.appBarTitle,
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _Body extends StatelessWidget {
  const _Body(this.viewModel, this.source);
  final CreateDemarcheSuccessViewModel viewModel;
  final CreateDemarcheSource source;

  @override
  Widget build(BuildContext context) {
    final feedbackFeature = _feedbackFeatureForSource(source);

    return _Scaffold(
      appBarTitle: viewModel.appBarTitle,
      body: CreationConfirmationBody(
        header: feedbackFeature != null
            ? InAppFeedback(
                feature: feedbackFeature,
                label: Strings.feedbackCreateDemarche,
              )
            : null,
        tag: viewModel.isPlural ? DsfrCategoryTag.demarchesDone() : DsfrCategoryTag.demarcheDone(),
        title: Strings.userActionConfirmationTitle(viewModel.firstName),
        subtitle: viewModel.subtitle,
        actions: _DemarcheSuccessButtons.build(
          context: context,
          source: source,
          onGoActionDetail: viewModel.demarcheId != null
              ? () {
                  Navigator.pop(context);
                  DemarcheDetailPage.show(context, viewModel.demarcheId!);
                }
              : null,
          onCreateMore: () {
            Navigator.pop(context);
            Navigator.of(context).push(CreateDemarcheFormPage.route());
          },
        ),
      ),
    );
  }
}

class _DemarcheSuccessButtons {
  static List<Widget> build({
    required BuildContext context,
    required CreateDemarcheSource source,
    required void Function()? onGoActionDetail,
    required void Function() onCreateMore,
  }) {
    if (source == CreateDemarcheSource.iaFt) {
      return [
        _primaryButton(
          label: Strings.consulterMesDemarches,
          autoFocus: true,
          onPressed: () {
            Navigator.pop(context);
            StoreProvider.of<AppState>(context).dispatch(
              HandleDeepLinkAction(
                MonSuiviDeepLink(),
                DeepLinkOrigin.inAppNavigation,
              ),
            );
          },
        ),
      ];
    }

    return [
      if (onGoActionDetail != null) ...[
        _primaryButton(
          label: Strings.demarcheSuccessConsulter,
          autoFocus: true,
          onPressed: onGoActionDetail,
        ),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
      _secondaryButton(
        label: Strings.demarcheSuccessCreerUneAutre,
        onPressed: onCreateMore,
      ),
    ];
  }

  static Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
    bool autoFocus = false,
  }) {
    final button = DsfrButton(
      label: label,
      variant: DsfrButtonVariant.primary,
      size: DsfrComponentSize.lg,
      onPressed: onPressed,
    );
    return autoFocus ? AutoFocusA11y(child: button) : button;
  }

  static Widget _secondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return DsfrButton(
      label: label,
      variant: DsfrButtonVariant.secondary,
      size: DsfrComponentSize.lg,
      onPressed: onPressed,
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.appBarTitle, required this.body});
  final String appBarTitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: SuccessDialogAppBar(title: appBarTitle),
      body: body,
    );
  }
}
