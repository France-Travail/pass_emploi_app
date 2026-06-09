import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/presentation/soft_update_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';

class SoftUpdateBottomSheet extends StatelessWidget {
  const SoftUpdateBottomSheet({super.key});

  static void show(BuildContext context) {
    showPassEmploiBottomSheet<bool>(
      context: context,
      builder: (context) => const SoftUpdateBottomSheet(),
    ).then((didDownload) {
      if (!context.mounted) return;
      final store = StoreProvider.of<AppState>(context);
      final viewModel = SoftUpdateBottomSheetViewModel.create(store, PlatformUtils.getPlatform);
      if (didDownload == true) {
        viewModel.onDownload?.call();
      } else {
        viewModel.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SoftUpdateBottomSheetViewModel>(
      converter: (store) => SoftUpdateBottomSheetViewModel.create(store, PlatformUtils.getPlatform),
      builder: (context, viewModel) {
        return BottomSheetWrapper(
          title: viewModel.title,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Margins.spacing_base),
                Text(
                  viewModel.subtitle,
                  style: TextStyles.textBaseRegular.copyWith(color: context.content),
                ),
                SizedBox(height: Margins.spacing_l),
                PrimaryActionButton(
                  label: viewModel.downloadLabel,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                SizedBox(height: Margins.spacing_base),
                SecondaryButton(
                  label: viewModel.closeLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
