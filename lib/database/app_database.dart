import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/baggage_event.dart';
import 'events_table.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [BaggageEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 1;

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    final rows = await (select(baggageEvents)
          ..where((t) => t.baggageId.equals(baggageId)))
        .get();
    return rows
        .map((row) => BaggageEvent(
            id: row.id,
            baggageId: row.baggageId,
            type: row.type,
            createdAt: row.createdAt))
        .toList();
  }

  Future<void> saveEvent(BaggageEvent event) async {
    await into(baggageEvents).insertOnConflictUpdate(
        BaggageEventsCompanion.insert(
            id: event.id,
            baggageId: event.baggageId,
            type: event.type,
            createdAt: event.createdAt));
  }

  Future<void> cacheEvents(List<BaggageEvent> events) async {
    // Cada evento tiene su propio ID: guardar no reemplaza otros eventos.
    for (final event in events) {
      await saveEvent(event);
    }
  }
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
          File(p.join(dir.path, 'baggage_events_baggage_16688.sqlite')));
    });
