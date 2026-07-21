import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingLocationStep extends StatefulWidget {
  const InviteOnboardingLocationStep({
    super.key,
    required this.form,
    required this.communesRepository,
    required this.isHabitation,
  });

  final InviteOnboardingFormChangeNotifier form;
  final CommunesRepository communesRepository;
  final bool isHabitation;

  @override
  State<InviteOnboardingLocationStep> createState() => _InviteOnboardingLocationStepState();
}

class _InviteOnboardingLocationStepState extends State<InviteOnboardingLocationStep> {
  List<InviteCommune> _suggestions = [];
  Timer? _debounce;
  late final TextEditingController _controller;

  InviteOnboardingFormChangeNotifier get form => widget.form;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentQuery);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant InviteOnboardingLocationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHabitation != widget.isHabitation) {
      _controller.text = _currentQuery;
      setState(() => _suggestions = []);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  String get _currentQuery => widget.isHabitation ? form.draftHabitationQuery : form.draftVilleQuery;

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final label = widget.isHabitation ? Strings.inviteOnboardingHabitationLabel : Strings.inviteOnboardingVilleLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.isHabitation ? Strings.inviteOnboardingHabitationSubtitle : Strings.inviteOnboardingVilleSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        Text(
          label,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrInputHeadless(
          key: ValueKey(widget.isHabitation ? 'habitation' : 'ville'),
          controller: _controller,
          onChanged: _onQueryChanged,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  tooltip: Strings.clear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  icon: Icon(
                    DsfrIcons.systemCloseLine,
                    size: 16,
                    color: DsfrColorDecisions.textDefaultGrey(context),
                  ),
                  onPressed: _clearQuery,
                )
              : null,
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: Margins.spacing_s),
          ..._suggestions.map(
            (commune) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                commune.displayLabel,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              onTap: () => _onCommuneSelected(commune),
            ),
          ),
        ],
        if (!widget.isHabitation) ...[
          const SizedBox(height: Margins.spacing_base),
          Text(
            Strings.inviteOnboardingVilleOr,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ],
        const SizedBox(height: Margins.spacing_base),
        DsfrButton(
          label: Strings.inviteOnboardingGeolocate,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          icon: DsfrIcons.mapMapPin2Line,
          onPressed: form.isGeolocating ? null : _geolocate,
        ),
        if (form.geolocationError != null) ...[
          const SizedBox(height: Margins.spacing_s),
          Text(
            form.geolocationError!,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultError(context)),
          ),
        ],
        if (!widget.isHabitation) ...[
          const SizedBox(height: Margins.spacing_l),
          DsfrSlider(
            label: Strings.inviteOnboardingRayonLabel,
            description: Strings.inviteOnboardingRayonDescription(form.draftRayonKm),
            value: form.draftRayonKm.toDouble(),
            min: 10,
            max: 100,
            divisions: 9,
            size: DsfrComponentSize.md,
            valueLabelBuilder: (value) => Strings.inviteOnboardingRayonValue(value.round()),
            showMinMaxLabels: true,
            onChanged: form.updateRayon,
          ),
        ],
      ],
    );
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _suggestions = []);
    if (widget.isHabitation) {
      form.updateHabitationQuery('');
    } else {
      form.updateVilleQuery('');
    }
  }

  void _onQueryChanged(String value) {
    if (widget.isHabitation) {
      form.updateHabitationQuery(value);
    } else {
      form.updateVilleQuery(value);
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await widget.communesRepository.search(value);
      if (!mounted) return;
      setState(() => _suggestions = results);
    });
  }

  Future<void> _onCommuneSelected(InviteCommune commune) async {
    setState(() => _suggestions = []);
    if (widget.isHabitation) {
      await form.selectHabitationAndContinue(commune);
    } else {
      await form.selectVilleAndContinue(commune);
    }
  }

  Future<void> _geolocate() async {
    form.setGeolocating(true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        form.setGeolocationError(Strings.inviteOnboardingGeolocateError);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        form.setGeolocationError(Strings.inviteOnboardingGeolocateError);
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final commune = await widget.communesRepository.findByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (commune == null) {
        form.setGeolocationError(Strings.inviteOnboardingGeolocateError);
        return;
      }
      setState(() => _suggestions = []);
      _controller.text = commune.displayLabel;
      if (widget.isHabitation) {
        form.selectHabitation(commune);
      } else {
        form.selectVilleRecherche(commune);
      }
      form.setGeolocating(false);
    } catch (_) {
      form.setGeolocationError(Strings.inviteOnboardingGeolocateError);
    }
  }
}
