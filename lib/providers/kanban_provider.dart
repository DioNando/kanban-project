import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/kanban_column.dart';

class KanbanProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  final List<KanbanColumn> _columns = [
    KanbanColumn(
      status: ColumnStatus.todo,
      tasks: [
        Task(
          id: '1',
          title: 'Concevoir la maquette UI',
          description: 'Créer les wireframes de l\'application',
          priority: TaskPriority.high,
        ),
        Task(
          id: '2',
          title: 'Configurer le projet Flutter',
          description: 'Initialiser le projet et les dépendances',
          priority: TaskPriority.medium,
        ),
      ],
    ),
    KanbanColumn(
      status: ColumnStatus.inProgress,
      tasks: [
        Task(
          id: '3',
          title: 'Développer les modèles de données',
          description: 'Créer les classes Task et KanbanColumn',
          priority: TaskPriority.high,
        ),
      ],
    ),
    KanbanColumn(
      status: ColumnStatus.done,
      tasks: [
        Task(
          id: '4',
          title: 'Analyse des besoins',
          description: 'Rédiger les spécifications fonctionnelles',
          priority: TaskPriority.low,
        ),
      ],
    ),
  ];

  List<KanbanColumn> get columns => _columns;

  KanbanColumn columnByStatus(ColumnStatus status) {
    return _columns.firstWhere((col) => col.status == status);
  }

  void addTask({
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    ColumnStatus column = ColumnStatus.todo,
  }) {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
    );
    final col = _columns.firstWhere((c) => c.status == column);
    col.tasks.add(task);
    notifyListeners();
  }

  void moveTask(Task task, ColumnStatus fromStatus, ColumnStatus toStatus) {
    if (fromStatus == toStatus) return;
    final fromCol = _columns.firstWhere((c) => c.status == fromStatus);
    final toCol = _columns.firstWhere((c) => c.status == toStatus);
    fromCol.tasks.removeWhere((t) => t.id == task.id);
    toCol.tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    for (final col in _columns) {
      col.tasks.removeWhere((t) => t.id == taskId);
    }
    notifyListeners();
  }

  void updateTask({
    required String taskId,
    required String title,
    String description = '',
    required TaskPriority priority,
  }) {
    for (final col in _columns) {
      final index = col.tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        col.tasks[index] = col.tasks[index].copyWith(
          title: title,
          description: description,
          priority: priority,
        );
        notifyListeners();
        return;
      }
    }
  }

  ColumnStatus? getTaskColumn(String taskId) {
    for (final col in _columns) {
      if (col.tasks.any((t) => t.id == taskId)) {
        return col.status;
      }
    }
    return null;
  }

  int get totalTasks =>
      _columns.fold(0, (sum, col) => sum + col.tasks.length);

  int taskCountFor(ColumnStatus status) {
    return columnByStatus(status).tasks.length;
  }
}
