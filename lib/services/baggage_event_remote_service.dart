import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/baggage_event.dart';

class BaggageEventRemoteService {
  final FirebaseFirestore firestore;
  BaggageEventRemoteService(this.firestore);

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    // Source.server permite distinguir el fallo remoto de la cache de Firestore.
    final result = await firestore
        .collection('baggage_events')
        .where('baggageId', isEqualTo: baggageId)
        .get(const GetOptions(source: Source.server));
    return result.docs.map((doc) {
      final data = doc.data();
      final date = data['createdAt'];
      return BaggageEvent(
          id: data['id'] as String,
          baggageId: data['baggageId'] as String,
          type: data['type'] as String,
          createdAt: date is Timestamp
              ? date.toDate()
              : DateTime.parse(date as String));
    }).toList();
  }

  String newEventId() => firestore.collection('baggage_events').doc().id;

  Future<void> saveEvent(BaggageEvent event) async {
    // Un documento por evento; nunca utilizar baggageId como ID de documento.
    await firestore.collection('baggage_events').doc(event.id).set({
      'id': event.id,
      'baggageId': event.baggageId,
      'type': event.type,
      'createdAt': Timestamp.fromDate(event.createdAt),
    });
  }
}
