import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class RechercheCriteresFullScreen<Result> extends StatefulWidget {
  final RechercheState Function(AppState) rechercheState;
  final Widget Function({required Function(int) onNumberOfCriteresChanged}) buildCriteresContentWidget;

  const RechercheCriteresFullScreen({
    super.key,
    required this.rechercheState,
    required this.buildCriteresContentWidget,
  });

  @override
  State<RechercheCriteresFullScreen<Result>> createState() => _RechercheCriteresFullScreenState<Result>();
}

class _RechercheCriteresFullScreenState<Result> extends State<RechercheCriteresFullScreen<Result>> {
  int? _criteresActifsCount;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RechercheCriteresFullScreenViewModel<Result>>(
      converter: (store) => _RechercheCriteresFullScreenViewModel.create(store, widget.rechercheState),
      distinct: true,
      builder: (context, viewModel) {
        return SizedBox.expand(
          child: ColoredBox(
            color: Colors.white,
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.all(Margins.spacing_base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Margins.spacing_base),
                    widget.buildCriteresContentWidget(
                      onNumberOfCriteresChanged: (number) {
                        setState(() => _criteresActifsCount = number);
                        SemanticsService.announce(
                          intl.Intl.plural(
                            _criteresActifsCount ?? 0,
                            zero: Strings.rechercheCriteresActifsZero,
                            one: Strings.rechercheCriteresActifsOne,
                            other: Strings.rechercheCriteresActifsPlural(_criteresActifsCount ?? 0),
                          ),
                          TextDirection.ltr,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RechercheCriteresFullScreenViewModel<Result> extends Equatable {
  final bool canSeeResults;

  const _RechercheCriteresFullScreenViewModel({
    required this.canSeeResults,
  });

  factory _RechercheCriteresFullScreenViewModel.create(
    Store<AppState> store,
    RechercheState Function(AppState) rechercheState,
  ) {
    final state = rechercheState(store.state);
    return _RechercheCriteresFullScreenViewModel(
      canSeeResults: state.results != null,
    );
  }

  @override
  List<Object?> get props => [canSeeResults];
}
