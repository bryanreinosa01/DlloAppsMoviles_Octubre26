import 'package:flutter/material.dart';

import '../models/baggage.dart';

class BaggageCard extends StatelessWidget {
  const BaggageCard({
    super.key,
    required this.baggage,
    required this.onTap,
    this.status = 'Sin eventos',
    this.usingLocal = false,
  });

  final Baggage baggage;
  final VoidCallback onTap;
  final String status;
  final bool usingLocal;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.luggage_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baggage.id,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(baggage.passenger),
                    const SizedBox(height: 3),
                    Text(
                      '${baggage.flight}  ·  ${baggage.destination}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _InitialStatusChip(status: status),
                  if (usingLocal) const Text('Datos locales'),
                  const SizedBox(height: 10),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialStatusChip extends StatelessWidget {
  final String status;
  const _InitialStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 6),
          Text(status),
        ],
      ),
    );
  }
}
