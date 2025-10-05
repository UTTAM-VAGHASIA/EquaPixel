import 'thread.dart';

class Connection {
  final int fromNailId;
  final int toNailId;
  final Thread thread;
  final double errorReduction;

  Connection({
    required this.fromNailId,
    required this.toNailId,
    required this.thread,
    required this.errorReduction,
  });

  Connection copyWith({
    int? fromNailId,
    int? toNailId,
    Thread? thread,
    double? errorReduction,
  }) {
    return Connection(
      fromNailId: fromNailId ?? this.fromNailId,
      toNailId: toNailId ?? this.toNailId,
      thread: thread ?? this.thread,
      errorReduction: errorReduction ?? this.errorReduction,
    );
  }

  @override
  String toString() => 'Connection($fromNailId -> $toNailId)';
}