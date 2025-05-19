part of 'pattern_cubit.dart';

sealed class PatternState extends Equatable {
  const PatternState();

  @override
  List<Object> get props => [];
}

final class PatternInitial extends PatternState {}

final class PatternLoading extends PatternState {}

final class PatternLoaded extends PatternState {
  final PatternModel pattern;
  const PatternLoaded({required this.pattern});
}

final class PatternError extends PatternState {
  final String message;
  const PatternError({required this.message});
}
