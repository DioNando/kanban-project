import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/kanban_provider.dart';
import 'screens/kanban_board_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KanbanApp());
}

class KanbanApp extends StatelessWidget {
  const KanbanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KanbanProvider(),
      child: MaterialApp(
        title: 'Kanban Project',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const KanbanBoardScreen(),
      ),
    );
  }
}
