import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:kanban_project/main.dart';
import 'package:kanban_project/models/task.dart';
import 'package:kanban_project/models/kanban_column.dart';
import 'package:kanban_project/providers/kanban_provider.dart';

void main() {
  group('KanbanProvider', () {
    late KanbanProvider provider;

    setUp(() {
      provider = KanbanProvider();
    });

    test('initialise avec des données de démo', () {
      expect(provider.columns.length, 3);
      expect(provider.totalTasks, greaterThan(0));
    });

    test('colonnes correspondent aux statuts attendus', () {
      expect(provider.columns[0].status, ColumnStatus.todo);
      expect(provider.columns[1].status, ColumnStatus.inProgress);
      expect(provider.columns[2].status, ColumnStatus.done);
    });

    test('addTask ajoute une tâche à la bonne colonne', () {
      final initialCount = provider.taskCountFor(ColumnStatus.todo);
      provider.addTask(
        title: 'Test tâche',
        description: 'Description test',
        priority: TaskPriority.high,
        column: ColumnStatus.todo,
      );
      expect(provider.taskCountFor(ColumnStatus.todo), initialCount + 1);
    });

    test('addTask notifie les listeners', () {
      bool notified = false;
      provider.addListener(() => notified = true);
      provider.addTask(title: 'Tâche notification');
      expect(notified, isTrue);
    });

    test('moveTask déplace une tâche entre colonnes', () {
      final todoCountBefore = provider.taskCountFor(ColumnStatus.todo);
      final inProgressCountBefore =
          provider.taskCountFor(ColumnStatus.inProgress);

      final task = provider.columnByStatus(ColumnStatus.todo).tasks.first;
      provider.moveTask(task, ColumnStatus.todo, ColumnStatus.inProgress);

      expect(provider.taskCountFor(ColumnStatus.todo), todoCountBefore - 1);
      expect(provider.taskCountFor(ColumnStatus.inProgress),
          inProgressCountBefore + 1);
    });

    test('moveTask ne fait rien si même colonne', () {
      final countBefore = provider.taskCountFor(ColumnStatus.todo);
      final task = provider.columnByStatus(ColumnStatus.todo).tasks.first;
      provider.moveTask(task, ColumnStatus.todo, ColumnStatus.todo);
      expect(provider.taskCountFor(ColumnStatus.todo), countBefore);
    });

    test('deleteTask supprime la tâche', () {
      final task = provider.columnByStatus(ColumnStatus.todo).tasks.first;
      final countBefore = provider.taskCountFor(ColumnStatus.todo);
      provider.deleteTask(task.id);
      expect(provider.taskCountFor(ColumnStatus.todo), countBefore - 1);
    });

    test('updateTask modifie les propriétés de la tâche', () {
      final task = provider.columnByStatus(ColumnStatus.todo).tasks.first;
      provider.updateTask(
        taskId: task.id,
        title: 'Titre modifié',
        description: 'Nouvelle description',
        priority: TaskPriority.low,
      );
      final updated =
          provider.columnByStatus(ColumnStatus.todo).tasks.firstWhere(
                (t) => t.id == task.id,
              );
      expect(updated.title, 'Titre modifié');
      expect(updated.description, 'Nouvelle description');
      expect(updated.priority, TaskPriority.low);
    });

    test('getTaskColumn retourne la bonne colonne', () {
      final task = provider.columnByStatus(ColumnStatus.inProgress).tasks.first;
      expect(provider.getTaskColumn(task.id), ColumnStatus.inProgress);
    });

    test('getTaskColumn retourne null pour un id inconnu', () {
      expect(provider.getTaskColumn('inexistant'), isNull);
    });
  });

  group('Task model', () {
    test('copyWith crée une copie avec les nouvelles valeurs', () {
      final task = Task(id: '1', title: 'Original');
      final copy = task.copyWith(title: 'Copie', priority: TaskPriority.high);
      expect(copy.id, '1');
      expect(copy.title, 'Copie');
      expect(copy.priority, TaskPriority.high);
    });

    test('Task garde son id et createdAt après copyWith', () {
      final task = Task(id: 'abc', title: 'Test');
      final copy = task.copyWith(title: 'Autre');
      expect(copy.id, task.id);
      expect(copy.createdAt, task.createdAt);
    });
  });

  group('KanbanApp widget', () {
    testWidgets('affiche le KanbanBoardScreen', (tester) async {
      await tester.pumpWidget(const KanbanApp());
      await tester.pumpAndSettle();
      expect(find.text('Kanban Board'), findsOneWidget);
    });

    testWidgets('affiche les trois colonnes', (tester) async {
      await tester.pumpWidget(const KanbanApp());
      await tester.pumpAndSettle();
      expect(find.text('À faire'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('Terminé'), findsOneWidget);
    });

    testWidgets('le bouton FAB est présent', (tester) async {
      await tester.pumpWidget(const KanbanApp());
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle tâche'), findsOneWidget);
    });

    testWidgets('ouvrir le dialogue d\'ajout via FAB', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => KanbanProvider(),
          child: const MaterialApp(home: Scaffold(body: KanbanApp())),
        ),
      );
      await tester.pumpWidget(const KanbanApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nouvelle tâche'));
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle tâche'), findsWidgets);
    });
  });
}
