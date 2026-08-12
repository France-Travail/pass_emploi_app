import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';

class AlerteFormTag {
  const AlerteFormTag(this.label, {this.isLocation = false});

  factory AlerteFormTag.location(String label) => AlerteFormTag(label, isLocation: true);

  final String label;
  final bool isLocation;
}

class AlerteBottomSheetFormContent extends StatefulWidget {
  const AlerteBottomSheetFormContent({
    super.key,
    required this.initialTitle,
    required this.tags,
    required this.savingFailure,
    required this.onCreate,
  });

  final String initialTitle;
  final List<AlerteFormTag> tags;
  final bool savingFailure;
  final ValueChanged<String> onCreate;

  @override
  State<AlerteBottomSheetFormContent> createState() => _AlerteBottomSheetFormContentState();
}

class _AlerteBottomSheetFormContentState extends State<AlerteBottomSheetFormContent> {
  String? _searchTitle;

  @override
  void initState() {
    super.initState();
    _searchTitle = widget.initialTitle.isNotEmpty ? widget.initialTitle : null;
  }

  bool get _isFormValid => _searchTitle != null && _searchTitle!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              DsfrInput(
                label: Strings.alerteTitle,
                initialValue: widget.initialTitle,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                componentState: (_searchTitle != null && _searchTitle!.isEmpty)
                    ? DsfrComponentState.error(errorMessage: Strings.mandatoryAlerteTitleError)
                    : const DsfrComponentState.none(),
                onChanged: (value) => setState(() => _searchTitle = value),
              ),
              const SizedBox(height: DsfrSpacings.s3w),
              Text(
                Strings.alerteFilters,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Wrap(
                spacing: DsfrSpacings.s1w,
                runSpacing: DsfrSpacings.s1w,
                children: widget.tags.map(_buildTag).toList(),
              ),
              const SizedBox(height: DsfrSpacings.s3w),
              DsfrAlert(
                type: DsfrAlertType.info,
                description: DsfrAlertDescriptionText(
                  '${Strings.alerteInfo}\n${Strings.searchNotificationInfo}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.createAlert,
          icon: DsfrIcons.mediaNotification3Line,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: _isFormValid
              ? () {
                  widget.onCreate(_searchTitle!);
                }
              : null,
        ),
        if (widget.savingFailure) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            Strings.creationAlerteError,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultError(context)),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(AlerteFormTag tag) {
    if (tag.isLocation) return OffreDetailsTag.location(tag.label);
    return OffreDetailsTag(label: tag.label);
  }
}
