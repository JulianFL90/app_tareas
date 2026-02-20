import 'package:flutter/material.dart';

import '../../domain/task.dart';
import '../../domain/task_update_repository.dart';
import 'task_info_chips.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final TaskUpdateRepository taskUpdateRepository;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.taskUpdateRepository,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = task.priority.color(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                width: 5,
                color: borderColor,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              TaskInfoChips(task: task),

              const SizedBox(height: 10),

              FutureBuilder<int>(
                future: taskUpdateRepository.countByTask(task.id),
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  if (count <= 0) return const SizedBox.shrink();

                  return Text(
                    'Actualizaciones: $count',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}