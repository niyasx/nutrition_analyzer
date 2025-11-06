import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrition_app/core/error/failures.dart';
import 'package:nutrition_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_event.dart';
import 'package:nutrition_app/features/nutrition/presentation/bloc/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final NutritionRepository _repository;

  HistoryBloc({required NutritionRepository nutritionRepository})
      : _repository = nutritionRepository,
        super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<RefreshHistory>(_onRefreshHistory);
    on<DeleteAnalysis>(_onDeleteAnalysis);
    on<LoadAnalysisDetail>(_onLoadAnalysisDetail);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      emit(const HistoryLoading());
      final results = await _repository.getAnalysisHistory();
      emit(HistoryLoaded(results: results));
      log('History loaded: ${results.length} items');
    } catch (e) {
      log('Failed to load history: $e');
      emit(HistoryError(
        failure: CacheFailure(message: 'Failed to load history'),
      ));
    }
  }

  Future<void> _onRefreshHistory(
    RefreshHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      final results = await _repository.getAnalysisHistory();
      emit(HistoryLoaded(results: results));
      log('History refreshed: ${results.length} items');
    } catch (e) {
      log('Failed to refresh history: $e');
      emit(HistoryError(
        failure: CacheFailure(message: 'Failed to refresh history'),
      ));
    }
  }

  Future<void> _onDeleteAnalysis(
    DeleteAnalysis event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.deleteAnalysis(event.analysisId);
      
      // Reload history after deletion
      final results = await _repository.getAnalysisHistory();
      emit(HistoryLoaded(results: results));
      log('Analysis deleted and history refreshed');
    } catch (e) {
      log('Failed to delete analysis: $e');
      emit(HistoryError(
        failure: CacheFailure(message: 'Failed to delete analysis'),
      ));
    }
  }

  Future<void> _onLoadAnalysisDetail(
    LoadAnalysisDetail event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      emit(const HistoryLoading());
      final result = await _repository.getAnalysisById(event.analysisId);
      
      if (result != null) {
        emit(HistoryDetailLoaded(result: result));
        log('Analysis detail loaded: ${result.id}');
      } else {
        emit(const HistoryError(
          failure: CacheFailure(message: 'Analysis not found'),
        ));
      }
    } catch (e) {
      log('Failed to load analysis detail: $e');
      emit(HistoryError(
        failure: CacheFailure(message: 'Failed to load analysis detail'),
      ));
    }
  }
}