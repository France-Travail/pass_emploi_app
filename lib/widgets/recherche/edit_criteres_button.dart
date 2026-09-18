import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/presentation/recherche/actions_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:redux/redux.dart';

class EditCriteresButton<Result> extends StatelessWidget {
  const EditCriteresButton({
    super.key,
    required this.searchLabel,
    required this.buildViewModel,
    required this.buildFiltresBottomSheet,
    required this.onFiltreApplied,
  });

  final String searchLabel;
  final ActionsRechercheViewModel Function(Store<AppState> store) buildViewModel;
  final Future<bool?>? Function() buildFiltresBottomSheet;
  final VoidCallback onFiltreApplied;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ActionsRechercheViewModel>(
      converter: buildViewModel,
      distinct: true,
      builder: (context, viewModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchBar(
              label: searchLabel,
              onTap: () => context.dispatch(RechercheOpenCriteresAction<Result>()),
            ),
            if (viewModel.withFiltreButton) ...[
              const SizedBox(height: DsfrSpacings.s3v),
              DsfrButton(
                label: viewModel.filtresCount != null && viewModel.filtresCount! > 0
                    ? "${Strings.filtrerLesResultats} (${viewModel.filtresCount})"
                    : Strings.filtrerLesResultats,
                icon: DsfrIcons.mediaEqualizerLine,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.lg,
                onPressed: () => _onFiltreButtonPressed(context),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _onFiltreButtonPressed(BuildContext context) {
    final bottomSheet = buildFiltresBottomSheet();
    if (bottomSheet == null) return Future.value();
    return bottomSheet.then((value) {
      if (value == true) onFiltreApplied();
    });
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(DsfrSpacings.s1v);
    final underlineBorder = Border(
      bottom: BorderSide(
        color: DsfrColorDecisions.borderPlainBlueFrance(context),
        width: DsfrSpacings.s0v5,
      ),
    );

    return Semantics(
      button: true,
      label: Strings.rechercheEditButton,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: DsfrColorDecisions.backgroundDefaultGreyHover(context),
              borderRadius: const BorderRadius.only(topLeft: radius),
              child: InkWell(
                onTap: onTap,
                borderRadius: const BorderRadius.only(topLeft: radius),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: radius),
                    border: underlineBorder,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
                    child: SizedBox(
                      height: DsfrSpacings.s6w,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
            borderRadius: const BorderRadius.only(topRight: radius),
            child: InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.only(topRight: radius),
              child: SizedBox(
                width: DsfrSpacings.s6w,
                height: DsfrSpacings.s6w,
                child: Icon(
                  DsfrIcons.systemSearchLine,
                  color: DsfrColorDecisions.textInvertedBlueFrance(context),
                  size: DsfrSpacings.s3w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
