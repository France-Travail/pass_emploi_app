import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';
import 'package:pass_emploi_app/widgets/in_app_feedback.dart';

enum CreateDemarcheSource { personnalisee, fromReferentiel, iaFt, duplicate }

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
        body: Center(child: ErrorText(Strings.genericCreationError)),
      ),
      _ => _Scaffold(body: const Center(child: CircularProgressIndicator())),
    };
  }
}

class _Body extends StatelessWidget {
  const _Body(this.viewModel, this.source);
  final CreateDemarcheSuccessViewModel viewModel;
  final CreateDemarcheSource source;

  @override
  Widget build(BuildContext context) {
    final title = switch (source) {
      CreateDemarcheSource.iaFt => Strings.demarcheSuccessTitlePlural,
      _ => Strings.demarcheSuccessTitle,
    };
    final content = switch (source) {
      CreateDemarcheSource.iaFt => Strings.demarcheSuccessSubtitlePlural,
      _ => Strings.demarcheSuccessSubtitle,
    };

    return _Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InAppFeedback(
                    feature: switch (source) {
                      CreateDemarcheSource.personnalisee => "create-demarche-personnalisee",
                      CreateDemarcheSource.fromReferentiel => "create-demarche-referentiel",
                      CreateDemarcheSource.iaFt => "create-demarche-ia-ft",
                      CreateDemarcheSource.duplicate => "create-demarche-duplicate",
                    },
                    label: Strings.feedbackCreateDemarche,
                    disabledPlaceholder: switch (source) {
                      CreateDemarcheSource.iaFt => InAppFeedback(
                        feature: "create-demarche-ia-ft-suggestions",
                        label: Strings.feedbackCreateDemarcheSuggestions,
                        responses: [
                          Strings.feedbackCreateDemarcheSuggestionsResponse1,
                          Strings.feedbackCreateDemarcheSuggestionsResponse2,
                          Strings.feedbackCreateDemarcheSuggestionsResponse3,
                        ],
                      ),
                      _ => null,
                    },
                  ),
                  const SizedBox(height: DsfrSpacings.s3w),
                  Center(
                    child: SvgPicture.asset(
                      Drawables.illustrationSuccess,
                      width: 160,
                      height: 160,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s3w),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s3w),
                  _Buttons(
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
                    source: source,
                  ),
                  const SizedBox(height: DsfrSpacings.s4w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({
    required this.onGoActionDetail,
    required this.onCreateMore,
    required this.source,
  });

  final void Function()? onGoActionDetail;
  final void Function() onCreateMore;
  final CreateDemarcheSource source;

  @override
  Widget build(BuildContext context) {
    if (source == CreateDemarcheSource.iaFt) {
      return AutoFocusA11y(
        child: DsfrButton(
          label: Strings.consulterMesDemarches,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
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
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onGoActionDetail != null) ...[
          AutoFocusA11y(
            child: DsfrButton(
              label: Strings.demarcheSuccessConsulter,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: onGoActionDetail,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        DsfrButton(
          label: Strings.demarcheSuccessCreerUneAutre,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: onCreateMore,
        ),
      ],
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.body});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: AppBar(
        toolbarHeight: PrimaryAppBar.toolBarHeight,
        titleSpacing: DsfrSpacings.s2w,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        iconTheme: IconThemeData(color: DsfrColorDecisions.textTitleGrey(context)),
        title: Semantics(
          header: true,
          child: Tooltip(
            message: Strings.createDemarcheAppBarTitle,
            excludeFromSemantics: true,
            child: Text(
              Strings.createDemarcheAppBarTitle,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
