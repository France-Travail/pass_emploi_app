import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/pages/evenement_emploi/evenement_emploi_details_page.dart';
import 'package:pass_emploi_app/presentation/evenement_emploi/evenement_emploi_item_view_model.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_event_card.dart';

class EvenementEmploiCard extends StatelessWidget {
  final EvenementEmploiItemViewModel _viewModel;

  const EvenementEmploiCard(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return DsfrEventCard(
      onTap: () => Navigator.of(context).push(
        EvenementEmploiDetailsPage.materialPageRoute(_viewModel.id),
      ),
      emoji: _viewModel.emoji,
      emojiBackgroundColor: _viewModel.emojiBackground,
      semanticsLabel: [
        _viewModel.type,
        _viewModel.titre,
        _viewModel.dateLabel,
        _viewModel.heureLabel,
        _viewModel.locationLabel,
      ].join('. '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsfrStatusBadge(type: DsfrBadgeType.information, label: _viewModel.type),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            _viewModel.titre,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1v),
          DsfrEventCardComplement(
            icon: DsfrIcons.systemTimeLine,
            text: _viewModel.heureLabel,
            semanticsLabel: _viewModel.heureLabel.toTimeAndDurationForScreenReaders(),
          ),
          if (_viewModel.locationLabel.trim().isNotEmpty) ...[
            const SizedBox(height: DsfrSpacings.s1v),
            DsfrEventCardComplement(
              icon: DsfrIcons.mapMapPin2Line,
              text: _viewModel.locationLabel,
            ),
          ],
        ],
      ),
    );
  }
}
