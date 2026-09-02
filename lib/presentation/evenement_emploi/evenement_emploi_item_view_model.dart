import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/evenement_emploi/evenement_emploi.dart';
import 'package:pass_emploi_app/models/evenement_emploi/evenement_emploi_type.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

class EvenementEmploiItemViewModel extends Equatable {
  final String id;
  final String type;
  final String titre;
  final String dateLabel;
  final String heureLabel;
  final String locationLabel;
  final String emoji;
  final Color emojiBackground;

  EvenementEmploiItemViewModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.dateLabel,
    required this.heureLabel,
    required this.locationLabel,
    required this.emoji,
    required this.emojiBackground,
  });

  factory EvenementEmploiItemViewModel.create(EvenementEmploi evenement) {
    final type = evenementEmploiTypeFromLabel(evenement.type);
    return EvenementEmploiItemViewModel(
      id: evenement.id,
      type: evenement.type,
      titre: evenement.titre,
      dateLabel: evenement.dateDebut.toDay(),
      heureLabel: '${evenement.dateDebut.toHourWithHSeparator()} - ${evenement.dateFin.toHourWithHSeparator()}',
      locationLabel: '${evenement.codePostal} ${evenement.ville}',
      emoji: type?.emoji ?? evenementEmploiDefaultEmoji,
      emojiBackground: type?.emojiBackground ?? evenementEmploiDefaultEmojiBackground,
    );
  }

  @override
  List<Object?> get props => [id, type, titre, dateLabel, heureLabel, locationLabel, emoji, emojiBackground];
}
