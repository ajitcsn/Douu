import 'package:drift/drift.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

import '../../data/db/database.dart';
import 'phone_normalizer.dart';

/// Contact import & E.164 normalization (§5.1). Batched so importing thousands
/// of contacts never blocks the UI; reports progress via [onProgress].
class ContactsImporter {
  ContactsImporter(this.db, {PhoneNormalizer? normalizer})
      : normalizer = normalizer ?? PhoneNormalizer();

  final AppDatabase db;
  final PhoneNormalizer normalizer;

  Future<bool> hasPermission() =>
      fc.FlutterContacts.requestPermission(readonly: true);

  /// Lightweight count of contacts on the device (no properties/thumbnails),
  /// used for the "X of Y phone contacts are on Douu" coverage stat.
  Future<int> deviceContactsCount() async {
    final contacts = await fc.FlutterContacts.getContacts();
    return contacts.length;
  }

  /// Imports all device contacts. [onProgress] is called as (done, total).
  Future<int> importAll(
      {void Function(int done, int total)? onProgress}) async {
    final deviceContacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: true,
    );
    final total = deviceContacts.length;
    if (total == 0) return 0;

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    var done = 0;
    const batchSize = 100;

    for (var i = 0; i < total; i += batchSize) {
      final slice = deviceContacts.skip(i).take(batchSize).toList();
      await db.batch((b) {
        for (final c in slice) {
          final rawPhone = c.phones.isNotEmpty ? c.phones.first.number : null;
          final e164 = normalizer.toE164(rawPhone);
          final companion = ContactsCompanion.insert(
            systemContactId: Value(c.id),
            displayName:
                c.displayName.isEmpty ? (rawPhone ?? 'Unknown') : c.displayName,
            phoneE164: Value(e164),
            phoneRaw: Value(rawPhone),
            photoUri: const Value(null),
            isStarredOnImport: Value(c.isStarred),
            createdAt: nowMs,
          );
          b.insert(
            db.contacts,
            companion,
            // Unlike REPLACE, a conflict update preserves the existing ID,
            // memberships, notes, and reach-out history.
            onConflict: DoUpdate((_) => companion),
          );
        }
      });
      done += slice.length;
      onProgress?.call(done, total);
    }
    return done;
  }

  /// Smart pre-sort for any triage list (§5.1):
  /// starred → name+photo → name only → bare number / digits-only name last.
  static int triageRank(Contact c) {
    if (c.isStarredOnImport) return 0;
    final hasName = c.displayName.trim().isNotEmpty &&
        !RegExp(r'^[+\d\s\-()]+$').hasMatch(c.displayName.trim());
    final hasPhoto = c.photoUri != null && c.photoUri!.isNotEmpty;
    if (hasName && hasPhoto) return 1;
    if (hasName) return 2;
    return 3;
  }

  static List<Contact> smartSort(List<Contact> contacts) {
    final list = [...contacts];
    list.sort((a, b) {
      final r = triageRank(a).compareTo(triageRank(b));
      if (r != 0) return r;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return list;
  }
}
