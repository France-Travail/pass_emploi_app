import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OffreDetailsTag extends StatelessWidget {
  const OffreDetailsTag({
    super.key,
    required this.label,
    this.icon,
    this.iconSemanticLabel,
  });

  final String label;
  final IconData? icon;
  final String? iconSemanticLabel;

  factory OffreDetailsTag.location(String location) {
    return OffreDetailsTag(
      label: location,
      icon: DsfrIcons.mapMapPin2Line,
      iconSemanticLabel: Strings.iconAlternativeLocation,
    );
  }

  factory OffreDetailsTag.contractType(String contractType) {
    return OffreDetailsTag(
      label: contractType,
      icon: DsfrIcons.businessBriefcaseLine,
      iconSemanticLabel: Strings.iconAlternativeContractType,
    );
  }

  factory OffreDetailsTag.salary(String salary) {
    return OffreDetailsTag(
      label: salary,
      icon: DsfrIcons.financeMoneyEuroCircleLine,
      iconSemanticLabel: Strings.iconAlternativeSalary,
    );
  }

  factory OffreDetailsTag.duration(String duration) {
    return OffreDetailsTag(
      label: duration,
      icon: DsfrIcons.systemTimeLine,
      iconSemanticLabel: Strings.iconAlternativeDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: iconSemanticLabel != null ? '$iconSemanticLabel : $label' : label,
      child: ExcludeSemantics(
        child: DsfrTag(
          label: label,
          size: DsfrComponentSize.md,
          icon: icon,
          backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
          textColor: DsfrColorDecisions.textTitleGrey(context),
        ),
      ),
    );
  }
}
