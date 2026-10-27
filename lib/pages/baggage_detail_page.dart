import 'package:flutter/material.dart';
import '../models/baggage.dart';
import '../models/baggage_event.dart';
import '../models/event_history.dart';
import '../models/event_rules.dart';
import '../repositories/baggage_event_repository.dart';

class BaggageDetailPage extends StatefulWidget {
  final Baggage baggage;
  final BaggageEventRepository repository;
  const BaggageDetailPage(
      {super.key, required this.baggage, required this.repository});
  @override
  State<BaggageDetailPage> createState() => _BaggageDetailPageState();
}

class _BaggageDetailPageState extends State<BaggageDetailPage> {
  EventHistory? _history;
  bool _loading = true;
  bool _saving = false;
  String _error = '';
  String _selectedType = eventTypes.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final history =
          await widget.repository.getEventsForBaggage(widget.baggage.id);
      if (!mounted) return;
      final latest = latestEvent(history.events, widget.baggage.id);
      final next = latest == null ? 0 : eventTypes.indexOf(latest.type) + 1;
      setState(() {
        _history = history;
        _selectedType =
            next < eventTypes.length ? eventTypes[next] : eventTypes.last;
      });
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = 'No se pudo obtener el historial remoto ni local.');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _register() async {
    final event = BaggageEvent(
        id: widget.repository.newEventId(),
        baggageId: widget.baggage.id,
        type: _selectedType,
        createdAt: DateTime.now());
    final error = transitionError(_history!.events, event);
    if (error != null) {
      _message(error);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.registerEvent(event);
      if (mounted) _message('Evento confirmado y guardado.');
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    }
    if (!mounted) return;
    await _load();
    if (mounted) setState(() => _saving = false);
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final events = _history?.events ?? <BaggageEvent>[];
    final latest = latestEvent(events, widget.baggage.id);
    return Scaffold(
      appBar: AppBar(title: Text(widget.baggage.id), actions: [
        IconButton(
            tooltip: 'Actualizar historial',
            onPressed: _loading || _saving ? null : _load,
            icon: const Icon(Icons.refresh)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _BaggageHeader(
            baggage: widget.baggage,
            status: _loading
                ? 'Cargando...'
                : _error.isNotEmpty
                    ? 'No disponible'
                    : latest?.type ?? 'Sin eventos'),
        const SizedBox(height: 24),
        if (_history != null && _history!.message.isNotEmpty)
          Text(_history!.message),
        Text('Historial de eventos',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        if (_loading)
          const Text('Cargando historial...')
        else if (_error.isNotEmpty)
          Text(_error)
        else if (events.isEmpty)
          const _EmptyHistory()
        else
          for (final event in events)
            ListTile(
                title: Text(event.type),
                subtitle: Text(event.createdAt.toLocal().toString())),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedType),
          initialValue: _selectedType,
          decoration: const InputDecoration(
              labelText: 'Tipo de evento', border: OutlineInputBorder()),
          items: eventTypes
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: _loading || _saving
              ? null
              : (value) => setState(() => _selectedType = value!),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
            onPressed:
                _loading || _saving || _error.isNotEmpty || _history == null
                    ? null
                    : _register,
            icon: const Icon(Icons.add),
            label: Text(_saving ? 'Registrando...' : 'Registrar evento')),
      ]),
    );
  }
}

class _BaggageHeader extends StatelessWidget {
  const _BaggageHeader({required this.baggage, required this.status});
  final String status;

  final Baggage baggage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.luggage,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Chip(label: Text(status)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: _InfoField(
                    label: 'Pasajero',
                    value: baggage.passenger,
                  ),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'Vuelo',
                    value: baggage.flight,
                  ),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'Destino',
                    value: baggage.destination,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Este equipaje aun no tiene eventos.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
