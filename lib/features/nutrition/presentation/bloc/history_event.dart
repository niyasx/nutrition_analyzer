import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

class RefreshHistory extends HistoryEvent {
  const RefreshHistory();
}

class DeleteAnalysis extends HistoryEvent {
  final String analysisId;

  const DeleteAnalysis({required this.analysisId});

  @override
  List<Object?> get props => [analysisId];
}

class LoadAnalysisDetail extends HistoryEvent {
  final String analysisId;

  const LoadAnalysisDetail({required this.analysisId});

  @override
  List<Object?> get props => [analysisId];
}