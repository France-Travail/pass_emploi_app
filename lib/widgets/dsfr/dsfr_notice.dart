import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart' hide DsfrNotice;

/// Copie locale du bandeau d'information flutter_dsfr (0.4.1) :
/// description optionnelle, pas de bouton de fermeture.
class DsfrNotice extends StatelessWidget {
  const DsfrNotice({
    super.key,
    required this.titre,
    this.description,
    this.type = DsfrNoticeType.genericInfo,
  });

  final String titre;
  final String? description;
  final DsfrNoticeType type;

  @override
  Widget build(BuildContext context) {
    final color = _getTextColor(context);
    final textStyle = DsfrTextStyle.bodySm(color: color);
    final descriptionText = description;

    return Semantics(
      container: true,
      child: Column(
        children: [
          if (_isAlertType())
            Divider(thickness: 6, color: _getLineColor(context), height: 0),
          ColoredBox(
            color: _getBackgroundColor(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DsfrSpacings.s2w,
                DsfrSpacings.s3v,
                DsfrSpacings.s2w,
                DsfrSpacings.s2w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ExcludeSemantics(child: Icon(_getIcon(), color: color)),
                      const SizedBox(width: DsfrSpacings.s1w),
                      Expanded(
                        child: Text(
                          titre,
                          style: textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (descriptionText != null && descriptionText.isNotEmpty)
                    Text(descriptionText, style: textStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case DsfrNoticeType.genericInfo:
        return DsfrIcons.systemFrInfoFill;
      case DsfrNoticeType.genericWarning:
        return DsfrIcons.systemFrWarningFill;
      case DsfrNoticeType.genericAlert:
        return DsfrIcons.systemErrorWarningFill;
      case DsfrNoticeType.weatherOrange:
        return DsfrIcons.weatherHeavyShowersFill;
      case DsfrNoticeType.weatherRed:
        return DsfrIcons.weatherTornadoFill;
      case DsfrNoticeType.weatherPurple:
        return DsfrIcons.weatherTyphoonFill;
      case DsfrNoticeType.alertAttack:
        return DsfrIcons.systemFrAlertWarning2Fill;
      case DsfrNoticeType.alertCallForWitnesses:
      case DsfrNoticeType.alertTechnology:
        return DsfrIcons.systemFrWarningFill;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case DsfrNoticeType.genericInfo:
        return DsfrColorDecisions.backgroundContrastInfo(context);
      case DsfrNoticeType.genericWarning:
        return DsfrColorDecisions.backgroundContrastWarning(context);
      case DsfrNoticeType.genericAlert:
        return DsfrColorDecisions.backgroundContrastError(context);
      case DsfrNoticeType.weatherOrange:
        return DsfrColorDecisions.backgroundContrastWarning(context);
      case DsfrNoticeType.weatherRed:
        return DsfrColorDecisions.backgroundFlatError(context);
      case DsfrNoticeType.weatherPurple:
        return DsfrColorDecisionsExtension.backgroundPurpleGlycineLow(context);
      case DsfrNoticeType.alertAttack:
        return DsfrColorDecisions.backgroundFlatError(context);
      case DsfrNoticeType.alertCallForWitnesses:
      case DsfrNoticeType.alertTechnology:
        return DsfrColorDecisions.backgroundFlatGrey(context);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (type) {
      case DsfrNoticeType.genericInfo:
        return DsfrColorDecisions.textDefaultInfo(context);
      case DsfrNoticeType.genericWarning:
        return DsfrColorDecisions.textDefaultWarning(context);
      case DsfrNoticeType.genericAlert:
        return DsfrColorDecisions.textActionHighError(context);
      case DsfrNoticeType.weatherOrange:
        return DsfrColorDecisions.textActionHighWarning(context);
      case DsfrNoticeType.weatherRed:
      case DsfrNoticeType.weatherPurple:
      case DsfrNoticeType.alertAttack:
      case DsfrNoticeType.alertCallForWitnesses:
      case DsfrNoticeType.alertTechnology:
        return DsfrColorDecisions.textInvertedGrey(context);
    }
  }

  bool _isAlertType() =>
      type == DsfrNoticeType.alertAttack ||
      type == DsfrNoticeType.alertCallForWitnesses ||
      type == DsfrNoticeType.alertTechnology;

  Color _getLineColor(BuildContext context) {
    switch (type) {
      case DsfrNoticeType.alertAttack:
        return DsfrColorDecisions.borderPlainGrey(context);
      case DsfrNoticeType.alertCallForWitnesses:
        return DsfrColorDecisions.borderPlainError(context);
      case DsfrNoticeType.alertTechnology:
        return DsfrColorDecisions.borderPlainInfo(context);
      default:
        return DsfrColorDecisions.backgroundTransparent(context);
    }
  }
}
