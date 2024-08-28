part of 'sse_cubit.dart';

abstract class SseState extends Equatable {
  const SseState();

  @override
  List<Object> get props => [];
}

class SseInitial extends SseState {}

class SseLoading extends SseState {}

class SseLoaded extends SseState {
  final String event;

  const SseLoaded(this.event);

  @override
  List<Object> get props => [event];
}

class SseError extends SseState {
  final String message;

  const SseError(this.message);

  @override
  List<Object> get props => [message];
}

class SseComplete extends SseState {}
