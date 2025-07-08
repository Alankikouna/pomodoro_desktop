import 'package:flutter/material.dart';

class ExeTile extends StatelessWidget {
  final String exeName;
  final bool isBlocked;
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;

  const ExeTile({
    super.key,
    required this.exeName,
    this.isBlocked = false,
    this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.apps),
      title: Text(exeName),
      trailing: isBlocked
          ? Tooltip(
              message: "Retirer de la liste bloquée",
              child: IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: onDelete,
              ),
            )
          : Tooltip(
              message: "Ajouter à la liste bloquée",
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAdd,
              ),
            ),
    );
  }
}
