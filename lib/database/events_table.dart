import 'package:drift/drift.dart';

@DataClassName('BaggageEventRow')
class BaggageEvents extends Table {
  TextColumn get id => text()();
  TextColumn get baggageId => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}
