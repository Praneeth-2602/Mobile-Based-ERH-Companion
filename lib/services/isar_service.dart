import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'isar_service.g.dart';

@collection
class StoredRecord {
  Id id = Isar.autoIncrement; // local auto id

  late String kind; // 'patient' | 'anc_visit' | 'immunization' | 'visit' | 'reminder'
  late String recordId; // domain id (e.g., pat-001)
  late String json; // canonical json string
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

class IsarService {
  static Isar? _isar;

  static Future<Isar> instance() async {
    if (_isar != null) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [StoredRecordSchema],
      directory: dir.path,
      inspector: false,
    );
    return _isar!;
  }

  // Upsert by kind+recordId
  static Future<void> put(String kind, String recordId, String json) async {
    final isar = await instance();
    final existing = await isar.storedRecords
        .filter()
        .kindEqualTo(kind)
        .and()
        .recordIdEqualTo(recordId)
        .findFirst();

    final now = DateTime.now();
    final sr = existing ?? StoredRecord()
      ..kind = kind
      ..recordId = recordId
      ..createdAt = now;
    sr
      ..json = json
      ..updatedAt = now;

    await isar.writeTxn(() async {
      await isar.storedRecords.put(sr);
    });
  }

  static Future<void> delete(String kind, String recordId) async {
    final isar = await instance();
    final existing = await isar.storedRecords
        .filter()
        .kindEqualTo(kind)
        .and()
        .recordIdEqualTo(recordId)
        .findFirst();
    if (existing != null) {
      await isar.writeTxn(() async {
        await isar.storedRecords.delete(existing.id);
      });
    }
  }

  static Future<List<StoredRecord>> getAll(String kind) async {
    final isar = await instance();
    return isar.storedRecords.filter().kindEqualTo(kind).findAll();
  }

  static Future<void> clearKind(String kind) async {
    final isar = await instance();
    final all = await isar.storedRecords.filter().kindEqualTo(kind).findAll();
    await isar.writeTxn(() async {
      for (final rec in all) {
        await isar.storedRecords.delete(rec.id);
      }
    });
  }
}
