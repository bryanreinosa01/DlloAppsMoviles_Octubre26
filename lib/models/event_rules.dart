import 'baggage_event.dart';

const eventTypes = [
  'CHECKED_IN',
  'SECURITY',
  'LOADED',
  'IN_TRANSIT',
  'DELIVERED'
];

BaggageEvent? latestEvent(List<BaggageEvent> events, String baggageId) {
  BaggageEvent? latest;
  for (final event in events) {
    if (event.baggageId == baggageId &&
        (latest == null || event.createdAt.isAfter(latest.createdAt))) {
      latest = event;
    }
  }
  return latest;
}

String? transitionError(List<BaggageEvent> history, BaggageEvent event) {
  final latest = latestEvent(history, event.baggageId);
  // Variante A: comparar con el ultimo evento DEL MISMO equipaje.
  if (latest != null && latest.type == event.type) {
    return 'No se permiten dos eventos consecutivos del mismo tipo para este equipaje.';
  }
  final nextIndex = latest == null ? 0 : eventTypes.indexOf(latest.type) + 1;
  if (latest != null && !eventTypes.contains(latest.type)) {
    return 'El historial contiene un estado desconocido.';
  }
  if (nextIndex >= eventTypes.length) {
    return 'No hay otro evento en la secuencia base.';
  }
  if (event.type != eventTypes[nextIndex]) {
    return 'Transicion invalida. El siguiente evento debe ser ${eventTypes[nextIndex]}.';
  }
  if (latest != null && !event.createdAt.isAfter(latest.createdAt)) {
    return 'El nuevo evento debe tener una fecha posterior al ultimo registro.';
  }
  return null;
}
