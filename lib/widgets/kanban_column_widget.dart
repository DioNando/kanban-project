import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/kanban_column.dart';
import '../providers/kanban_provider.dart';
import '../theme/app_theme.dart';
import 'task_card.dart';
import 'add_task_dialog.dart';

class KanbanColumnWidget extends StatefulWidget {
  final KanbanColumn column;

  const KanbanColumnWidget({super.key, required this.column});

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.column.status;
    final tasks = widget.column.tasks;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) {
        final fromColumn =
            context.read<KanbanProvider>().getTaskColumn(details.data.id);
        return fromColumn != null && fromColumn != status;
      },
      onAcceptWithDetails: (details) {
        final fromColumn =
            context.read<KanbanProvider>().getTaskColumn(details.data.id);
        if (fromColumn != null) {
          context
              .read<KanbanProvider>()
              .moveTask(details.data, fromColumn, status);
        }
        setState(() => _isDragOver = false);
      },
      onMove: (_) => setState(() => _isDragOver = true),
      onLeave: (_) => setState(() => _isDragOver = false),
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _isDragOver
                ? status.color.withOpacity(0.08)
                : AppTheme.columnBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragOver
                  ? status.color.withOpacity(0.5)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              _ColumnHeader(column: widget.column),
              Expanded(
                child: tasks.isEmpty
                    ? _EmptyColumnPlaceholder(
                        status: status,
                        isDragOver: _isDragOver,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: tasks.length,
                        itemBuilder: (_, index) => TaskCard(
                          task: tasks[index],
                          currentColumn: status,
                        ),
                      ),
              ),
              _AddTaskButton(status: status),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  final KanbanColumn column;

  const _ColumnHeader({required this.column});

  @override
  Widget build(BuildContext context) {
    final status = column.status;
    final taskCount = column.tasks.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: status.color,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$taskCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyColumnPlaceholder extends StatelessWidget {
  final ColumnStatus status;
  final bool isDragOver;

  const _EmptyColumnPlaceholder({
    required this.status,
    required this.isDragOver,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDragOver ? Icons.add_circle_outline : Icons.inbox_outlined,
            size: 40,
            color: isDragOver
                ? status.color
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            isDragOver ? 'Déposer ici' : 'Aucune tâche',
            style: TextStyle(
              color: isDragOver ? status.color : Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  final ColumnStatus status;

  const _AddTaskButton({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(40),
          foregroundColor: status.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: status.color.withOpacity(0.3)),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Ajouter une tâche'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddTaskDialog(defaultColumn: status),
          );
        },
      ),
    );
  }
}
