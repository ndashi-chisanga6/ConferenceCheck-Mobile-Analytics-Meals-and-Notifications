import 'package:flutter/material.dart';

class ResultBanner extends StatelessWidget {
  const ResultBanner({required this.message, required this.kind, super.key});

  final String message;
  final ResultKind kind;

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      ResultKind.success => Colors.green,
      ResultKind.warning => Colors.orange,
      ResultKind.error => Colors.red,
      ResultKind.info => Theme.of(context).colorScheme.primary,
    };
    final icon = switch (kind) {
      ResultKind.success => Icons.check_circle_outline,
      ResultKind.warning => Icons.warning_amber,
      ResultKind.error => Icons.error_outline,
      ResultKind.info => Icons.info_outline,
    };

    return Card(
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(message),
      ),
    );
  }
}

enum ResultKind { success, warning, error, info }
