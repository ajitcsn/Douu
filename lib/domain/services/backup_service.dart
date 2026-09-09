import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../config/defaults.dart';
import '../../data/db/database.dart';

/// Backup / export (§5.9). Serializes all structural tables to JSON, optionally
/// AES-GCM encrypted with a passphrase. This is the ONLY place data leaves the
/// app — and only by explicit user action.
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  Future<String> exportJson({String? passphrase}) async {
    final data = <String, dynamic>{
      'contacts':
          (await db.select(db.contacts).get()).map((c) => c.toJson()).toList(),
      'groups':
          (await db.select(db.groups).get()).map((g) => g.toJson()).toList(),
      'memberships': (await db.select(db.groupMemberships).get())
          .map((m) => m.toJson())
          .toList(),
      'frequencyOverrides':
          (await db.select(db.contactFrequencyOverrides).get())
              .map((o) => o.toJson())
              .toList(),
      'messageTemplates': (await db.select(db.messageTemplates).get())
          .map((t) => t.toJson())
          .toList(),
      // Side quests are part of the user's local experience. They are kept so
      // a restore does not resurrect unrelated history from this device.
      'sideQuests': (await db.select(db.sideQuests).get())
          .map((q) => q.toJson())
          .toList(),
      'settings': (await db.getSettings()).toJson(),
      'globalStreak': (await db.getGlobalStreak()).toJson(),
      if (DouuDefaults.includeLogsInBackup)
        'nudgeLogs': (await db.select(db.nudgeLogs).get())
            .map((l) => l.toJson())
            .toList(),
    };

    final inner = jsonEncode({
      'douuBackupVersion': DouuDefaults.backupVersion,
      'exportedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      'data': data,
    });

    if (passphrase == null || passphrase.isEmpty) {
      return inner;
    }
    return _encrypt(inner, passphrase);
  }

  Future<void> importJson(String raw, {String? passphrase}) async {
    Map<String, dynamic> doc;
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    if (parsed['encrypted'] == true) {
      if (passphrase == null || passphrase.isEmpty) {
        throw const BackupException(
            'This backup is encrypted. Enter the passphrase.');
      }
      final decrypted = await _decrypt(parsed, passphrase);
      doc = jsonDecode(decrypted) as Map<String, dynamic>;
    } else {
      doc = parsed;
    }

    final version = doc['douuBackupVersion'];
    if (version != 2 && version != DouuDefaults.backupVersion) {
      throw const BackupException('Unsupported backup version.');
    }
    final data = doc['data'] as Map<String, dynamic>;

    // v1 = replace. Wipe then reinsert inside one transaction.
    await db.transaction(() async {
      await db.delete(db.nudgeLogs).go();
      await db.delete(db.questItems).go();
      // Notification throttles belong to the device, not the restored data.
      // Clearing them prevents an old install from suppressing useful nudges.
      await db.delete(db.notificationLedgers).go();
      await db.delete(db.groupMemberships).go();
      await db.delete(db.contactFrequencyOverrides).go();
      await db.delete(db.quests).go();
      await db.delete(db.sideQuests).go();
      await db.delete(db.messageTemplates).go();
      await db.delete(db.groups).go();
      await db.delete(db.contacts).go();

      for (final c in (data['contacts'] as List)) {
        await db.into(db.contacts).insert(
            Contact.fromJson(c as Map<String, dynamic>).toCompanion(false));
      }
      for (final g in (data['groups'] as List)) {
        await db.into(db.groups).insert(
            Group.fromJson(g as Map<String, dynamic>).toCompanion(false));
      }
      for (final m in (data['memberships'] as List)) {
        await db.into(db.groupMemberships).insert(
            GroupMembership.fromJson(m as Map<String, dynamic>)
                .toCompanion(false));
      }
      for (final o in (data['frequencyOverrides'] as List? ?? [])) {
        await db.into(db.contactFrequencyOverrides).insert(
            ContactFrequencyOverride.fromJson(o as Map<String, dynamic>)
                .toCompanion(false));
      }
      for (final t in (data['messageTemplates'] as List? ?? [])) {
        await db.into(db.messageTemplates).insert(
            MessageTemplate.fromJson(t as Map<String, dynamic>)
                .toCompanion(false));
      }
      for (final q in (data['sideQuests'] as List? ?? [])) {
        await db.into(db.sideQuests).insert(
            SideQuest.fromJson(q as Map<String, dynamic>).toCompanion(false));
      }
      if (data['settings'] != null) {
        await db.into(db.settingsTable).insertOnConflictUpdate(
            SettingsTableData.fromJson(
                data['settings'] as Map<String, dynamic>));
      }
      if (data['globalStreak'] != null) {
        await db.into(db.globalStreaks).insertOnConflictUpdate(
            GlobalStreak.fromJson(
                data['globalStreak'] as Map<String, dynamic>));
      }
    });
  }

  // ── AES-GCM with PBKDF2 (§5.9) ─────────────────────────────────────
  Future<String> _encrypt(String plaintext, String passphrase) async {
    final salt = SecretKeyData.random(length: 16).bytes;
    final secretKey = await _deriveKey(passphrase, salt);
    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
    );
    return jsonEncode({
      'douuBackupVersion': DouuDefaults.backupVersion,
      'encrypted': true,
      'kdf': 'pbkdf2',
      'salt': base64Encode(salt),
      'iv': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'ciphertext': base64Encode(secretBox.cipherText),
    });
  }

  Future<String> _decrypt(Map<String, dynamic> doc, String passphrase) async {
    try {
      final salt = base64Decode(doc['salt'] as String);
      final secretKey = await _deriveKey(passphrase, salt);
      final algorithm = AesGcm.with256bits();
      final secretBox = SecretBox(
        base64Decode(doc['ciphertext'] as String),
        nonce: base64Decode(doc['iv'] as String),
        mac: Mac(base64Decode(doc['mac'] as String)),
      );
      final clear = await algorithm.decrypt(secretBox, secretKey: secretKey);
      return utf8.decode(clear);
    } catch (_) {
      throw const BackupException('Wrong passphrase or corrupt file.');
    }
  }

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: Uint8List.fromList(salt),
    );
  }
}

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}
