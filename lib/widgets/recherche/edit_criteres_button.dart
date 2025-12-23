import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/presentation/recherche/actions_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:redux/redux.dart';

class EditCriteresButton<Result> extends StatelessWidget {
  const EditCriteresButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buildViewModel,
    required this.buildFiltresBottomSheet,
    required this.onFiltreApplied,
  });
  final String title;
  final String subtitle;

  final ActionsRechercheViewModel Function(Store<AppState> store) buildViewModel;

  final Future<bool?>? Function() buildFiltresBottomSheet;

  final Function() onFiltreApplied;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ActionsRechercheViewModel>(
      converter: buildViewModel,
      distinct: true,
      builder: (context, viewModel) {
        return CardContainer(
          border: Border.all(color: AppColors.primary, width: 1),
          padding: EdgeInsets.all(Margins.spacing_base),
          onTap: () => context.dispatch(RechercheOpenCriteresAction<Result>()),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                AppIcons.search_rounded,
                color: AppColors.primary,
                size: Dimens.icon_size_m,
              ),
              SizedBox(width: Margins.spacing_base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.textBaseBold,
                    ),
                    Text(
                      subtitle,
                      style: TextStyles.textSRegular(),
                    ),
                  ],
                ),
              ),
              if (viewModel.withFiltreButton)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_xs),
                  child: IconButton(
                    onPressed: () => _onFiltreButtonPressed(context),
                    icon: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Icon(AppIcons.tune_rounded, color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onFiltreButtonPressed(BuildContext context) {
    final bottomSheet = buildFiltresBottomSheet();
    if (bottomSheet == null) return Future(() => {});
    return bottomSheet.then((value) {
      if (value == true) onFiltreApplied();
    });
  }
}
