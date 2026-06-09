import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/features/soft_update/soft_update_actions.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:redux/redux.dart';

class SoftUpdateBottomSheetViewModel extends Equatable {
  final String title;
  final String subtitle;
  final String downloadLabel;
  final String closeLabel;
  final VoidCallback onDismiss;
  final VoidCallback? onDownload;

  SoftUpdateBottomSheetViewModel({
    required this.title,
    required this.subtitle,
    required this.downloadLabel,
    required this.closeLabel,
    required this.onDismiss,
    required this.onDownload,
  });

  factory SoftUpdateBottomSheetViewModel.create(Store<AppState> store, Platform platform) {
    final flavor = store.state.configurationState.configuration?.flavor ?? Flavor.PROD;
    final brand = store.state.configurationState.configuration?.brand ?? Brand.brand;
    final storeUrl = flavor == Flavor.PROD ? platform.getAppStoreUrl(brand) : '';

    return SoftUpdateBottomSheetViewModel(
      title: Strings.softUpdateBottomSheetTitle,
      subtitle: Strings.softUpdateBottomSheetSubtitle,
      downloadLabel: Strings.softUpdateBottomSheetDownload,
      closeLabel: Strings.softUpdateBottomSheetClose,
      onDismiss: () => store.dispatch(SoftUpdateDismissAction()),
      onDownload: () {
        store.dispatch(SoftUpdateDownloadAction());
        launchExternalUrl(storeUrl);
      },
    );
  }

  @override
  List<Object?> get props => [title, subtitle, downloadLabel, closeLabel];
}
