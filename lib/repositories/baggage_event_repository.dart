import '../database/app_database.dart';
import '../models/baggage_event.dart';
import '../models/event_history.dart';
import '../models/event_rules.dart';
import '../services/baggage_event_remote_service.dart';

class BaggageEventRepository {
  final AppDatabase local;
  final BaggageEventRemoteService remote;
  BaggageEventRepository({required this.local, required this.remote});

  Future<EventHistory> getEventsForBaggage(String baggageId) async {
    List<BaggageEvent> events;
    try {
      events = await remote.getEventsForBaggage(baggageId);
    } catch (_) {
      final cached = await local.getEventsForBaggage(baggageId);
      return EventHistory(cached,
          usingLocal: true,
          message:
              'Sin lectura remota. Mostrando los ultimos datos locales disponibles.');
    }
    try {
      await local.cacheEvents(events);
      return EventHistory(events);
    } catch (_) {
      return EventHistory(events,
          message:
              'Datos remotos recibidos; no se pudo actualizar la cache local.');
    }
  }

  String newEventId() => remote.newEventId();

  Future<void> registerEvent(BaggageEvent event) async {
    // Validar contra el historial remoto actual antes de escribir.
    final history = await remote.getEventsForBaggage(event.baggageId);
    final error = transitionError(history, event);
    if (error != null) throw Exception(error);
    await remote.saveEvent(event);
    try {
      await local.saveEvent(event);
    } catch (_) {
      throw Exception(
          'Evento confirmado en Firestore, pero fallo la cache local. Actualiza el historial.');
    }
  }
}
