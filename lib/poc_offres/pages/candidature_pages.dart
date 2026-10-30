import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_memoire.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/mandatory_fields_label.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class PocCibleCandidature {
  final String id;
  final String titre;
  final String sousTitre;
  final bool spontanee;

  const PocCibleCandidature({required this.id, required this.titre, required this.sousTitre, required this.spontanee});
}

class _PocCv {
  final String nom;
  final String? chemin;

  const _PocCv(this.nom, {this.chemin});
}

// Candidature simplifiée de La bonne alternance (POST /job/v1/apply) : mêmes champs obligatoires.
// En démo, rien n'est envoyé ; en vrai, le CV passerait par notre API sans y être gardé.
class CandidaturePage extends StatefulWidget {
  const CandidaturePage({super.key, required this.cible});

  final PocCibleCandidature cible;

  static Future<void> ouvrir(BuildContext context, PocCibleCandidature cible) async {
    final envoyee = await showPassEmploiBottomSheet<bool>(context: context, builder: (_) => CandidaturePage(cible: cible));
    if (envoyee != true || !context.mounted) return;
    PocOffresMemoire.instance.noterCandidature(cible.id);
    await Navigator.push(context, CandidatureConfirmationPage.route());
  }

  @override
  State<CandidaturePage> createState() => _CandidaturePageState();
}

class _CandidaturePageState extends State<CandidaturePage> {
  static const _tailleMaxCv = 3 * 1024 * 1024;

  late final TextEditingController _nom;
  late final TextEditingController _prenom;
  late final TextEditingController _email;
  final _telephone = TextEditingController();
  final _message = TextEditingController();
  late final bool _cvFranceTravail;
  _PocCv? _cv;
  String? _erreurCv;
  bool _essaiEnvoi = false;

  @override
  void initState() {
    super.initState();
    // Choix de Steph (30/10) : nom, prénom et e-mail préremplis depuis le profil.
    final user = StoreProvider.of<AppState>(context, listen: false).state.user();
    _nom = TextEditingController(text: user?.lastName ?? '');
    _prenom = TextEditingController(text: user?.firstName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _cvFranceTravail = user?.loginMode.isPe() ?? false;
    if (_cvFranceTravail) _cv = _PocCv(pocCvFranceTravail.first);
  }

  @override
  void dispose() {
    for (final controleur in [_nom, _prenom, _email, _telephone, _message]) {
      controleur.dispose();
    }
    super.dispose();
  }

  String? get _erreurNom => _nom.text.trim().isEmpty ? PocOffresStrings.erreurNom : null;

  String? get _erreurPrenom => _prenom.text.trim().isEmpty ? PocOffresStrings.erreurPrenom : null;

  String? get _erreurEmail {
    final valide = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
    return valide ? null : PocOffresStrings.erreurEmail;
  }

  String? get _erreurTelephone {
    final chiffres = _telephone.text.replaceAll(RegExp(r'[\s.\-]'), '');
    final valide = RegExp(r'^(0|\+33)[1-9]\d{8}$').hasMatch(chiffres);
    return valide ? null : PocOffresStrings.erreurTelephone;
  }

  String? get _erreurCvAffichee => _erreurCv ?? (_essaiEnvoi && _cv == null ? PocOffresStrings.erreurCvAbsent : null);

  DsfrComponentState _etat(String? erreur) {
    return _essaiEnvoi && erreur != null ? DsfrComponentState.error(errorMessage: erreur) : const DsfrComponentState.none();
  }

  void _envoyer() {
    setState(() => _essaiEnvoi = true);
    final erreurs = [_erreurNom, _erreurPrenom, _erreurEmail, _erreurTelephone, _erreurCvAffichee];
    if (erreurs.every((erreur) => erreur == null)) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final cible = widget.cible;
    return FiltresBottomSheet(
      title: cible.spontanee ? PocOffresStrings.envoyerMaCandidatureSpontanee : PocOffresStrings.envoyerMaCandidature,
      maxHeightFactor: 0.95,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RecapitulatifCible(cible),
                  const SizedBox(height: DsfrSpacings.s2w),
                  MandatoryFieldsLabel.some(),
                  const SizedBox(height: DsfrSpacings.s2w),
                  _champ(PocOffresStrings.nom, _nom, _erreurNom, autofill: AutofillHints.familyName),
                  _champ(PocOffresStrings.prenom, _prenom, _erreurPrenom, autofill: AutofillHints.givenName),
                  _champ(
                    PocOffresStrings.email,
                    _email,
                    _erreurEmail,
                    clavier: TextInputType.emailAddress,
                    autofill: AutofillHints.email,
                  ),
                  _champ(
                    PocOffresStrings.telephoneChamp,
                    _telephone,
                    _erreurTelephone,
                    aide: PocOffresStrings.telephoneAide,
                    clavier: TextInputType.phone,
                    autofill: AutofillHints.telephoneNumber,
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  _cvFranceTravail ? _cvDeFranceTravail() : _cvDuTelephone(),
                  const SizedBox(height: DsfrSpacings.s3w),
                  DsfrInput(
                    label: PocOffresStrings.messageRecruteur,
                    hintText: PocOffresStrings.messageAide,
                    controller: _message,
                    minLines: 4,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                ],
              ),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: PocOffresStrings.jEnvoieMaCandidature,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: _envoyer,
          ),
        ],
      ),
    );
  }

  Widget _champ(
    String libelle,
    TextEditingController controleur,
    String? erreur, {
    String? aide,
    TextInputType clavier = TextInputType.name,
    required String autofill,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
      child: DsfrInput(
        label: libelle,
        hintText: aide,
        controller: controleur,
        keyboardType: clavier,
        textCapitalization: clavier == TextInputType.name ? TextCapitalization.words : TextCapitalization.none,
        textInputAction: TextInputAction.next,
        autofillHints: [autofill],
        componentState: _etat(erreur),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _cvDeFranceTravail() {
    final cv = _cv;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TitreCv(PocOffresStrings.tonCvFranceTravail),
        const SizedBox(height: DsfrSpacings.s1w),
        if (cv != null) _CarteCv(cv: cv, onConsulter: () => _consulter(cv), onModifier: _choisirCvFranceTravail),
        _ErreurCv(_erreurCvAffichee),
      ],
    );
  }

  Widget _cvDuTelephone() {
    final cv = _cv;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TitreCv(PocOffresStrings.tonCv),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(PocOffresStrings.cvFormat, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context))),
        const SizedBox(height: DsfrSpacings.s2w),
        if (cv == null)
          DsfrButton(
            label: PocOffresStrings.ajouterMonCv,
            icon: DsfrIcons.systemUploadLine,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.lg,
            onPressed: _choisirFichier,
          )
        else
          _CarteCv(
            cv: cv,
            onConsulter: () => _consulter(cv),
            onModifier: _choisirFichier,
            onRetirer: () => setState(() => _cv = null),
          ),
        _ErreurCv(_erreurCvAffichee),
      ],
    );
  }

  void _consulter(_PocCv cv) {
    final chemin = cv.chemin;
    if (chemin != null) {
      OpenFilex.open(chemin);
    } else {
      showSnackBarWithInformation(context, PocOffresStrings.cvApercuDemo);
    }
  }

  Future<void> _choisirCvFranceTravail() async {
    final choix = await showPassEmploiBottomSheet<String>(
      context: context,
      builder: (_) => FiltresBottomSheet(title: PocOffresStrings.choisirCv, body: _ChoixCvFranceTravail(selection: _cv?.nom)),
    );
    if (choix == null || !mounted) return;
    if (choix == _ChoixCvFranceTravail.telephone) {
      await _choisirFichier();
    } else {
      setState(() {
        _cv = _PocCv(choix);
        _erreurCv = null;
      });
    }
  }

  Future<void> _choisirFichier() async {
    try {
      final resultat = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
      final fichier = resultat?.files.single;
      if (fichier == null || !mounted) return;
      final extension = fichier.extension?.toLowerCase();
      setState(() {
        if (extension != 'pdf' && extension != 'docx') {
          _erreurCv = PocOffresStrings.erreurCvFormat;
        } else if (fichier.size > _tailleMaxCv) {
          _erreurCv = PocOffresStrings.erreurCvTropLourd;
        } else {
          _cv = _PocCv(fichier.name, chemin: fichier.path);
          _erreurCv = null;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _erreurCv = PocOffresStrings.erreurCvLecture);
    }
  }
}

class _RecapitulatifCible extends StatelessWidget {
  const _RecapitulatifCible(this.cible);

  final PocCibleCandidature cible;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundAltGrey(context),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cible.titre,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(cible.sousTitre, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context))),
          ],
        ),
      ),
    );
  }
}

class _TitreCv extends StatelessWidget {
  const _TitreCv(this.titre);

  final String titre;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(titre, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
    );
  }
}

class _CarteCv extends StatelessWidget {
  const _CarteCv({required this.cv, required this.onConsulter, required this.onModifier, this.onRetirer});

  final _PocCv cv;
  final VoidCallback onConsulter;
  final VoidCallback onModifier;
  final VoidCallback? onRetirer;

  @override
  Widget build(BuildContext context) {
    final onRetirer = this.onRetirer;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(cv.nom, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
            const SizedBox(height: DsfrSpacings.s2w),
            // Comme la page CV depuis le 28/10 : « Consulter » avec l'œil, et non « Voir le CV ».
            DsfrButton(
              label: Strings.cvConsultButton,
              icon: DsfrIcons.systemEyeLine,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.md,
              onPressed: onConsulter,
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: DsfrSpacings.s3w,
              children: [
                if (onRetirer != null)
                  DsfrLink(label: PocOffresStrings.retirer, icon: DsfrIcons.systemDeleteBinLine, onTap: onRetirer),
                DsfrLink(label: PocOffresStrings.modifier, icon: DsfrIcons.designPencilLine, onTap: onModifier),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErreurCv extends StatelessWidget {
  const _ErreurCv(this.erreur);

  final String? erreur;

  @override
  Widget build(BuildContext context) {
    final erreur = this.erreur;
    if (erreur == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
      child: Semantics(
        liveRegion: true,
        child: Text(erreur, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultError(context))),
      ),
    );
  }
}

class _ChoixCvFranceTravail extends StatelessWidget {
  const _ChoixCvFranceTravail({required this.selection});

  static const telephone = '__telephone__';

  final String? selection;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          PocOffresStrings.cvFranceTravailListe,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        for (final cv in pocCvFranceTravail)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(DsfrIcons.documentFilePdfLine, color: DsfrColorDecisions.textActionHighBlueFrance(context)),
            title: Text(cv, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
            trailing: cv == selection
                ? Icon(DsfrIcons.systemCheckLine, color: DsfrColorDecisions.textActionHighBlueFrance(context))
                : null,
            selected: cv == selection,
            onTap: () => Navigator.pop(context, cv),
          ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOffresStrings.cvDuTelephone,
          icon: DsfrIcons.systemUploadLine,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context, telephone),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
      ],
    );
  }
}

class CandidatureConfirmationPage extends StatelessWidget {
  const CandidatureConfirmationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(fullscreenDialog: true, builder: (_) => const CandidatureConfirmationPage());
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    final prenom = store.state.user()?.firstName ?? '';
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: DsfrButton(
                  label: Strings.close,
                  icon: DsfrIcons.systemCloseLine,
                  iconLocation: DsfrButtonIconLocation.right,
                  variant: DsfrButtonVariant.tertiaryWithoutBorder,
                  size: DsfrComponentSize.sm,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: DsfrSpacings.s3w),
                      const SuccessIllustration(size: 80),
                      const SizedBox(height: DsfrSpacings.s3w),
                      DsfrBadge(
                        label: PocOffresStrings.candidatureEnvoyee,
                        type: DsfrBadgeType.success,
                        size: DsfrComponentSize.sm,
                      ),
                      const SizedBox(height: DsfrSpacings.s2w),
                      Semantics(
                        header: true,
                        child: Text(
                          PocOffresStrings.bravo(prenom),
                          textAlign: TextAlign.center,
                          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                        ),
                      ),
                      const SizedBox(height: DsfrSpacings.s2w),
                      Text(
                        PocOffresStrings.confirmationTexte,
                        textAlign: TextAlign.center,
                        style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                      ),
                    ],
                  ),
                ),
              ),
              BottomActions(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DsfrButton(
                      label: PocOffresStrings.voirAutresOffres,
                      variant: DsfrButtonVariant.primary,
                      size: DsfrComponentSize.lg,
                      // Ferme la confirmation et la fiche : retour aux résultats.
                      onPressed: () => Navigator.of(context)
                        ..pop()
                        ..pop(),
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  SizedBox(
                    width: double.infinity,
                    child: DsfrButton(
                      label: PocOffresStrings.monSuiviDesOffres,
                      variant: DsfrButtonVariant.secondary,
                      size: DsfrComponentSize.lg,
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        store.dispatch(HandleDeepLinkAction(OffresEnregistreesDeepLink(), DeepLinkOrigin.inAppNavigation));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
