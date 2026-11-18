import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/chat/messages/chat_actions.dart';
import 'package:pass_emploi_app/models/chat/message.dart';
import 'package:pass_emploi_app/models/chat/sender.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';
import 'package:uuid/uuid.dart';

String messagePourLeConseiller(MesPistesEtat etat) {
  final total = Piste.nombreActions;
  final profil = etat.profilRiasec;
  return [
    PocOrientationStrings.messageIntro,
    if (etat.quiTentent.isNotEmpty) ...[
      '',
      PocOrientationStrings.messageQuiTentent,
      for (final piste in etat.quiTentent)
        '- ${piste.metier.libelle} : ${PocOrientationStrings.messageOuJenSuis(piste.etapeEnCours, piste.nombreFaites, total)}',
    ],
    if (etat.misDeCote.isNotEmpty) ...[
      '',
      PocOrientationStrings.messageMisDeCote,
      for (final piste in etat.misDeCote)
        piste.raisons.isEmpty
            ? '- ${piste.metier.libelle}'
            : '- ${piste.metier.libelle} : ${piste.raisons.map((raison) => _minuscule(raison.libelle)).join(" ; ")}',
    ],
    if (profil != null && !profil.estPlat || etat.centresInteret.isNotEmpty) '',
    if (profil != null && !profil.estPlat)
      PocOrientationStrings.messageProfil(profil.dominants.map((type) => type.nom).toList()),
    if (etat.centresInteret.isNotEmpty) PocOrientationStrings.messageCentres(etat.centresInteret),
    '',
    PocOrientationStrings.messageConclusion,
  ].join('\n');
}

String _minuscule(String texte) => texte.isEmpty ? texte : texte[0].toLowerCase() + texte.substring(1);

// En démo, le message partagé s'ajoute à la messagerie fictive (voir modeDemoChat) : rien ne part sur le réseau.
class PocMessagesDemo {
  static final _messages = <Message>[];

  static List<Message> get messages => List.unmodifiable(_messages);

  static void ajouter(String texte) {
    _messages.add(
      Message(
        id: const Uuid().v4(),
        content: texte,
        creationDate: DateTime.now(),
        sentBy: Sender.jeune,
        type: MessageType.message,
        sendingStatus: MessageSendingStatus.sent,
        contentStatus: MessageContentStatus.content,
        pieceJointes: const [],
      ),
    );
  }

  static void vider() => _messages.clear();
}

Future<void> afficherPartageConseiller(BuildContext context) async {
  final envoye = await showPassEmploiBottomSheet<bool>(
    context: context,
    builder: (_) => BottomSheetWrapper(
      title: PocOrientationStrings.partagerTitre,
      body: _PartageConseiller(message: messagePourLeConseiller(MesPistes.instance.value)),
    ),
  );
  if (envoye == true && context.mounted) showSnackBarWithSuccess(context, PocOrientationStrings.partagerSucces);
}

class _PartageConseiller extends StatelessWidget {
  const _PartageConseiller({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final demo = StoreProvider.of<AppState>(context).state.demoState;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            PocOrientationStrings.partagerIntro,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DecoratedBox(
            decoration: BoxDecoration(
              color: DsfrColorDecisions.backgroundAltGrey(context),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DsfrSpacings.s2w),
              child: Text(message, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context))),
            ),
          ),
          if (demo) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            Text(
              PocOrientationStrings.partagerDemo,
              style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
          ],
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: PocOrientationStrings.partagerEnvoyer,
            icon: DsfrIcons.businessSendPlaneLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: () => _envoyer(context, demo: demo),
          ),
        ],
      ),
    );
  }

  void _envoyer(BuildContext context, {required bool demo}) {
    if (demo) {
      PocMessagesDemo.ajouter(message);
    } else {
      StoreProvider.of<AppState>(context, listen: false).dispatch(SendMessageAction(message));
    }
    Navigator.pop(context, true);
  }
}
