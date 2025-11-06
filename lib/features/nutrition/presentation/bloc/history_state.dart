import 'package:equatable/equatable.dart';
import 'package:nutrition_app/features/nutrition/domain/entities/analysis_result.dart';
import 'package:nutrition_app/core/error/failures.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<AnalysisResult> results;

  const HistoryLoaded({required this.results});

  @override
  List<Object?> get props => [results];
}

class HistoryError extends HistoryState {
  final Failure failure;

  const HistoryError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

class HistoryDetailLoaded extends HistoryState {
  final AnalysisResult result;

  const HistoryDetailLoaded({required this.result});

  @override
  List<Object?> get props => [result];
}