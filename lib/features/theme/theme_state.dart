import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class ThemeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ThemeNotInitializedState extends ThemeState {}

class ThemeSuccessState extends ThemeState {
  final ThemeMode themeMode;

  ThemeSuccessState(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
