import 'package:flutter/material.dart';
import '../models/task.dart';

enum ColumnStatus { todo, inProgress, done }

extension ColumnStatusExtension on ColumnStatus {
  String get label {
    switch (this) {
      case ColumnStatus.todo:
        return 'À faire';
      case ColumnStatus.inProgress:
        return 'En cours';
      case ColumnStatus.done:
        return 'Terminé';
    }
  }

  Color get color {
    switch (this) {
      case ColumnStatus.todo:
        return const Color(0xFF5C6BC0);
      case ColumnStatus.inProgress:
        return const Color(0xFFFF8F00);
      case ColumnStatus.done:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get icon {
    switch (this) {
      case ColumnStatus.todo:
        return Icons.inbox_outlined;
      case ColumnStatus.inProgress:
        return Icons.autorenew;
      case ColumnStatus.done:
        return Icons.check_circle_outline;
    }
  }
}

class KanbanColumn {
  final ColumnStatus status;
  final List<Task> tasks;

  KanbanColumn({required this.status, List<Task>? tasks})
      : tasks = tasks ?? [];
}
