import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/sepline.dart';

class ColorInspectionPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() => MaterialPageRoute(builder: (context) => ColorInspectionPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppBar(title: Strings.developerOptionColorInspector),
      body: ListView.separated(
        itemBuilder: (context, index) => _ColorTitle(InternalAppColors.values[index]),
        padding: EdgeInsets.all(Margins.spacing_base),
        separatorBuilder: (_, index) => SepLine(Margins.spacing_s, Margins.spacing_s),
        itemCount: InternalAppColors.values.length,
      ),
    );
  }
}

class _ColorTitle extends StatefulWidget {
  final InternalAppColors color;

  const _ColorTitle(this.color);

  @override
  State<_ColorTitle> createState() => _ColorTitleState();
}

class _ColorTitleState extends State<_ColorTitle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 32, height: 32, color: widget.color.color),
        SizedBox(width: Margins.spacing_s),
        Expanded(child: Text(widget.color.name, style: TextStyles.textBaseRegular)),
        Switch(
          value: InternalAppColors.inspectedColors.contains(widget.color),
          onChanged: _onChanged,
        ),
      ],
    );
  }

  void _onChanged(bool checked) {
    setState(() {
      if (checked) {
        InternalAppColors.inspectedColors.add(widget.color);
      } else {
        InternalAppColors.inspectedColors.remove(widget.color);
      }
    });
  }
}
