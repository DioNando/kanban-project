# Kanban Project

Application de gestion de tâches Kanban — MVP Flutter.

## Fonctionnalités

- **Tableau Kanban** avec 3 colonnes : *À faire*, *En cours*, *Terminé*
- **Ajout de tâches** via un formulaire (titre, description, priorité, colonne)
- **Modification** d'une tâche (tap sur la carte ou menu contextuel)
- **Suppression** d'une tâche avec confirmation
- **Glisser-déposer** pour déplacer les tâches entre colonnes
- **Priorités** : Faible, Moyenne, Haute (avec code couleur)
- Compteur de tâches par colonne et total dans l'AppBar

## Structure du projet

```
lib/
├── main.dart                        # Point d'entrée de l'application
├── models/
│   ├── task.dart                    # Modèle Task + enum TaskPriority
│   └── kanban_column.dart           # Modèle KanbanColumn + enum ColumnStatus
├── providers/
│   └── kanban_provider.dart         # State management (ChangeNotifier)
├── screens/
│   └── kanban_board_screen.dart     # Écran principal du tableau
├── widgets/
│   ├── kanban_column_widget.dart    # Widget colonne avec drag-target
│   ├── task_card.dart               # Carte de tâche draggable
│   └── add_task_dialog.dart         # Dialogue ajout/modification de tâche
└── theme/
    └── app_theme.dart               # Thème Material 3
```

## Stack technique

| Technologie | Usage |
|---|---|
| Flutter 3+ | Framework UI cross-platform |
| Provider 6 | Gestion d'état (ChangeNotifier) |
| UUID | Génération d'identifiants uniques |
| Material 3 | Design system |

## Lancer l'application

```bash
# Installer les dépendances
flutter pub get

# Lancer sur le device/émulateur de votre choix
flutter run

# Lancer les tests
flutter test
```

## Roadmap (post-MVP)

- [ ] Persistance locale avec `shared_preferences` ou `hive`
- [ ] Réorganisation par glisser-déposer à l'intérieur d'une colonne
- [ ] Dates d'échéance et rappels
- [ ] Attribution de tâches à des membres
- [ ] Plusieurs tableaux
- [ ] Mode sombre
- [ ] Synchronisation cloud (Firebase / Supabase)
