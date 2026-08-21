import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/chat/message.dart';
import 'package:pass_emploi_app/models/chat/sender.dart';
import 'package:pass_emploi_app/pages/evenement_emploi/evenement_emploi_details_page.dart';
import 'package:pass_emploi_app/pages/immersion/immersion_details_page.dart';
import 'package:pass_emploi_app/pages/offre_emploi/offre_emploi_details_page.dart';
import 'package:pass_emploi_app/pages/rendezvous/rendezvous_details_page.dart';
import 'package:pass_emploi_app/pages/service_civique/service_civique_detail_page.dart';
import 'package:pass_emploi_app/pages/user_action/update/update_user_action_page.dart';
import 'package:pass_emploi_app/presentation/chat/chat_item.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/presentation/user_action/user_action_state_source.dart';
import 'package:pass_emploi_app/widgets/chat/chat_message_container.dart';
import 'package:pass_emploi_app/widgets/text_with_clickable_links.dart';

class PartageMessage extends StatelessWidget {
  final PartageMessageItem item;

  PartageMessage(this.item);

  @override
  Widget build(BuildContext context) {
    return ChatMessageContainer(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContentMessage(content: item.content, sender: item.sender),
          SizedBox(height: DsfrSpacings.s1w),
          _PartageCard(item: item),
        ],
      ),
      isPj: false,
      isMyMessage: item.sender == Sender.jeune,
      caption: item.caption,
      captionColor: item.captionColor,
    );
  }
}

class _ContentMessage extends StatelessWidget {
  final String content;
  final Sender sender;

  _ContentMessage({required this.content, required this.sender});

  @override
  Widget build(BuildContext context) {
    final style = chatBubbleTextStyle(context, isMyMessage: sender == Sender.jeune);
    return SelectableTextWithClickableLinks(
      content,
      linkStyle: style,
      style: style,
    );
  }
}

class _PartageCard extends StatelessWidget {
  final PartageMessageItem item;

  _PartageCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ChatBubbleActionButton(
      label: item.titrePartage,
      onPressed: () => _onTap(context),
    );
  }

  void _onTap(BuildContext context) {
    final item = this.item;
    if (item is OffreMessageItem) {
      _showOffreDetailsPage(context, item);
    } else if (item is EventMessageItem) {
      _showEventDetailsPage(context, item);
    } else if (item is EvenementEmploiMessageItem) {
      _showEvenementEmploiDetailsPage(context, item);
    } else if (item is SessionMiloMessageItem) {
      _showSessionMiloDetailsPage(context, item);
    } else if (item is ActionMessageItem) {
      _showUserActionDetailPage(context, item);
    }
  }

  void _showUserActionDetailPage(BuildContext context, ActionMessageItem item) {
    Navigator.push(
      context,
      UpdateUserActionPage.route(
        UserActionStateSource.chatPartage,
        item.idPartage,
      ),
    );
  }

  void _showOffreDetailsPage(BuildContext context, OffreMessageItem offreItem) {
    switch (offreItem.type) {
      case OffreType.emploi:
      case OffreType.alternance:
        Navigator.push(
          context,
          OffreEmploiDetailsPage.materialPageRoute(
            offreItem.idPartage,
            fromAlternance: offreItem.type == OffreType.alternance,
          ),
        );
        break;
      case OffreType.immersion:
        Navigator.push(
          context,
          ImmersionDetailsPage.materialPageRoute(offreItem.idPartage),
        );
        break;
      case OffreType.civique:
        Navigator.push(
          context,
          ServiceCiviqueDetailPage.materialPageRoute(offreItem.idPartage),
        );
        break;
      case OffreType.inconnu:
        break;
    }
  }

  void _showEventDetailsPage(BuildContext context, EventMessageItem item) {
    RendezvousDetailsPage.show(
      context,
      RendezvousStateSource.noSource,
      item.idPartage,
    );
  }

  void _showEvenementEmploiDetailsPage(
    BuildContext context,
    EvenementEmploiMessageItem item,
  ) {
    Navigator.push(
      context,
      EvenementEmploiDetailsPage.materialPageRoute(
        item.idPartage,
      ),
    );
  }

  void _showSessionMiloDetailsPage(
    BuildContext context,
    SessionMiloMessageItem item,
  ) {
    RendezvousDetailsPage.show(
      context,
      RendezvousStateSource.sessionMiloDetails,
      item.idPartage,
    );
  }
}

