import 'package:drift/drift.dart';
import 'database_connection/connection.dart';

part 'database.g.dart';

class FlashcardsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get nextReview => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastReview => dateTime().withDefault(currentDateAndTime)();
  IntColumn get priority => integer().withDefault(const Constant(1))();
  RealColumn get stability => real().withDefault(const Constant(1.0))();
  RealColumn get difficulty => real().withDefault(const Constant(5.0))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [FlashcardsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
