import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class ChatListView extends StatelessWidget {
  final ScrollController? controller;
  final List<dynamic> reversedItems;
  final NullableIndexedWidgetBuilder itemBuilder;

  const ChatListView({
    this.controller,
    required this.reversedItems,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: controller,
      itemCount: reversedItems.length,
      itemBuilder: itemBuilder,
    );
  }
}
