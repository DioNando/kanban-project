import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/kanban_column.dart';
import '../providers/kanban_provider.dart';

class AddTaskDialog extends StatefulWidget {
  final ColumnStatus defaultColumn;
  final Task? taskToEdit;

  const AddTaskDialog({
    super.key,
    this.defaultColumn = ColumnStatus.todo,
    this.taskToEdit,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _selectedPriority;
  late ColumnStatus _selectedColumn;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedPriority = widget.taskToEdit?.priority ?? TaskPriority.medium;
    _selectedColumn = widget.defaultColumn;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<KanbanProvider>();

    if (_isEditing) {
      provider.updateTask(
        taskId: widget.taskToEdit!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );
    } else {
      provider.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        column: _selectedColumn,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  hintText: 'Titre de la tâche',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description optionnelle',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priorité',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: priority.color, size: 12),
                        const SizedBox(width: 8),
                        Text(priority.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<ColumnStatus>(
                  value: _selectedColumn,
                  decoration: const InputDecoration(
                    labelText: 'Colonne',
                    prefixIcon: Icon(Icons.view_column_outlined),
                  ),
                  items: ColumnStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedColumn = value);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }
}
