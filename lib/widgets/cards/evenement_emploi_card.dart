import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/pages/evenement_emploi/evenement_emploi_details_page.dart';
import 'package:pass_emploi_app/presentation/evenement_emploi/evenement_emploi_item_view_model.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';

class EvenementEmploiCard extends StatelessWidget {
  final EvenementEmploiItemViewModel _viewModel;

  const EvenementEmploiCard(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [
        _viewModel.type,
        _viewModel.titre,
        _viewModel.dateLabel,
        _viewModel.heureLabel,
        _viewModel.locationLabel,
      ].join('. '),
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            EvenementEmploiDetailsPage.materialPageRoute(_viewModel.id),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(DsfrSpacings.s3v),
                    child: Align(
                      alignment: Alignment.center,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: DsfrColorDecisions.backgroundOpenBlueFrance(context)),
                          color: DsfrColorDecisions.backgroundContrastInfo(context),
                        ),
                        child: SizedBox.square(
                          dimension: DsfrSpacings.s6w,
                          child: Icon(
                            DsfrIcons.businessCalendarEventLine,
                            color: DsfrColorDecisions.textTitleBlueFrance(context),
                            size: DsfrSpacings.s3w,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        DsfrSpacings.s3v,
                        DsfrSpacings.s3v,
                        DsfrSpacings.s3v,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _viewModel.titre,
                            style: DsfrTextStyle.bodyMdBold(
                              color: DsfrColorDecisions.textTitleBlueFrance(context),
                            ),
                          ),
                          const SizedBox(height: DsfrSpacings.s1w),
                          Wrap(
                            spacing: DsfrSpacings.s1w,
                            runSpacing: DsfrSpacings.s1w,
                            children: [
                              OffreDetailsTag(
                                label: _viewModel.type,
                                icon: DsfrIcons.businessCalendarEventLine,
                              ),
                              OffreDetailsTag(
                                label: _viewModel.dateLabel,
                                icon: DsfrIcons.businessCalendarLine,
                              ),
                              OffreDetailsTag(
                                label: _viewModel.heureLabel,
                                icon: DsfrIcons.systemTimeLine,
                              ),
                              if (_viewModel.locationLabel.isNotEmpty)
                                OffreDetailsTag.location(_viewModel.locationLabel),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
