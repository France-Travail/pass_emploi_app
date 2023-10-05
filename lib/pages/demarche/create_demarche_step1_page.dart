import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/demarche/search/seach_demarche_actions.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche_step2_page.dart';
import 'package:pass_emploi_app/pages/demarche/thematiques_demarche_page.dart';
import 'package:pass_emploi_app/pages/demarche/top_demarche_page.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_step1_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_source.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/pressed_tip.dart';

class CreateDemarcheStep1Page extends StatefulWidget {
  static MaterialPageRoute<String?> materialPageRoute() {
    return MaterialPageRoute(builder: (context) => CreateDemarcheStep1Page());
  }

  @override
  State<CreateDemarcheStep1Page> createState() => _CreateDemarcheStep1PageState();
}

class _CreateDemarcheStep1PageState extends State<CreateDemarcheStep1Page> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.searchDemarcheStep1,
      child: StoreConnector<AppState, CreateDemarcheStep1ViewModel>(
        builder: _buildBody,
        converter: (store) => CreateDemarcheStep1ViewModel.create(store),
        onDispose: (store) => store.dispatch(SearchDemarcheResetAction()),
        distinct: true,
      ),
    );
  }

  Widget _buildBody(BuildContext context, CreateDemarcheStep1ViewModel viewModel) {
    return Scaffold(
      appBar: SecondaryAppBar(title: Strings.createDemarcheTitle),
      body: Padding(
        padding: const EdgeInsets.all(Margins.spacing_base),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Subtitle(text: Strings.demarcheRechercheSubtitle),
              SizedBox(height: Margins.spacing_base),
              _Mandatory(),
              SizedBox(height: Margins.spacing_base),
              Text(Strings.searchDemarcheHint, style: TextStyles.textBaseMedium),
              SizedBox(height: Margins.spacing_base),
              _ChampRecherche(
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
              SizedBox(height: Margins.spacing_xl),
              SizedBox(
                width: double.infinity,
                child: PrimaryActionButton(
                  icon: AppIcons.search_rounded,
                  label: Strings.searchDemarcheButton,
                  onPressed: () => _onSearchStarted(viewModel, context),
                ),
              ),
              SizedBox(height: Margins.spacing_xl),
              _Subtitle(text: Strings.demarcheCategoriesSubtitle),
              SizedBox(height: Margins.spacing_base),
              _ThematicCard(),
              SizedBox(height: Margins.spacing_base),
              _TopDemarcheCard(),
              SizedBox(height: Margins.spacing_huge),
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchStarted(CreateDemarcheStep1ViewModel viewModel, BuildContext context) {
    viewModel.onSearchDemarche(_query);

    Navigator.push(
        context,
        CreateDemarcheStep2Page.materialPageRoute(
          source: RechercheDemarcheSource(),
          query: _query,
        )).then((value) {
      // forward result to previous page
      if (value != null) Navigator.pop(context, value);
    });
  }
}

class _ThematicCard extends StatelessWidget {
  const _ThematicCard();

  @override
  Widget build(BuildContext context) {
    return _DemarcheCardBase(
      icon: AppIcons.signpost_rounded,
      title: Strings.demarcheThematiqueTitle,
      description: Strings.demarchesCategoriesDescription,
      pressedTip: Strings.demarchesCategoriesPressedTip,
      onTap: () {
        Navigator.push(context, ThematiqueDemarchePage.materialPageRoute()).then((value) {
          // forward result to previous page
          if (value != null) Navigator.pop(context, value);
        });
      },
    );
  }
}

class _TopDemarcheCard extends StatelessWidget {
  const _TopDemarcheCard();

  @override
  Widget build(BuildContext context) {
    return _DemarcheCardBase(
      icon: AppIcons.favorite_rounded,
      title: Strings.topDemarchesTitle,
      description: Strings.topDemarchesSubtitle,
      pressedTip: Strings.topDemarchesPressedTip,
      onTap: () {
        Navigator.push(context, TopDemarchePage.materialPageRoute()).then((value) {
          // forward result to previous page
          if (value != null) Navigator.pop(context, value);
        });
      },
    );
  }
}

class _DemarcheCardBase extends StatelessWidget {
  const _DemarcheCardBase(
      {required this.icon, required this.title, required this.description, required this.pressedTip, this.onTap});
  final IconData icon;
  final String title;
  final String description;
  final String pressedTip;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                SizedBox(width: Margins.spacing_s),
                Text(title, style: TextStyles.textMBold),
              ],
            ),
            SizedBox(height: Margins.spacing_base),
            Text(description, style: TextStyles.textBaseRegular),
            SizedBox(height: Margins.spacing_base),
            PressedTip(pressedTip),
          ],
        ));
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyles.textMBold.copyWith(color: AppColors.grey800));
  }
}

class _Mandatory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(Strings.mandatoryFields, style: TextStyles.textSRegular());
  }
}

class _ChampRecherche extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _ChampRecherche({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyles.textBaseBold,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return Strings.mandatoryField;
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(
          left: Margins.spacing_m,
          top: Margins.spacing_base,
          bottom: Margins.spacing_base,
        ),
        border: _Border(AppColors.contentColor),
        focusedBorder: _Border(AppColors.primary),
        errorBorder: _Border(AppColors.warning),
        focusedErrorBorder: _Border(AppColors.warning),
      ),
      onChanged: onChanged,
    );
  }
}

class _Border extends OutlineInputBorder {
  _Border(Color color)
      : super(
          borderRadius: BorderRadius.circular(Dimens.radius_base),
          borderSide: BorderSide(color: color, width: 1.0),
        );
}
