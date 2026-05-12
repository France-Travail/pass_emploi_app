import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Opacity(opacity: 0.2, child: ModalBarrier(dismissible: false, color: AppColors.contentLight)),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
