import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/date_consultation_notification/date_consultation_notification_actions.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/notifications_center/notifications_center_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(
      builder: (_) => const NotificationCenter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.centreNotification,
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        appBar: const BackAppBar(),
        body: StoreConnector<AppState, NotificationsCenterViewModel>(
          converter: (store) => NotificationsCenterViewModel.create(store),
          builder: (context, viewModel) => _PageBody(viewModel),
          onDispose: (store) => store.dispatch(DateConsultationNotificationWriteAction(DateTime.now())),
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody(this.viewModel);

  final NotificationsCenterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: PageTitle(Strings.notificationsCenterTitle),
          ),
          Expanded(child: _DisplayState(viewModel)),
        ],
      ),
    );
  }
}

class _DisplayState extends StatelessWidget {
  const _DisplayState(this.viewModel);
  final NotificationsCenterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState) {
      DisplayState.CONTENT => _Body(viewModel: viewModel),
      DisplayState.LOADING => const _LoadingIndicator(),
      DisplayState.FAILURE => Retry(Strings.notificationsCenterError, () => viewModel.retry()),
      DisplayState.EMPTY => const _Empty(),
    };
  }
}

class _Body extends StatelessWidget {
  final NotificationsCenterViewModel viewModel;

  const _Body({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: viewModel.notifications.length,
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      separatorBuilder: (_, __) => const SizedBox(height: DsfrSpacings.s3v),
      itemBuilder: (context, index) {
        final notification = viewModel.notifications[index];
        return _NotificationTile(notification: notification);
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.loadingAnnouncement,
      liveRegion: true,
      child: Center(
        child: CircularProgressIndicator(
          color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: DsfrColorDecisions.backgroundContrastBlueFrance(context),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: SizedBox.square(
                  dimension: 80,
                  child: Icon(
                    DsfrIcons.mediaNotification3Line,
                    size: 40,
                    color: DsfrColorDecisions.textTitleBlueFrance(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            Strings.notificationsCenterEmptyTitle,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});
  final NotificationViewModel notification;

  bool get _isTappable => notification.onPressed != null;

  String get _semanticsLabel {
    return [
      if (notification.isNew) Strings.newPillule,
      notification.title,
      notification.description,
      notification.date,
    ].join('. ');
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(4));
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context)),
    );

    final content = Padding(
      padding: const EdgeInsets.all(DsfrSpacings.s3w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.isNew) ...[
            DsfrBadge(
              label: Strings.newPillule,
              type: DsfrBadgeType.news,
              size: DsfrComponentSize.sm,
              withIcon: true,
            ),
            const SizedBox(height: DsfrSpacings.s1w),
          ],
          Text(
            notification.title,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
          ),
          const SizedBox(height: DsfrSpacings.s1v),
          Text(
            notification.description,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s3v),
          Row(
            children: [
              Icon(
                DsfrIcons.systemTimeLine,
                size: DsfrSpacings.s2w,
                color: DsfrColorDecisions.textMentionGrey(context),
              ),
              const SizedBox(width: DsfrSpacings.s2w),
              Expanded(
                child: Text(
                  notification.date,
                  style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      button: _isTappable,
      label: _semanticsLabel,
      onTap: notification.onPressed,
      child: ExcludeSemantics(
        child: Material(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: _isTappable
              ? InkWell(
                  onTap: notification.onPressed,
                  customBorder: shape,
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
