import 'baggage_event.dart';

class EventHistory {
  final List<BaggageEvent> events;
  final bool usingLocal;
  final String message;
  const EventHistory(this.events, {this.usingLocal = false, this.message = ''});
}
