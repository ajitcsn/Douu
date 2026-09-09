// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _systemContactIdMeta =
      const VerificationMeta('systemContactId');
  @override
  late final GeneratedColumn<String> systemContactId = GeneratedColumn<String>(
      'system_contact_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneE164Meta =
      const VerificationMeta('phoneE164');
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
      'phone_e164', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneRawMeta =
      const VerificationMeta('phoneRaw');
  @override
  late final GeneratedColumn<String> phoneRaw = GeneratedColumn<String>(
      'phone_raw', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUriMeta =
      const VerificationMeta('photoUri');
  @override
  late final GeneratedColumn<String> photoUri = GeneratedColumn<String>(
      'photo_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isStarredOnImportMeta =
      const VerificationMeta('isStarredOnImport');
  @override
  late final GeneratedColumn<bool> isStarredOnImport = GeneratedColumn<bool>(
      'is_starred_on_import', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_starred_on_import" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastReachedAtMeta =
      const VerificationMeta('lastReachedAt');
  @override
  late final GeneratedColumn<int> lastReachedAt = GeneratedColumn<int>(
      'last_reached_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        systemContactId,
        displayName,
        phoneE164,
        phoneRaw,
        photoUri,
        isStarredOnImport,
        lastReachedAt,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('system_contact_id')) {
      context.handle(
          _systemContactIdMeta,
          systemContactId.isAcceptableOrUnknown(
              data['system_contact_id']!, _systemContactIdMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('phone_e164')) {
      context.handle(_phoneE164Meta,
          phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta));
    }
    if (data.containsKey('phone_raw')) {
      context.handle(_phoneRawMeta,
          phoneRaw.isAcceptableOrUnknown(data['phone_raw']!, _phoneRawMeta));
    }
    if (data.containsKey('photo_uri')) {
      context.handle(_photoUriMeta,
          photoUri.isAcceptableOrUnknown(data['photo_uri']!, _photoUriMeta));
    }
    if (data.containsKey('is_starred_on_import')) {
      context.handle(
          _isStarredOnImportMeta,
          isStarredOnImport.isAcceptableOrUnknown(
              data['is_starred_on_import']!, _isStarredOnImportMeta));
    }
    if (data.containsKey('last_reached_at')) {
      context.handle(
          _lastReachedAtMeta,
          lastReachedAt.isAcceptableOrUnknown(
              data['last_reached_at']!, _lastReachedAtMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      systemContactId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}system_contact_id']),
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      phoneE164: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_e164']),
      phoneRaw: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_raw']),
      photoUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_uri']),
      isStarredOnImport: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_starred_on_import'])!,
      lastReachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_reached_at']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final int id;

  /// Platform contact IDs make repeated local imports an upsert, not a second
  /// copy of every person. SQLite permits multiple null values here for manual
  /// contacts that have no platform record.
  final String? systemContactId;
  final String displayName;
  final String? phoneE164;
  final String? phoneRaw;
  final String? photoUri;
  final bool isStarredOnImport;
  final int? lastReachedAt;
  final String? notes;
  final int createdAt;
  const Contact(
      {required this.id,
      this.systemContactId,
      required this.displayName,
      this.phoneE164,
      this.phoneRaw,
      this.photoUri,
      required this.isStarredOnImport,
      this.lastReachedAt,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || systemContactId != null) {
      map['system_contact_id'] = Variable<String>(systemContactId);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || phoneE164 != null) {
      map['phone_e164'] = Variable<String>(phoneE164);
    }
    if (!nullToAbsent || phoneRaw != null) {
      map['phone_raw'] = Variable<String>(phoneRaw);
    }
    if (!nullToAbsent || photoUri != null) {
      map['photo_uri'] = Variable<String>(photoUri);
    }
    map['is_starred_on_import'] = Variable<bool>(isStarredOnImport);
    if (!nullToAbsent || lastReachedAt != null) {
      map['last_reached_at'] = Variable<int>(lastReachedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      systemContactId: systemContactId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemContactId),
      displayName: Value(displayName),
      phoneE164: phoneE164 == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneE164),
      phoneRaw: phoneRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneRaw),
      photoUri: photoUri == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUri),
      isStarredOnImport: Value(isStarredOnImport),
      lastReachedAt: lastReachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReachedAt),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      systemContactId: serializer.fromJson<String?>(json['systemContactId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      phoneE164: serializer.fromJson<String?>(json['phoneE164']),
      phoneRaw: serializer.fromJson<String?>(json['phoneRaw']),
      photoUri: serializer.fromJson<String?>(json['photoUri']),
      isStarredOnImport: serializer.fromJson<bool>(json['isStarredOnImport']),
      lastReachedAt: serializer.fromJson<int?>(json['lastReachedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'systemContactId': serializer.toJson<String?>(systemContactId),
      'displayName': serializer.toJson<String>(displayName),
      'phoneE164': serializer.toJson<String?>(phoneE164),
      'phoneRaw': serializer.toJson<String?>(phoneRaw),
      'photoUri': serializer.toJson<String?>(photoUri),
      'isStarredOnImport': serializer.toJson<bool>(isStarredOnImport),
      'lastReachedAt': serializer.toJson<int?>(lastReachedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Contact copyWith(
          {int? id,
          Value<String?> systemContactId = const Value.absent(),
          String? displayName,
          Value<String?> phoneE164 = const Value.absent(),
          Value<String?> phoneRaw = const Value.absent(),
          Value<String?> photoUri = const Value.absent(),
          bool? isStarredOnImport,
          Value<int?> lastReachedAt = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? createdAt}) =>
      Contact(
        id: id ?? this.id,
        systemContactId: systemContactId.present
            ? systemContactId.value
            : this.systemContactId,
        displayName: displayName ?? this.displayName,
        phoneE164: phoneE164.present ? phoneE164.value : this.phoneE164,
        phoneRaw: phoneRaw.present ? phoneRaw.value : this.phoneRaw,
        photoUri: photoUri.present ? photoUri.value : this.photoUri,
        isStarredOnImport: isStarredOnImport ?? this.isStarredOnImport,
        lastReachedAt:
            lastReachedAt.present ? lastReachedAt.value : this.lastReachedAt,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      systemContactId: data.systemContactId.present
          ? data.systemContactId.value
          : this.systemContactId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      phoneRaw: data.phoneRaw.present ? data.phoneRaw.value : this.phoneRaw,
      photoUri: data.photoUri.present ? data.photoUri.value : this.photoUri,
      isStarredOnImport: data.isStarredOnImport.present
          ? data.isStarredOnImport.value
          : this.isStarredOnImport,
      lastReachedAt: data.lastReachedAt.present
          ? data.lastReachedAt.value
          : this.lastReachedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('systemContactId: $systemContactId, ')
          ..write('displayName: $displayName, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('phoneRaw: $phoneRaw, ')
          ..write('photoUri: $photoUri, ')
          ..write('isStarredOnImport: $isStarredOnImport, ')
          ..write('lastReachedAt: $lastReachedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, systemContactId, displayName, phoneE164,
      phoneRaw, photoUri, isStarredOnImport, lastReachedAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.systemContactId == this.systemContactId &&
          other.displayName == this.displayName &&
          other.phoneE164 == this.phoneE164 &&
          other.phoneRaw == this.phoneRaw &&
          other.photoUri == this.photoUri &&
          other.isStarredOnImport == this.isStarredOnImport &&
          other.lastReachedAt == this.lastReachedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String?> systemContactId;
  final Value<String> displayName;
  final Value<String?> phoneE164;
  final Value<String?> phoneRaw;
  final Value<String?> photoUri;
  final Value<bool> isStarredOnImport;
  final Value<int?> lastReachedAt;
  final Value<String?> notes;
  final Value<int> createdAt;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.systemContactId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.phoneRaw = const Value.absent(),
    this.photoUri = const Value.absent(),
    this.isStarredOnImport = const Value.absent(),
    this.lastReachedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    this.systemContactId = const Value.absent(),
    required String displayName,
    this.phoneE164 = const Value.absent(),
    this.phoneRaw = const Value.absent(),
    this.photoUri = const Value.absent(),
    this.isStarredOnImport = const Value.absent(),
    this.lastReachedAt = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
  })  : displayName = Value(displayName),
        createdAt = Value(createdAt);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? systemContactId,
    Expression<String>? displayName,
    Expression<String>? phoneE164,
    Expression<String>? phoneRaw,
    Expression<String>? photoUri,
    Expression<bool>? isStarredOnImport,
    Expression<int>? lastReachedAt,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (systemContactId != null) 'system_contact_id': systemContactId,
      if (displayName != null) 'display_name': displayName,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (phoneRaw != null) 'phone_raw': phoneRaw,
      if (photoUri != null) 'photo_uri': photoUri,
      if (isStarredOnImport != null) 'is_starred_on_import': isStarredOnImport,
      if (lastReachedAt != null) 'last_reached_at': lastReachedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ContactsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? systemContactId,
      Value<String>? displayName,
      Value<String?>? phoneE164,
      Value<String?>? phoneRaw,
      Value<String?>? photoUri,
      Value<bool>? isStarredOnImport,
      Value<int?>? lastReachedAt,
      Value<String?>? notes,
      Value<int>? createdAt}) {
    return ContactsCompanion(
      id: id ?? this.id,
      systemContactId: systemContactId ?? this.systemContactId,
      displayName: displayName ?? this.displayName,
      phoneE164: phoneE164 ?? this.phoneE164,
      phoneRaw: phoneRaw ?? this.phoneRaw,
      photoUri: photoUri ?? this.photoUri,
      isStarredOnImport: isStarredOnImport ?? this.isStarredOnImport,
      lastReachedAt: lastReachedAt ?? this.lastReachedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (systemContactId.present) {
      map['system_contact_id'] = Variable<String>(systemContactId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (phoneRaw.present) {
      map['phone_raw'] = Variable<String>(phoneRaw.value);
    }
    if (photoUri.present) {
      map['photo_uri'] = Variable<String>(photoUri.value);
    }
    if (isStarredOnImport.present) {
      map['is_starred_on_import'] = Variable<bool>(isStarredOnImport.value);
    }
    if (lastReachedAt.present) {
      map['last_reached_at'] = Variable<int>(lastReachedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('systemContactId: $systemContactId, ')
          ..write('displayName: $displayName, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('phoneRaw: $phoneRaw, ')
          ..write('photoUri: $photoUri, ')
          ..write('isStarredOnImport: $isStarredOnImport, ')
          ..write('lastReachedAt: $lastReachedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyDaysMeta =
      const VerificationMeta('frequencyDays');
  @override
  late final GeneratedColumn<int> frequencyDays = GeneratedColumn<int>(
      'frequency_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _streakCountMeta =
      const VerificationMeta('streakCount');
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
      'streak_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _streakLastDayMeta =
      const VerificationMeta('streakLastDay');
  @override
  late final GeneratedColumn<String> streakLastDay = GeneratedColumn<String>(
      'streak_last_day', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ragHealthMeta =
      const VerificationMeta('ragHealth');
  @override
  late final GeneratedColumn<String> ragHealth = GeneratedColumn<String>(
      'rag_health', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('grey'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        emoji,
        frequencyDays,
        streakCount,
        streakLastDay,
        ragHealth,
        sortOrder,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    }
    if (data.containsKey('frequency_days')) {
      context.handle(
          _frequencyDaysMeta,
          frequencyDays.isAcceptableOrUnknown(
              data['frequency_days']!, _frequencyDaysMeta));
    } else if (isInserting) {
      context.missing(_frequencyDaysMeta);
    }
    if (data.containsKey('streak_count')) {
      context.handle(
          _streakCountMeta,
          streakCount.isAcceptableOrUnknown(
              data['streak_count']!, _streakCountMeta));
    }
    if (data.containsKey('streak_last_day')) {
      context.handle(
          _streakLastDayMeta,
          streakLastDay.isAcceptableOrUnknown(
              data['streak_last_day']!, _streakLastDayMeta));
    }
    if (data.containsKey('rag_health')) {
      context.handle(_ragHealthMeta,
          ragHealth.isAcceptableOrUnknown(data['rag_health']!, _ragHealthMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji']),
      frequencyDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency_days'])!,
      streakCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak_count'])!,
      streakLastDay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}streak_last_day']),
      ragHealth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rag_health'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final int id;
  final String name;
  final String? emoji;
  final int frequencyDays;
  final int streakCount;
  final String? streakLastDay;
  final String ragHealth;
  final int sortOrder;
  final int createdAt;
  const Group(
      {required this.id,
      required this.name,
      this.emoji,
      required this.frequencyDays,
      required this.streakCount,
      this.streakLastDay,
      required this.ragHealth,
      required this.sortOrder,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['frequency_days'] = Variable<int>(frequencyDays);
    map['streak_count'] = Variable<int>(streakCount);
    if (!nullToAbsent || streakLastDay != null) {
      map['streak_last_day'] = Variable<String>(streakLastDay);
    }
    map['rag_health'] = Variable<String>(ragHealth);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      emoji:
          emoji == null && nullToAbsent ? const Value.absent() : Value(emoji),
      frequencyDays: Value(frequencyDays),
      streakCount: Value(streakCount),
      streakLastDay: streakLastDay == null && nullToAbsent
          ? const Value.absent()
          : Value(streakLastDay),
      ragHealth: Value(ragHealth),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      frequencyDays: serializer.fromJson<int>(json['frequencyDays']),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      streakLastDay: serializer.fromJson<String?>(json['streakLastDay']),
      ragHealth: serializer.fromJson<String>(json['ragHealth']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String?>(emoji),
      'frequencyDays': serializer.toJson<int>(frequencyDays),
      'streakCount': serializer.toJson<int>(streakCount),
      'streakLastDay': serializer.toJson<String?>(streakLastDay),
      'ragHealth': serializer.toJson<String>(ragHealth),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Group copyWith(
          {int? id,
          String? name,
          Value<String?> emoji = const Value.absent(),
          int? frequencyDays,
          int? streakCount,
          Value<String?> streakLastDay = const Value.absent(),
          String? ragHealth,
          int? sortOrder,
          int? createdAt}) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji.present ? emoji.value : this.emoji,
        frequencyDays: frequencyDays ?? this.frequencyDays,
        streakCount: streakCount ?? this.streakCount,
        streakLastDay:
            streakLastDay.present ? streakLastDay.value : this.streakLastDay,
        ragHealth: ragHealth ?? this.ragHealth,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      frequencyDays: data.frequencyDays.present
          ? data.frequencyDays.value
          : this.frequencyDays,
      streakCount:
          data.streakCount.present ? data.streakCount.value : this.streakCount,
      streakLastDay: data.streakLastDay.present
          ? data.streakLastDay.value
          : this.streakLastDay,
      ragHealth: data.ragHealth.present ? data.ragHealth.value : this.ragHealth,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('frequencyDays: $frequencyDays, ')
          ..write('streakCount: $streakCount, ')
          ..write('streakLastDay: $streakLastDay, ')
          ..write('ragHealth: $ragHealth, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, frequencyDays, streakCount,
      streakLastDay, ragHealth, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.frequencyDays == this.frequencyDays &&
          other.streakCount == this.streakCount &&
          other.streakLastDay == this.streakLastDay &&
          other.ragHealth == this.ragHealth &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> emoji;
  final Value<int> frequencyDays;
  final Value<int> streakCount;
  final Value<String?> streakLastDay;
  final Value<String> ragHealth;
  final Value<int> sortOrder;
  final Value<int> createdAt;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.frequencyDays = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.streakLastDay = const Value.absent(),
    this.ragHealth = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    required int frequencyDays,
    this.streakCount = const Value.absent(),
    this.streakLastDay = const Value.absent(),
    this.ragHealth = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int createdAt,
  })  : name = Value(name),
        frequencyDays = Value(frequencyDays),
        createdAt = Value(createdAt);
  static Insertable<Group> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? frequencyDays,
    Expression<int>? streakCount,
    Expression<String>? streakLastDay,
    Expression<String>? ragHealth,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (frequencyDays != null) 'frequency_days': frequencyDays,
      if (streakCount != null) 'streak_count': streakCount,
      if (streakLastDay != null) 'streak_last_day': streakLastDay,
      if (ragHealth != null) 'rag_health': ragHealth,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GroupsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? emoji,
      Value<int>? frequencyDays,
      Value<int>? streakCount,
      Value<String?>? streakLastDay,
      Value<String>? ragHealth,
      Value<int>? sortOrder,
      Value<int>? createdAt}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      streakCount: streakCount ?? this.streakCount,
      streakLastDay: streakLastDay ?? this.streakLastDay,
      ragHealth: ragHealth ?? this.ragHealth,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (frequencyDays.present) {
      map['frequency_days'] = Variable<int>(frequencyDays.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (streakLastDay.present) {
      map['streak_last_day'] = Variable<String>(streakLastDay.value);
    }
    if (ragHealth.present) {
      map['rag_health'] = Variable<String>(ragHealth.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('frequencyDays: $frequencyDays, ')
          ..write('streakCount: $streakCount, ')
          ..write('streakLastDay: $streakLastDay, ')
          ..write('ragHealth: $ragHealth, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GroupMembershipsTable extends GroupMemberships
    with TableInfo<$GroupMembershipsTable, GroupMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES contacts (id) ON DELETE CASCADE'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [id, contactId, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_memberships';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMembership> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {contactId, groupId},
      ];
  @override
  GroupMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMembership(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
    );
  }

  @override
  $GroupMembershipsTable createAlias(String alias) {
    return $GroupMembershipsTable(attachedDatabase, alias);
  }
}

class GroupMembership extends DataClass implements Insertable<GroupMembership> {
  final int id;
  final int contactId;
  final int groupId;
  const GroupMembership(
      {required this.id, required this.contactId, required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    map['group_id'] = Variable<int>(groupId);
    return map;
  }

  GroupMembershipsCompanion toCompanion(bool nullToAbsent) {
    return GroupMembershipsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      groupId: Value(groupId),
    );
  }

  factory GroupMembership.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMembership(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      groupId: serializer.fromJson<int>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'groupId': serializer.toJson<int>(groupId),
    };
  }

  GroupMembership copyWith({int? id, int? contactId, int? groupId}) =>
      GroupMembership(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        groupId: groupId ?? this.groupId,
      );
  GroupMembership copyWithCompanion(GroupMembershipsCompanion data) {
    return GroupMembership(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembership(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contactId, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMembership &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.groupId == this.groupId);
}

class GroupMembershipsCompanion extends UpdateCompanion<GroupMembership> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<int> groupId;
  const GroupMembershipsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.groupId = const Value.absent(),
  });
  GroupMembershipsCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    required int groupId,
  })  : contactId = Value(contactId),
        groupId = Value(groupId);
  static Insertable<GroupMembership> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<int>? groupId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (groupId != null) 'group_id': groupId,
    });
  }

  GroupMembershipsCompanion copyWith(
      {Value<int>? id, Value<int>? contactId, Value<int>? groupId}) {
    return GroupMembershipsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }
}

class $ContactFrequencyOverridesTable extends ContactFrequencyOverrides
    with TableInfo<$ContactFrequencyOverridesTable, ContactFrequencyOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactFrequencyOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES contacts (id) ON DELETE CASCADE'));
  static const VerificationMeta _frequencyDaysMeta =
      const VerificationMeta('frequencyDays');
  @override
  late final GeneratedColumn<int> frequencyDays = GeneratedColumn<int>(
      'frequency_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [contactId, frequencyDays];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_frequency_overrides';
  @override
  VerificationContext validateIntegrity(
      Insertable<ContactFrequencyOverride> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    }
    if (data.containsKey('frequency_days')) {
      context.handle(
          _frequencyDaysMeta,
          frequencyDays.isAcceptableOrUnknown(
              data['frequency_days']!, _frequencyDaysMeta));
    } else if (isInserting) {
      context.missing(_frequencyDaysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contactId};
  @override
  ContactFrequencyOverride map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactFrequencyOverride(
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
      frequencyDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency_days'])!,
    );
  }

  @override
  $ContactFrequencyOverridesTable createAlias(String alias) {
    return $ContactFrequencyOverridesTable(attachedDatabase, alias);
  }
}

class ContactFrequencyOverride extends DataClass
    implements Insertable<ContactFrequencyOverride> {
  final int contactId;
  final int frequencyDays;
  const ContactFrequencyOverride(
      {required this.contactId, required this.frequencyDays});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['contact_id'] = Variable<int>(contactId);
    map['frequency_days'] = Variable<int>(frequencyDays);
    return map;
  }

  ContactFrequencyOverridesCompanion toCompanion(bool nullToAbsent) {
    return ContactFrequencyOverridesCompanion(
      contactId: Value(contactId),
      frequencyDays: Value(frequencyDays),
    );
  }

  factory ContactFrequencyOverride.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactFrequencyOverride(
      contactId: serializer.fromJson<int>(json['contactId']),
      frequencyDays: serializer.fromJson<int>(json['frequencyDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contactId': serializer.toJson<int>(contactId),
      'frequencyDays': serializer.toJson<int>(frequencyDays),
    };
  }

  ContactFrequencyOverride copyWith({int? contactId, int? frequencyDays}) =>
      ContactFrequencyOverride(
        contactId: contactId ?? this.contactId,
        frequencyDays: frequencyDays ?? this.frequencyDays,
      );
  ContactFrequencyOverride copyWithCompanion(
      ContactFrequencyOverridesCompanion data) {
    return ContactFrequencyOverride(
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      frequencyDays: data.frequencyDays.present
          ? data.frequencyDays.value
          : this.frequencyDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactFrequencyOverride(')
          ..write('contactId: $contactId, ')
          ..write('frequencyDays: $frequencyDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(contactId, frequencyDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactFrequencyOverride &&
          other.contactId == this.contactId &&
          other.frequencyDays == this.frequencyDays);
}

class ContactFrequencyOverridesCompanion
    extends UpdateCompanion<ContactFrequencyOverride> {
  final Value<int> contactId;
  final Value<int> frequencyDays;
  const ContactFrequencyOverridesCompanion({
    this.contactId = const Value.absent(),
    this.frequencyDays = const Value.absent(),
  });
  ContactFrequencyOverridesCompanion.insert({
    this.contactId = const Value.absent(),
    required int frequencyDays,
  }) : frequencyDays = Value(frequencyDays);
  static Insertable<ContactFrequencyOverride> custom({
    Expression<int>? contactId,
    Expression<int>? frequencyDays,
  }) {
    return RawValuesInsertable({
      if (contactId != null) 'contact_id': contactId,
      if (frequencyDays != null) 'frequency_days': frequencyDays,
    });
  }

  ContactFrequencyOverridesCompanion copyWith(
      {Value<int>? contactId, Value<int>? frequencyDays}) {
    return ContactFrequencyOverridesCompanion(
      contactId: contactId ?? this.contactId,
      frequencyDays: frequencyDays ?? this.frequencyDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (frequencyDays.present) {
      map['frequency_days'] = Variable<int>(frequencyDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactFrequencyOverridesCompanion(')
          ..write('contactId: $contactId, ')
          ..write('frequencyDays: $frequencyDays')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, Quest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<int> periodStart = GeneratedColumn<int>(
      'period_start', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<int> periodEnd = GeneratedColumn<int>(
      'period_end', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poolContactIdsMeta =
      const VerificationMeta('poolContactIds');
  @override
  late final GeneratedColumn<String> poolContactIds = GeneratedColumn<String>(
      'pool_contact_ids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kThresholdMeta =
      const VerificationMeta('kThreshold');
  @override
  late final GeneratedColumn<int> kThreshold = GeneratedColumn<int>(
      'k_threshold', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reachedCountMeta =
      const VerificationMeta('reachedCount');
  @override
  late final GeneratedColumn<int> reachedCount = GeneratedColumn<int>(
      'reached_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        periodStart,
        periodEnd,
        type,
        poolContactIds,
        kThreshold,
        reachedCount,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(Insertable<Quest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('pool_contact_ids')) {
      context.handle(
          _poolContactIdsMeta,
          poolContactIds.isAcceptableOrUnknown(
              data['pool_contact_ids']!, _poolContactIdsMeta));
    } else if (isInserting) {
      context.missing(_poolContactIdsMeta);
    }
    if (data.containsKey('k_threshold')) {
      context.handle(
          _kThresholdMeta,
          kThreshold.isAcceptableOrUnknown(
              data['k_threshold']!, _kThresholdMeta));
    } else if (isInserting) {
      context.missing(_kThresholdMeta);
    }
    if (data.containsKey('reached_count')) {
      context.handle(
          _reachedCountMeta,
          reachedCount.isAcceptableOrUnknown(
              data['reached_count']!, _reachedCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}period_end'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      poolContactIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pool_contact_ids'])!,
      kThreshold: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}k_threshold'])!,
      reachedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reached_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }
}

class Quest extends DataClass implements Insertable<Quest> {
  final int id;
  final int periodStart;
  final int periodEnd;
  final String type;
  final String poolContactIds;
  final int kThreshold;
  final int reachedCount;
  final String status;
  final int createdAt;
  const Quest(
      {required this.id,
      required this.periodStart,
      required this.periodEnd,
      required this.type,
      required this.poolContactIds,
      required this.kThreshold,
      required this.reachedCount,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_start'] = Variable<int>(periodStart);
    map['period_end'] = Variable<int>(periodEnd);
    map['type'] = Variable<String>(type);
    map['pool_contact_ids'] = Variable<String>(poolContactIds);
    map['k_threshold'] = Variable<int>(kThreshold);
    map['reached_count'] = Variable<int>(reachedCount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      type: Value(type),
      poolContactIds: Value(poolContactIds),
      kThreshold: Value(kThreshold),
      reachedCount: Value(reachedCount),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Quest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quest(
      id: serializer.fromJson<int>(json['id']),
      periodStart: serializer.fromJson<int>(json['periodStart']),
      periodEnd: serializer.fromJson<int>(json['periodEnd']),
      type: serializer.fromJson<String>(json['type']),
      poolContactIds: serializer.fromJson<String>(json['poolContactIds']),
      kThreshold: serializer.fromJson<int>(json['kThreshold']),
      reachedCount: serializer.fromJson<int>(json['reachedCount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodStart': serializer.toJson<int>(periodStart),
      'periodEnd': serializer.toJson<int>(periodEnd),
      'type': serializer.toJson<String>(type),
      'poolContactIds': serializer.toJson<String>(poolContactIds),
      'kThreshold': serializer.toJson<int>(kThreshold),
      'reachedCount': serializer.toJson<int>(reachedCount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Quest copyWith(
          {int? id,
          int? periodStart,
          int? periodEnd,
          String? type,
          String? poolContactIds,
          int? kThreshold,
          int? reachedCount,
          String? status,
          int? createdAt}) =>
      Quest(
        id: id ?? this.id,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
        type: type ?? this.type,
        poolContactIds: poolContactIds ?? this.poolContactIds,
        kThreshold: kThreshold ?? this.kThreshold,
        reachedCount: reachedCount ?? this.reachedCount,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  Quest copyWithCompanion(QuestsCompanion data) {
    return Quest(
      id: data.id.present ? data.id.value : this.id,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      type: data.type.present ? data.type.value : this.type,
      poolContactIds: data.poolContactIds.present
          ? data.poolContactIds.value
          : this.poolContactIds,
      kThreshold:
          data.kThreshold.present ? data.kThreshold.value : this.kThreshold,
      reachedCount: data.reachedCount.present
          ? data.reachedCount.value
          : this.reachedCount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quest(')
          ..write('id: $id, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('type: $type, ')
          ..write('poolContactIds: $poolContactIds, ')
          ..write('kThreshold: $kThreshold, ')
          ..write('reachedCount: $reachedCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, periodStart, periodEnd, type,
      poolContactIds, kThreshold, reachedCount, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quest &&
          other.id == this.id &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.type == this.type &&
          other.poolContactIds == this.poolContactIds &&
          other.kThreshold == this.kThreshold &&
          other.reachedCount == this.reachedCount &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class QuestsCompanion extends UpdateCompanion<Quest> {
  final Value<int> id;
  final Value<int> periodStart;
  final Value<int> periodEnd;
  final Value<String> type;
  final Value<String> poolContactIds;
  final Value<int> kThreshold;
  final Value<int> reachedCount;
  final Value<String> status;
  final Value<int> createdAt;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.type = const Value.absent(),
    this.poolContactIds = const Value.absent(),
    this.kThreshold = const Value.absent(),
    this.reachedCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuestsCompanion.insert({
    this.id = const Value.absent(),
    required int periodStart,
    required int periodEnd,
    required String type,
    required String poolContactIds,
    required int kThreshold,
    this.reachedCount = const Value.absent(),
    required String status,
    required int createdAt,
  })  : periodStart = Value(periodStart),
        periodEnd = Value(periodEnd),
        type = Value(type),
        poolContactIds = Value(poolContactIds),
        kThreshold = Value(kThreshold),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<Quest> custom({
    Expression<int>? id,
    Expression<int>? periodStart,
    Expression<int>? periodEnd,
    Expression<String>? type,
    Expression<String>? poolContactIds,
    Expression<int>? kThreshold,
    Expression<int>? reachedCount,
    Expression<String>? status,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (type != null) 'type': type,
      if (poolContactIds != null) 'pool_contact_ids': poolContactIds,
      if (kThreshold != null) 'k_threshold': kThreshold,
      if (reachedCount != null) 'reached_count': reachedCount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuestsCompanion copyWith(
      {Value<int>? id,
      Value<int>? periodStart,
      Value<int>? periodEnd,
      Value<String>? type,
      Value<String>? poolContactIds,
      Value<int>? kThreshold,
      Value<int>? reachedCount,
      Value<String>? status,
      Value<int>? createdAt}) {
    return QuestsCompanion(
      id: id ?? this.id,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      type: type ?? this.type,
      poolContactIds: poolContactIds ?? this.poolContactIds,
      kThreshold: kThreshold ?? this.kThreshold,
      reachedCount: reachedCount ?? this.reachedCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<int>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<int>(periodEnd.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (poolContactIds.present) {
      map['pool_contact_ids'] = Variable<String>(poolContactIds.value);
    }
    if (kThreshold.present) {
      map['k_threshold'] = Variable<int>(kThreshold.value);
    }
    if (reachedCount.present) {
      map['reached_count'] = Variable<int>(reachedCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('type: $type, ')
          ..write('poolContactIds: $poolContactIds, ')
          ..write('kThreshold: $kThreshold, ')
          ..write('reachedCount: $reachedCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuestItemsTable extends QuestItems
    with TableInfo<$QuestItemsTable, QuestItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _questIdMeta =
      const VerificationMeta('questId');
  @override
  late final GeneratedColumn<int> questId = GeneratedColumn<int>(
      'quest_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES quests (id) ON DELETE CASCADE'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES contacts (id) ON DELETE CASCADE'));
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
      'rank', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _actedAtMeta =
      const VerificationMeta('actedAt');
  @override
  late final GeneratedColumn<int> actedAt = GeneratedColumn<int>(
      'acted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, questId, contactId, rank, state, actedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quest_items';
  @override
  VerificationContext validateIntegrity(Insertable<QuestItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quest_id')) {
      context.handle(_questIdMeta,
          questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta));
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(
          _rankMeta, rank.isAcceptableOrUnknown(data['rank']!, _rankMeta));
    } else if (isInserting) {
      context.missing(_rankMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('acted_at')) {
      context.handle(_actedAtMeta,
          actedAt.isAcceptableOrUnknown(data['acted_at']!, _actedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {questId, contactId},
      ];
  @override
  QuestItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      questId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quest_id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
      rank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rank'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      actedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}acted_at']),
    );
  }

  @override
  $QuestItemsTable createAlias(String alias) {
    return $QuestItemsTable(attachedDatabase, alias);
  }
}

class QuestItem extends DataClass implements Insertable<QuestItem> {
  final int id;
  final int questId;
  final int contactId;
  final int rank;
  final String state;
  final int? actedAt;
  const QuestItem(
      {required this.id,
      required this.questId,
      required this.contactId,
      required this.rank,
      required this.state,
      this.actedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quest_id'] = Variable<int>(questId);
    map['contact_id'] = Variable<int>(contactId);
    map['rank'] = Variable<int>(rank);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || actedAt != null) {
      map['acted_at'] = Variable<int>(actedAt);
    }
    return map;
  }

  QuestItemsCompanion toCompanion(bool nullToAbsent) {
    return QuestItemsCompanion(
      id: Value(id),
      questId: Value(questId),
      contactId: Value(contactId),
      rank: Value(rank),
      state: Value(state),
      actedAt: actedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actedAt),
    );
  }

  factory QuestItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestItem(
      id: serializer.fromJson<int>(json['id']),
      questId: serializer.fromJson<int>(json['questId']),
      contactId: serializer.fromJson<int>(json['contactId']),
      rank: serializer.fromJson<int>(json['rank']),
      state: serializer.fromJson<String>(json['state']),
      actedAt: serializer.fromJson<int?>(json['actedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questId': serializer.toJson<int>(questId),
      'contactId': serializer.toJson<int>(contactId),
      'rank': serializer.toJson<int>(rank),
      'state': serializer.toJson<String>(state),
      'actedAt': serializer.toJson<int?>(actedAt),
    };
  }

  QuestItem copyWith(
          {int? id,
          int? questId,
          int? contactId,
          int? rank,
          String? state,
          Value<int?> actedAt = const Value.absent()}) =>
      QuestItem(
        id: id ?? this.id,
        questId: questId ?? this.questId,
        contactId: contactId ?? this.contactId,
        rank: rank ?? this.rank,
        state: state ?? this.state,
        actedAt: actedAt.present ? actedAt.value : this.actedAt,
      );
  QuestItem copyWithCompanion(QuestItemsCompanion data) {
    return QuestItem(
      id: data.id.present ? data.id.value : this.id,
      questId: data.questId.present ? data.questId.value : this.questId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      rank: data.rank.present ? data.rank.value : this.rank,
      state: data.state.present ? data.state.value : this.state,
      actedAt: data.actedAt.present ? data.actedAt.value : this.actedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestItem(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('contactId: $contactId, ')
          ..write('rank: $rank, ')
          ..write('state: $state, ')
          ..write('actedAt: $actedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questId, contactId, rank, state, actedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestItem &&
          other.id == this.id &&
          other.questId == this.questId &&
          other.contactId == this.contactId &&
          other.rank == this.rank &&
          other.state == this.state &&
          other.actedAt == this.actedAt);
}

class QuestItemsCompanion extends UpdateCompanion<QuestItem> {
  final Value<int> id;
  final Value<int> questId;
  final Value<int> contactId;
  final Value<int> rank;
  final Value<String> state;
  final Value<int?> actedAt;
  const QuestItemsCompanion({
    this.id = const Value.absent(),
    this.questId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.rank = const Value.absent(),
    this.state = const Value.absent(),
    this.actedAt = const Value.absent(),
  });
  QuestItemsCompanion.insert({
    this.id = const Value.absent(),
    required int questId,
    required int contactId,
    required int rank,
    this.state = const Value.absent(),
    this.actedAt = const Value.absent(),
  })  : questId = Value(questId),
        contactId = Value(contactId),
        rank = Value(rank);
  static Insertable<QuestItem> custom({
    Expression<int>? id,
    Expression<int>? questId,
    Expression<int>? contactId,
    Expression<int>? rank,
    Expression<String>? state,
    Expression<int>? actedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questId != null) 'quest_id': questId,
      if (contactId != null) 'contact_id': contactId,
      if (rank != null) 'rank': rank,
      if (state != null) 'state': state,
      if (actedAt != null) 'acted_at': actedAt,
    });
  }

  QuestItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? questId,
      Value<int>? contactId,
      Value<int>? rank,
      Value<String>? state,
      Value<int?>? actedAt}) {
    return QuestItemsCompanion(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      contactId: contactId ?? this.contactId,
      rank: rank ?? this.rank,
      state: state ?? this.state,
      actedAt: actedAt ?? this.actedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<int>(questId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (actedAt.present) {
      map['acted_at'] = Variable<int>(actedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestItemsCompanion(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('contactId: $contactId, ')
          ..write('rank: $rank, ')
          ..write('state: $state, ')
          ..write('actedAt: $actedAt')
          ..write(')'))
        .toString();
  }
}

class $NudgeLogsTable extends NudgeLogs
    with TableInfo<$NudgeLogsTable, NudgeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NudgeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES contacts (id) ON DELETE CASCADE'));
  static const VerificationMeta _questIdMeta =
      const VerificationMeta('questId');
  @override
  late final GeneratedColumn<int> questId = GeneratedColumn<int>(
      'quest_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES quests (id) ON DELETE SET NULL'));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
      'due_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionAtMeta =
      const VerificationMeta('actionAt');
  @override
  late final GeneratedColumn<int> actionAt = GeneratedColumn<int>(
      'action_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contactId, questId, dueDate, action, actionAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nudge_logs';
  @override
  VerificationContext validateIntegrity(Insertable<NudgeLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(_questIdMeta,
          questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('action_at')) {
      context.handle(_actionAtMeta,
          actionAt.isAcceptableOrUnknown(data['action_at']!, _actionAtMeta));
    } else if (isInserting) {
      context.missing(_actionAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NudgeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NudgeLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id'])!,
      questId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quest_id']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_date'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      actionAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}action_at'])!,
    );
  }

  @override
  $NudgeLogsTable createAlias(String alias) {
    return $NudgeLogsTable(attachedDatabase, alias);
  }
}

class NudgeLog extends DataClass implements Insertable<NudgeLog> {
  final int id;
  final int contactId;
  final int? questId;
  final int dueDate;
  final String action;
  final int actionAt;
  const NudgeLog(
      {required this.id,
      required this.contactId,
      this.questId,
      required this.dueDate,
      required this.action,
      required this.actionAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    if (!nullToAbsent || questId != null) {
      map['quest_id'] = Variable<int>(questId);
    }
    map['due_date'] = Variable<int>(dueDate);
    map['action'] = Variable<String>(action);
    map['action_at'] = Variable<int>(actionAt);
    return map;
  }

  NudgeLogsCompanion toCompanion(bool nullToAbsent) {
    return NudgeLogsCompanion(
      id: Value(id),
      contactId: Value(contactId),
      questId: questId == null && nullToAbsent
          ? const Value.absent()
          : Value(questId),
      dueDate: Value(dueDate),
      action: Value(action),
      actionAt: Value(actionAt),
    );
  }

  factory NudgeLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NudgeLog(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      questId: serializer.fromJson<int?>(json['questId']),
      dueDate: serializer.fromJson<int>(json['dueDate']),
      action: serializer.fromJson<String>(json['action']),
      actionAt: serializer.fromJson<int>(json['actionAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'questId': serializer.toJson<int?>(questId),
      'dueDate': serializer.toJson<int>(dueDate),
      'action': serializer.toJson<String>(action),
      'actionAt': serializer.toJson<int>(actionAt),
    };
  }

  NudgeLog copyWith(
          {int? id,
          int? contactId,
          Value<int?> questId = const Value.absent(),
          int? dueDate,
          String? action,
          int? actionAt}) =>
      NudgeLog(
        id: id ?? this.id,
        contactId: contactId ?? this.contactId,
        questId: questId.present ? questId.value : this.questId,
        dueDate: dueDate ?? this.dueDate,
        action: action ?? this.action,
        actionAt: actionAt ?? this.actionAt,
      );
  NudgeLog copyWithCompanion(NudgeLogsCompanion data) {
    return NudgeLog(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      questId: data.questId.present ? data.questId.value : this.questId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      action: data.action.present ? data.action.value : this.action,
      actionAt: data.actionAt.present ? data.actionAt.value : this.actionAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NudgeLog(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('questId: $questId, ')
          ..write('dueDate: $dueDate, ')
          ..write('action: $action, ')
          ..write('actionAt: $actionAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactId, questId, dueDate, action, actionAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NudgeLog &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.questId == this.questId &&
          other.dueDate == this.dueDate &&
          other.action == this.action &&
          other.actionAt == this.actionAt);
}

class NudgeLogsCompanion extends UpdateCompanion<NudgeLog> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<int?> questId;
  final Value<int> dueDate;
  final Value<String> action;
  final Value<int> actionAt;
  const NudgeLogsCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.questId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.action = const Value.absent(),
    this.actionAt = const Value.absent(),
  });
  NudgeLogsCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    this.questId = const Value.absent(),
    required int dueDate,
    required String action,
    required int actionAt,
  })  : contactId = Value(contactId),
        dueDate = Value(dueDate),
        action = Value(action),
        actionAt = Value(actionAt);
  static Insertable<NudgeLog> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<int>? questId,
    Expression<int>? dueDate,
    Expression<String>? action,
    Expression<int>? actionAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (questId != null) 'quest_id': questId,
      if (dueDate != null) 'due_date': dueDate,
      if (action != null) 'action': action,
      if (actionAt != null) 'action_at': actionAt,
    });
  }

  NudgeLogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? contactId,
      Value<int?>? questId,
      Value<int>? dueDate,
      Value<String>? action,
      Value<int>? actionAt}) {
    return NudgeLogsCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      questId: questId ?? this.questId,
      dueDate: dueDate ?? this.dueDate,
      action: action ?? this.action,
      actionAt: actionAt ?? this.actionAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<int>(questId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (actionAt.present) {
      map['action_at'] = Variable<int>(actionAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NudgeLogsCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('questId: $questId, ')
          ..write('dueDate: $dueDate, ')
          ..write('action: $action, ')
          ..write('actionAt: $actionAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationLedgersTable extends NotificationLedgers
    with TableInfo<$NotificationLedgersTable, NotificationLedger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLedgersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectKeyMeta =
      const VerificationMeta('subjectKey');
  @override
  late final GeneratedColumn<String> subjectKey = GeneratedColumn<String>(
      'subject_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastScheduledAtMeta =
      const VerificationMeta('lastScheduledAt');
  @override
  late final GeneratedColumn<int> lastScheduledAt = GeneratedColumn<int>(
      'last_scheduled_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, kind, subjectKey, lastScheduledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_ledgers';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationLedger> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('subject_key')) {
      context.handle(
          _subjectKeyMeta,
          subjectKey.isAcceptableOrUnknown(
              data['subject_key']!, _subjectKeyMeta));
    } else if (isInserting) {
      context.missing(_subjectKeyMeta);
    }
    if (data.containsKey('last_scheduled_at')) {
      context.handle(
          _lastScheduledAtMeta,
          lastScheduledAt.isAcceptableOrUnknown(
              data['last_scheduled_at']!, _lastScheduledAtMeta));
    } else if (isInserting) {
      context.missing(_lastScheduledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {kind, subjectKey},
      ];
  @override
  NotificationLedger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLedger(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      subjectKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_key'])!,
      lastScheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_scheduled_at'])!,
    );
  }

  @override
  $NotificationLedgersTable createAlias(String alias) {
    return $NotificationLedgersTable(attachedDatabase, alias);
  }
}

class NotificationLedger extends DataClass
    implements Insertable<NotificationLedger> {
  final int id;
  final String kind;
  final String subjectKey;
  final int lastScheduledAt;
  const NotificationLedger(
      {required this.id,
      required this.kind,
      required this.subjectKey,
      required this.lastScheduledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['subject_key'] = Variable<String>(subjectKey);
    map['last_scheduled_at'] = Variable<int>(lastScheduledAt);
    return map;
  }

  NotificationLedgersCompanion toCompanion(bool nullToAbsent) {
    return NotificationLedgersCompanion(
      id: Value(id),
      kind: Value(kind),
      subjectKey: Value(subjectKey),
      lastScheduledAt: Value(lastScheduledAt),
    );
  }

  factory NotificationLedger.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLedger(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      subjectKey: serializer.fromJson<String>(json['subjectKey']),
      lastScheduledAt: serializer.fromJson<int>(json['lastScheduledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'subjectKey': serializer.toJson<String>(subjectKey),
      'lastScheduledAt': serializer.toJson<int>(lastScheduledAt),
    };
  }

  NotificationLedger copyWith(
          {int? id, String? kind, String? subjectKey, int? lastScheduledAt}) =>
      NotificationLedger(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        subjectKey: subjectKey ?? this.subjectKey,
        lastScheduledAt: lastScheduledAt ?? this.lastScheduledAt,
      );
  NotificationLedger copyWithCompanion(NotificationLedgersCompanion data) {
    return NotificationLedger(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      subjectKey:
          data.subjectKey.present ? data.subjectKey.value : this.subjectKey,
      lastScheduledAt: data.lastScheduledAt.present
          ? data.lastScheduledAt.value
          : this.lastScheduledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLedger(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('subjectKey: $subjectKey, ')
          ..write('lastScheduledAt: $lastScheduledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, subjectKey, lastScheduledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLedger &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.subjectKey == this.subjectKey &&
          other.lastScheduledAt == this.lastScheduledAt);
}

class NotificationLedgersCompanion extends UpdateCompanion<NotificationLedger> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> subjectKey;
  final Value<int> lastScheduledAt;
  const NotificationLedgersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.subjectKey = const Value.absent(),
    this.lastScheduledAt = const Value.absent(),
  });
  NotificationLedgersCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String subjectKey,
    required int lastScheduledAt,
  })  : kind = Value(kind),
        subjectKey = Value(subjectKey),
        lastScheduledAt = Value(lastScheduledAt);
  static Insertable<NotificationLedger> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? subjectKey,
    Expression<int>? lastScheduledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (subjectKey != null) 'subject_key': subjectKey,
      if (lastScheduledAt != null) 'last_scheduled_at': lastScheduledAt,
    });
  }

  NotificationLedgersCompanion copyWith(
      {Value<int>? id,
      Value<String>? kind,
      Value<String>? subjectKey,
      Value<int>? lastScheduledAt}) {
    return NotificationLedgersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      subjectKey: subjectKey ?? this.subjectKey,
      lastScheduledAt: lastScheduledAt ?? this.lastScheduledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (subjectKey.present) {
      map['subject_key'] = Variable<String>(subjectKey.value);
    }
    if (lastScheduledAt.present) {
      map['last_scheduled_at'] = Variable<int>(lastScheduledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLedgersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('subjectKey: $subjectKey, ')
          ..write('lastScheduledAt: $lastScheduledAt')
          ..write(')'))
        .toString();
  }
}

class $SideQuestsTable extends SideQuests
    with TableInfo<$SideQuestsTable, SideQuest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SideQuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
      'day_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _promptIdMeta =
      const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
      'prompt_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactIdMeta =
      const VerificationMeta('contactId');
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
      'contact_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES contacts (id) ON DELETE SET NULL'));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dayKey, promptId, contactId, completedAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'side_quests';
  @override
  VerificationContext validateIntegrity(Insertable<SideQuest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day_key')) {
      context.handle(_dayKeyMeta,
          dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta));
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta,
          promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(_contactIdMeta,
          contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SideQuest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SideQuest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dayKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}day_key'])!,
      promptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      contactId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contact_id']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SideQuestsTable createAlias(String alias) {
    return $SideQuestsTable(attachedDatabase, alias);
  }
}

class SideQuest extends DataClass implements Insertable<SideQuest> {
  final int id;
  final String dayKey;
  final String promptId;
  final int? contactId;
  final int? completedAt;
  final int createdAt;
  const SideQuest(
      {required this.id,
      required this.dayKey,
      required this.promptId,
      this.contactId,
      this.completedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day_key'] = Variable<String>(dayKey);
    map['prompt_id'] = Variable<String>(promptId);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SideQuestsCompanion toCompanion(bool nullToAbsent) {
    return SideQuestsCompanion(
      id: Value(id),
      dayKey: Value(dayKey),
      promptId: Value(promptId),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
    );
  }

  factory SideQuest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SideQuest(
      id: serializer.fromJson<int>(json['id']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      promptId: serializer.fromJson<String>(json['promptId']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dayKey': serializer.toJson<String>(dayKey),
      'promptId': serializer.toJson<String>(promptId),
      'contactId': serializer.toJson<int?>(contactId),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SideQuest copyWith(
          {int? id,
          String? dayKey,
          String? promptId,
          Value<int?> contactId = const Value.absent(),
          Value<int?> completedAt = const Value.absent(),
          int? createdAt}) =>
      SideQuest(
        id: id ?? this.id,
        dayKey: dayKey ?? this.dayKey,
        promptId: promptId ?? this.promptId,
        contactId: contactId.present ? contactId.value : this.contactId,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  SideQuest copyWithCompanion(SideQuestsCompanion data) {
    return SideQuest(
      id: data.id.present ? data.id.value : this.id,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SideQuest(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('promptId: $promptId, ')
          ..write('contactId: $contactId, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, dayKey, promptId, contactId, completedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SideQuest &&
          other.id == this.id &&
          other.dayKey == this.dayKey &&
          other.promptId == this.promptId &&
          other.contactId == this.contactId &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt);
}

class SideQuestsCompanion extends UpdateCompanion<SideQuest> {
  final Value<int> id;
  final Value<String> dayKey;
  final Value<String> promptId;
  final Value<int?> contactId;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  const SideQuestsCompanion({
    this.id = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.promptId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SideQuestsCompanion.insert({
    this.id = const Value.absent(),
    required String dayKey,
    required String promptId,
    this.contactId = const Value.absent(),
    this.completedAt = const Value.absent(),
    required int createdAt,
  })  : dayKey = Value(dayKey),
        promptId = Value(promptId),
        createdAt = Value(createdAt);
  static Insertable<SideQuest> custom({
    Expression<int>? id,
    Expression<String>? dayKey,
    Expression<String>? promptId,
    Expression<int>? contactId,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayKey != null) 'day_key': dayKey,
      if (promptId != null) 'prompt_id': promptId,
      if (contactId != null) 'contact_id': contactId,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SideQuestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? dayKey,
      Value<String>? promptId,
      Value<int?>? contactId,
      Value<int?>? completedAt,
      Value<int>? createdAt}) {
    return SideQuestsCompanion(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      promptId: promptId ?? this.promptId,
      contactId: contactId ?? this.contactId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SideQuestsCompanion(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('promptId: $promptId, ')
          ..write('contactId: $contactId, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GlobalStreaksTable extends GlobalStreaks
    with TableInfo<$GlobalStreaksTable, GlobalStreak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlobalStreaksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bestStreakMeta =
      const VerificationMeta('bestStreak');
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
      'best_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastWinPeriodMeta =
      const VerificationMeta('lastWinPeriod');
  @override
  late final GeneratedColumn<int> lastWinPeriod = GeneratedColumn<int>(
      'last_win_period', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, currentStreak, bestStreak, lastWinPeriod];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'global_streaks';
  @override
  VerificationContext validateIntegrity(Insertable<GlobalStreak> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    }
    if (data.containsKey('best_streak')) {
      context.handle(
          _bestStreakMeta,
          bestStreak.isAcceptableOrUnknown(
              data['best_streak']!, _bestStreakMeta));
    }
    if (data.containsKey('last_win_period')) {
      context.handle(
          _lastWinPeriodMeta,
          lastWinPeriod.isAcceptableOrUnknown(
              data['last_win_period']!, _lastWinPeriodMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlobalStreak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlobalStreak(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
      bestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}best_streak'])!,
      lastWinPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_win_period']),
    );
  }

  @override
  $GlobalStreaksTable createAlias(String alias) {
    return $GlobalStreaksTable(attachedDatabase, alias);
  }
}

class GlobalStreak extends DataClass implements Insertable<GlobalStreak> {
  final int id;
  final int currentStreak;
  final int bestStreak;
  final int? lastWinPeriod;
  const GlobalStreak(
      {required this.id,
      required this.currentStreak,
      required this.bestStreak,
      this.lastWinPeriod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak'] = Variable<int>(currentStreak);
    map['best_streak'] = Variable<int>(bestStreak);
    if (!nullToAbsent || lastWinPeriod != null) {
      map['last_win_period'] = Variable<int>(lastWinPeriod);
    }
    return map;
  }

  GlobalStreaksCompanion toCompanion(bool nullToAbsent) {
    return GlobalStreaksCompanion(
      id: Value(id),
      currentStreak: Value(currentStreak),
      bestStreak: Value(bestStreak),
      lastWinPeriod: lastWinPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWinPeriod),
    );
  }

  factory GlobalStreak.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlobalStreak(
      id: serializer.fromJson<int>(json['id']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      lastWinPeriod: serializer.fromJson<int?>(json['lastWinPeriod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'lastWinPeriod': serializer.toJson<int?>(lastWinPeriod),
    };
  }

  GlobalStreak copyWith(
          {int? id,
          int? currentStreak,
          int? bestStreak,
          Value<int?> lastWinPeriod = const Value.absent()}) =>
      GlobalStreak(
        id: id ?? this.id,
        currentStreak: currentStreak ?? this.currentStreak,
        bestStreak: bestStreak ?? this.bestStreak,
        lastWinPeriod:
            lastWinPeriod.present ? lastWinPeriod.value : this.lastWinPeriod,
      );
  GlobalStreak copyWithCompanion(GlobalStreaksCompanion data) {
    return GlobalStreak(
      id: data.id.present ? data.id.value : this.id,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      bestStreak:
          data.bestStreak.present ? data.bestStreak.value : this.bestStreak,
      lastWinPeriod: data.lastWinPeriod.present
          ? data.lastWinPeriod.value
          : this.lastWinPeriod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlobalStreak(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastWinPeriod: $lastWinPeriod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currentStreak, bestStreak, lastWinPeriod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlobalStreak &&
          other.id == this.id &&
          other.currentStreak == this.currentStreak &&
          other.bestStreak == this.bestStreak &&
          other.lastWinPeriod == this.lastWinPeriod);
}

class GlobalStreaksCompanion extends UpdateCompanion<GlobalStreak> {
  final Value<int> id;
  final Value<int> currentStreak;
  final Value<int> bestStreak;
  final Value<int?> lastWinPeriod;
  const GlobalStreaksCompanion({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastWinPeriod = const Value.absent(),
  });
  GlobalStreaksCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastWinPeriod = const Value.absent(),
  });
  static Insertable<GlobalStreak> custom({
    Expression<int>? id,
    Expression<int>? currentStreak,
    Expression<int>? bestStreak,
    Expression<int>? lastWinPeriod,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (lastWinPeriod != null) 'last_win_period': lastWinPeriod,
    });
  }

  GlobalStreaksCompanion copyWith(
      {Value<int>? id,
      Value<int>? currentStreak,
      Value<int>? bestStreak,
      Value<int?>? lastWinPeriod}) {
    return GlobalStreaksCompanion(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastWinPeriod: lastWinPeriod ?? this.lastWinPeriod,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (lastWinPeriod.present) {
      map['last_win_period'] = Variable<int>(lastWinPeriod.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlobalStreaksCompanion(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastWinPeriod: $lastWinPeriod')
          ..write(')'))
        .toString();
  }
}

class $MessageTemplatesTable extends MessageTemplates
    with TableInfo<$MessageTemplatesTable, MessageTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, groupId, body, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_templates';
  @override
  VerificationContext validateIntegrity(Insertable<MessageTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id']),
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
    );
  }

  @override
  $MessageTemplatesTable createAlias(String alias) {
    return $MessageTemplatesTable(attachedDatabase, alias);
  }
}

class MessageTemplate extends DataClass implements Insertable<MessageTemplate> {
  final int id;
  final int? groupId;
  final String body;
  final bool isDefault;
  const MessageTemplate(
      {required this.id,
      this.groupId,
      required this.body,
      required this.isDefault});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<int>(groupId);
    }
    map['body'] = Variable<String>(body);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  MessageTemplatesCompanion toCompanion(bool nullToAbsent) {
    return MessageTemplatesCompanion(
      id: Value(id),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      body: Value(body),
      isDefault: Value(isDefault),
    );
  }

  factory MessageTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageTemplate(
      id: serializer.fromJson<int>(json['id']),
      groupId: serializer.fromJson<int?>(json['groupId']),
      body: serializer.fromJson<String>(json['body']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupId': serializer.toJson<int?>(groupId),
      'body': serializer.toJson<String>(body),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  MessageTemplate copyWith(
          {int? id,
          Value<int?> groupId = const Value.absent(),
          String? body,
          bool? isDefault}) =>
      MessageTemplate(
        id: id ?? this.id,
        groupId: groupId.present ? groupId.value : this.groupId,
        body: body ?? this.body,
        isDefault: isDefault ?? this.isDefault,
      );
  MessageTemplate copyWithCompanion(MessageTemplatesCompanion data) {
    return MessageTemplate(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      body: data.body.present ? data.body.value : this.body,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageTemplate(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('body: $body, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, body, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageTemplate &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.body == this.body &&
          other.isDefault == this.isDefault);
}

class MessageTemplatesCompanion extends UpdateCompanion<MessageTemplate> {
  final Value<int> id;
  final Value<int?> groupId;
  final Value<String> body;
  final Value<bool> isDefault;
  const MessageTemplatesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.body = const Value.absent(),
    this.isDefault = const Value.absent(),
  });
  MessageTemplatesCompanion.insert({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    required String body,
    this.isDefault = const Value.absent(),
  }) : body = Value(body);
  static Insertable<MessageTemplate> custom({
    Expression<int>? id,
    Expression<int>? groupId,
    Expression<String>? body,
    Expression<bool>? isDefault,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (body != null) 'body': body,
      if (isDefault != null) 'is_default': isDefault,
    });
  }

  MessageTemplatesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? groupId,
      Value<String>? body,
      Value<bool>? isDefault}) {
    return MessageTemplatesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      body: body ?? this.body,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('body: $body, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _questTypeMeta =
      const VerificationMeta('questType');
  @override
  late final GeneratedColumn<String> questType = GeneratedColumn<String>(
      'quest_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('daily'));
  static const VerificationMeta _questSizeNMeta =
      const VerificationMeta('questSizeN');
  @override
  late final GeneratedColumn<int> questSizeN = GeneratedColumn<int>(
      'quest_size_n', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _kThresholdMeta =
      const VerificationMeta('kThreshold');
  @override
  late final GeneratedColumn<int> kThreshold = GeneratedColumn<int>(
      'k_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(2));
  static const VerificationMeta _notifyHourMeta =
      const VerificationMeta('notifyHour');
  @override
  late final GeneratedColumn<int> notifyHour = GeneratedColumn<int>(
      'notify_hour', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(9));
  static const VerificationMeta _notifyMinuteMeta =
      const VerificationMeta('notifyMinute');
  @override
  late final GeneratedColumn<int> notifyMinute = GeneratedColumn<int>(
      'notify_minute', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quietHoursStartMeta =
      const VerificationMeta('quietHoursStart');
  @override
  late final GeneratedColumn<int> quietHoursStart = GeneratedColumn<int>(
      'quiet_hours_start', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _quietHoursEndMeta =
      const VerificationMeta('quietHoursEnd');
  @override
  late final GeneratedColumn<int> quietHoursEnd = GeneratedColumn<int>(
      'quiet_hours_end', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _prefillStarterMeta =
      const VerificationMeta('prefillStarter');
  @override
  late final GeneratedColumn<bool> prefillStarter = GeneratedColumn<bool>(
      'prefill_starter', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prefill_starter" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _onboardingDoneMeta =
      const VerificationMeta('onboardingDone');
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
      'onboarding_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _whatsappTargetMeta =
      const VerificationMeta('whatsappTarget');
  @override
  late final GeneratedColumn<String> whatsappTarget = GeneratedColumn<String>(
      'whatsapp_target', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('auto'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questType,
        questSizeN,
        kThreshold,
        notifyHour,
        notifyMinute,
        quietHoursStart,
        quietHoursEnd,
        prefillStarter,
        onboardingDone,
        whatsappTarget
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quest_type')) {
      context.handle(_questTypeMeta,
          questType.isAcceptableOrUnknown(data['quest_type']!, _questTypeMeta));
    }
    if (data.containsKey('quest_size_n')) {
      context.handle(
          _questSizeNMeta,
          questSizeN.isAcceptableOrUnknown(
              data['quest_size_n']!, _questSizeNMeta));
    }
    if (data.containsKey('k_threshold')) {
      context.handle(
          _kThresholdMeta,
          kThreshold.isAcceptableOrUnknown(
              data['k_threshold']!, _kThresholdMeta));
    }
    if (data.containsKey('notify_hour')) {
      context.handle(
          _notifyHourMeta,
          notifyHour.isAcceptableOrUnknown(
              data['notify_hour']!, _notifyHourMeta));
    }
    if (data.containsKey('notify_minute')) {
      context.handle(
          _notifyMinuteMeta,
          notifyMinute.isAcceptableOrUnknown(
              data['notify_minute']!, _notifyMinuteMeta));
    }
    if (data.containsKey('quiet_hours_start')) {
      context.handle(
          _quietHoursStartMeta,
          quietHoursStart.isAcceptableOrUnknown(
              data['quiet_hours_start']!, _quietHoursStartMeta));
    }
    if (data.containsKey('quiet_hours_end')) {
      context.handle(
          _quietHoursEndMeta,
          quietHoursEnd.isAcceptableOrUnknown(
              data['quiet_hours_end']!, _quietHoursEndMeta));
    }
    if (data.containsKey('prefill_starter')) {
      context.handle(
          _prefillStarterMeta,
          prefillStarter.isAcceptableOrUnknown(
              data['prefill_starter']!, _prefillStarterMeta));
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
          _onboardingDoneMeta,
          onboardingDone.isAcceptableOrUnknown(
              data['onboarding_done']!, _onboardingDoneMeta));
    }
    if (data.containsKey('whatsapp_target')) {
      context.handle(
          _whatsappTargetMeta,
          whatsappTarget.isAcceptableOrUnknown(
              data['whatsapp_target']!, _whatsappTargetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      questType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quest_type'])!,
      questSizeN: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quest_size_n'])!,
      kThreshold: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}k_threshold'])!,
      notifyHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notify_hour'])!,
      notifyMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}notify_minute'])!,
      quietHoursStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quiet_hours_start']),
      quietHoursEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quiet_hours_end']),
      prefillStarter: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}prefill_starter'])!,
      onboardingDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}onboarding_done'])!,
      whatsappTarget: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}whatsapp_target'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final int id;
  final String questType;
  final int questSizeN;
  final int kThreshold;
  final int notifyHour;
  final int notifyMinute;
  final int? quietHoursStart;
  final int? quietHoursEnd;
  final bool prefillStarter;
  final bool onboardingDone;
  final String whatsappTarget;
  const SettingsTableData(
      {required this.id,
      required this.questType,
      required this.questSizeN,
      required this.kThreshold,
      required this.notifyHour,
      required this.notifyMinute,
      this.quietHoursStart,
      this.quietHoursEnd,
      required this.prefillStarter,
      required this.onboardingDone,
      required this.whatsappTarget});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quest_type'] = Variable<String>(questType);
    map['quest_size_n'] = Variable<int>(questSizeN);
    map['k_threshold'] = Variable<int>(kThreshold);
    map['notify_hour'] = Variable<int>(notifyHour);
    map['notify_minute'] = Variable<int>(notifyMinute);
    if (!nullToAbsent || quietHoursStart != null) {
      map['quiet_hours_start'] = Variable<int>(quietHoursStart);
    }
    if (!nullToAbsent || quietHoursEnd != null) {
      map['quiet_hours_end'] = Variable<int>(quietHoursEnd);
    }
    map['prefill_starter'] = Variable<bool>(prefillStarter);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['whatsapp_target'] = Variable<String>(whatsappTarget);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      questType: Value(questType),
      questSizeN: Value(questSizeN),
      kThreshold: Value(kThreshold),
      notifyHour: Value(notifyHour),
      notifyMinute: Value(notifyMinute),
      quietHoursStart: quietHoursStart == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursStart),
      quietHoursEnd: quietHoursEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(quietHoursEnd),
      prefillStarter: Value(prefillStarter),
      onboardingDone: Value(onboardingDone),
      whatsappTarget: Value(whatsappTarget),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      questType: serializer.fromJson<String>(json['questType']),
      questSizeN: serializer.fromJson<int>(json['questSizeN']),
      kThreshold: serializer.fromJson<int>(json['kThreshold']),
      notifyHour: serializer.fromJson<int>(json['notifyHour']),
      notifyMinute: serializer.fromJson<int>(json['notifyMinute']),
      quietHoursStart: serializer.fromJson<int?>(json['quietHoursStart']),
      quietHoursEnd: serializer.fromJson<int?>(json['quietHoursEnd']),
      prefillStarter: serializer.fromJson<bool>(json['prefillStarter']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      whatsappTarget: serializer.fromJson<String>(json['whatsappTarget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questType': serializer.toJson<String>(questType),
      'questSizeN': serializer.toJson<int>(questSizeN),
      'kThreshold': serializer.toJson<int>(kThreshold),
      'notifyHour': serializer.toJson<int>(notifyHour),
      'notifyMinute': serializer.toJson<int>(notifyMinute),
      'quietHoursStart': serializer.toJson<int?>(quietHoursStart),
      'quietHoursEnd': serializer.toJson<int?>(quietHoursEnd),
      'prefillStarter': serializer.toJson<bool>(prefillStarter),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'whatsappTarget': serializer.toJson<String>(whatsappTarget),
    };
  }

  SettingsTableData copyWith(
          {int? id,
          String? questType,
          int? questSizeN,
          int? kThreshold,
          int? notifyHour,
          int? notifyMinute,
          Value<int?> quietHoursStart = const Value.absent(),
          Value<int?> quietHoursEnd = const Value.absent(),
          bool? prefillStarter,
          bool? onboardingDone,
          String? whatsappTarget}) =>
      SettingsTableData(
        id: id ?? this.id,
        questType: questType ?? this.questType,
        questSizeN: questSizeN ?? this.questSizeN,
        kThreshold: kThreshold ?? this.kThreshold,
        notifyHour: notifyHour ?? this.notifyHour,
        notifyMinute: notifyMinute ?? this.notifyMinute,
        quietHoursStart: quietHoursStart.present
            ? quietHoursStart.value
            : this.quietHoursStart,
        quietHoursEnd:
            quietHoursEnd.present ? quietHoursEnd.value : this.quietHoursEnd,
        prefillStarter: prefillStarter ?? this.prefillStarter,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        whatsappTarget: whatsappTarget ?? this.whatsappTarget,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      questType: data.questType.present ? data.questType.value : this.questType,
      questSizeN:
          data.questSizeN.present ? data.questSizeN.value : this.questSizeN,
      kThreshold:
          data.kThreshold.present ? data.kThreshold.value : this.kThreshold,
      notifyHour:
          data.notifyHour.present ? data.notifyHour.value : this.notifyHour,
      notifyMinute: data.notifyMinute.present
          ? data.notifyMinute.value
          : this.notifyMinute,
      quietHoursStart: data.quietHoursStart.present
          ? data.quietHoursStart.value
          : this.quietHoursStart,
      quietHoursEnd: data.quietHoursEnd.present
          ? data.quietHoursEnd.value
          : this.quietHoursEnd,
      prefillStarter: data.prefillStarter.present
          ? data.prefillStarter.value
          : this.prefillStarter,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      whatsappTarget: data.whatsappTarget.present
          ? data.whatsappTarget.value
          : this.whatsappTarget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('id: $id, ')
          ..write('questType: $questType, ')
          ..write('questSizeN: $questSizeN, ')
          ..write('kThreshold: $kThreshold, ')
          ..write('notifyHour: $notifyHour, ')
          ..write('notifyMinute: $notifyMinute, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('prefillStarter: $prefillStarter, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('whatsappTarget: $whatsappTarget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      questType,
      questSizeN,
      kThreshold,
      notifyHour,
      notifyMinute,
      quietHoursStart,
      quietHoursEnd,
      prefillStarter,
      onboardingDone,
      whatsappTarget);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.id == this.id &&
          other.questType == this.questType &&
          other.questSizeN == this.questSizeN &&
          other.kThreshold == this.kThreshold &&
          other.notifyHour == this.notifyHour &&
          other.notifyMinute == this.notifyMinute &&
          other.quietHoursStart == this.quietHoursStart &&
          other.quietHoursEnd == this.quietHoursEnd &&
          other.prefillStarter == this.prefillStarter &&
          other.onboardingDone == this.onboardingDone &&
          other.whatsappTarget == this.whatsappTarget);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<int> id;
  final Value<String> questType;
  final Value<int> questSizeN;
  final Value<int> kThreshold;
  final Value<int> notifyHour;
  final Value<int> notifyMinute;
  final Value<int?> quietHoursStart;
  final Value<int?> quietHoursEnd;
  final Value<bool> prefillStarter;
  final Value<bool> onboardingDone;
  final Value<String> whatsappTarget;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.questType = const Value.absent(),
    this.questSizeN = const Value.absent(),
    this.kThreshold = const Value.absent(),
    this.notifyHour = const Value.absent(),
    this.notifyMinute = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.prefillStarter = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.whatsappTarget = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.questType = const Value.absent(),
    this.questSizeN = const Value.absent(),
    this.kThreshold = const Value.absent(),
    this.notifyHour = const Value.absent(),
    this.notifyMinute = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.prefillStarter = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.whatsappTarget = const Value.absent(),
  });
  static Insertable<SettingsTableData> custom({
    Expression<int>? id,
    Expression<String>? questType,
    Expression<int>? questSizeN,
    Expression<int>? kThreshold,
    Expression<int>? notifyHour,
    Expression<int>? notifyMinute,
    Expression<int>? quietHoursStart,
    Expression<int>? quietHoursEnd,
    Expression<bool>? prefillStarter,
    Expression<bool>? onboardingDone,
    Expression<String>? whatsappTarget,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questType != null) 'quest_type': questType,
      if (questSizeN != null) 'quest_size_n': questSizeN,
      if (kThreshold != null) 'k_threshold': kThreshold,
      if (notifyHour != null) 'notify_hour': notifyHour,
      if (notifyMinute != null) 'notify_minute': notifyMinute,
      if (quietHoursStart != null) 'quiet_hours_start': quietHoursStart,
      if (quietHoursEnd != null) 'quiet_hours_end': quietHoursEnd,
      if (prefillStarter != null) 'prefill_starter': prefillStarter,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (whatsappTarget != null) 'whatsapp_target': whatsappTarget,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? questType,
      Value<int>? questSizeN,
      Value<int>? kThreshold,
      Value<int>? notifyHour,
      Value<int>? notifyMinute,
      Value<int?>? quietHoursStart,
      Value<int?>? quietHoursEnd,
      Value<bool>? prefillStarter,
      Value<bool>? onboardingDone,
      Value<String>? whatsappTarget}) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      questType: questType ?? this.questType,
      questSizeN: questSizeN ?? this.questSizeN,
      kThreshold: kThreshold ?? this.kThreshold,
      notifyHour: notifyHour ?? this.notifyHour,
      notifyMinute: notifyMinute ?? this.notifyMinute,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      prefillStarter: prefillStarter ?? this.prefillStarter,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      whatsappTarget: whatsappTarget ?? this.whatsappTarget,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questType.present) {
      map['quest_type'] = Variable<String>(questType.value);
    }
    if (questSizeN.present) {
      map['quest_size_n'] = Variable<int>(questSizeN.value);
    }
    if (kThreshold.present) {
      map['k_threshold'] = Variable<int>(kThreshold.value);
    }
    if (notifyHour.present) {
      map['notify_hour'] = Variable<int>(notifyHour.value);
    }
    if (notifyMinute.present) {
      map['notify_minute'] = Variable<int>(notifyMinute.value);
    }
    if (quietHoursStart.present) {
      map['quiet_hours_start'] = Variable<int>(quietHoursStart.value);
    }
    if (quietHoursEnd.present) {
      map['quiet_hours_end'] = Variable<int>(quietHoursEnd.value);
    }
    if (prefillStarter.present) {
      map['prefill_starter'] = Variable<bool>(prefillStarter.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (whatsappTarget.present) {
      map['whatsapp_target'] = Variable<String>(whatsappTarget.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('questType: $questType, ')
          ..write('questSizeN: $questSizeN, ')
          ..write('kThreshold: $kThreshold, ')
          ..write('notifyHour: $notifyHour, ')
          ..write('notifyMinute: $notifyMinute, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('prefillStarter: $prefillStarter, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('whatsappTarget: $whatsappTarget')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembershipsTable groupMemberships =
      $GroupMembershipsTable(this);
  late final $ContactFrequencyOverridesTable contactFrequencyOverrides =
      $ContactFrequencyOverridesTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $QuestItemsTable questItems = $QuestItemsTable(this);
  late final $NudgeLogsTable nudgeLogs = $NudgeLogsTable(this);
  late final $NotificationLedgersTable notificationLedgers =
      $NotificationLedgersTable(this);
  late final $SideQuestsTable sideQuests = $SideQuestsTable(this);
  late final $GlobalStreaksTable globalStreaks = $GlobalStreaksTable(this);
  late final $MessageTemplatesTable messageTemplates =
      $MessageTemplatesTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        contacts,
        groups,
        groupMemberships,
        contactFrequencyOverrides,
        quests,
        questItems,
        nudgeLogs,
        notificationLedgers,
        sideQuests,
        globalStreaks,
        messageTemplates,
        settingsTable
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('contacts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_memberships', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_memberships', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('contacts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('contact_frequency_overrides',
                  kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('quests',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('quest_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('contacts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('quest_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('contacts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('nudge_logs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('quests',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('nudge_logs', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('contacts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('side_quests', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('message_templates', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  Value<int> id,
  Value<String?> systemContactId,
  required String displayName,
  Value<String?> phoneE164,
  Value<String?> phoneRaw,
  Value<String?> photoUri,
  Value<bool> isStarredOnImport,
  Value<int?> lastReachedAt,
  Value<String?> notes,
  required int createdAt,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<int> id,
  Value<String?> systemContactId,
  Value<String> displayName,
  Value<String?> phoneE164,
  Value<String?> phoneRaw,
  Value<String?> photoUri,
  Value<bool> isStarredOnImport,
  Value<int?> lastReachedAt,
  Value<String?> notes,
  Value<int> createdAt,
});

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ContactsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ContactsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> systemContactId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> phoneE164 = const Value.absent(),
            Value<String?> phoneRaw = const Value.absent(),
            Value<String?> photoUri = const Value.absent(),
            Value<bool> isStarredOnImport = const Value.absent(),
            Value<int?> lastReachedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              ContactsCompanion(
            id: id,
            systemContactId: systemContactId,
            displayName: displayName,
            phoneE164: phoneE164,
            phoneRaw: phoneRaw,
            photoUri: photoUri,
            isStarredOnImport: isStarredOnImport,
            lastReachedAt: lastReachedAt,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> systemContactId = const Value.absent(),
            required String displayName,
            Value<String?> phoneE164 = const Value.absent(),
            Value<String?> phoneRaw = const Value.absent(),
            Value<String?> photoUri = const Value.absent(),
            Value<bool> isStarredOnImport = const Value.absent(),
            Value<int?> lastReachedAt = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required int createdAt,
          }) =>
              ContactsCompanion.insert(
            id: id,
            systemContactId: systemContactId,
            displayName: displayName,
            phoneE164: phoneE164,
            phoneRaw: phoneRaw,
            photoUri: photoUri,
            isStarredOnImport: isStarredOnImport,
            lastReachedAt: lastReachedAt,
            notes: notes,
            createdAt: createdAt,
          ),
        ));
}

class $$ContactsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get systemContactId => $state.composableBuilder(
      column: $state.table.systemContactId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get phoneE164 => $state.composableBuilder(
      column: $state.table.phoneE164,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get phoneRaw => $state.composableBuilder(
      column: $state.table.phoneRaw,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get photoUri => $state.composableBuilder(
      column: $state.table.photoUri,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isStarredOnImport => $state.composableBuilder(
      column: $state.table.isStarredOnImport,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get lastReachedAt => $state.composableBuilder(
      column: $state.table.lastReachedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter groupMembershipsRefs(
      ComposableFilter Function($$GroupMembershipsTableFilterComposer f) f) {
    final $$GroupMembershipsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.groupMemberships,
            getReferencedColumn: (t) => t.contactId,
            builder: (joinBuilder, parentComposers) =>
                $$GroupMembershipsTableFilterComposer(ComposerState($state.db,
                    $state.db.groupMemberships, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter contactFrequencyOverridesRefs(
      ComposableFilter Function(
              $$ContactFrequencyOverridesTableFilterComposer f)
          f) {
    final $$ContactFrequencyOverridesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.contactFrequencyOverrides,
            getReferencedColumn: (t) => t.contactId,
            builder: (joinBuilder, parentComposers) =>
                $$ContactFrequencyOverridesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.contactFrequencyOverrides,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter questItemsRefs(
      ComposableFilter Function($$QuestItemsTableFilterComposer f) f) {
    final $$QuestItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.questItems,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder, parentComposers) =>
            $$QuestItemsTableFilterComposer(ComposerState($state.db,
                $state.db.questItems, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter nudgeLogsRefs(
      ComposableFilter Function($$NudgeLogsTableFilterComposer f) f) {
    final $$NudgeLogsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.nudgeLogs,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder, parentComposers) =>
            $$NudgeLogsTableFilterComposer(ComposerState(
                $state.db, $state.db.nudgeLogs, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter sideQuestsRefs(
      ComposableFilter Function($$SideQuestsTableFilterComposer f) f) {
    final $$SideQuestsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.sideQuests,
        getReferencedColumn: (t) => t.contactId,
        builder: (joinBuilder, parentComposers) =>
            $$SideQuestsTableFilterComposer(ComposerState($state.db,
                $state.db.sideQuests, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get systemContactId => $state.composableBuilder(
      column: $state.table.systemContactId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get displayName => $state.composableBuilder(
      column: $state.table.displayName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get phoneE164 => $state.composableBuilder(
      column: $state.table.phoneE164,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get phoneRaw => $state.composableBuilder(
      column: $state.table.phoneRaw,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get photoUri => $state.composableBuilder(
      column: $state.table.photoUri,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isStarredOnImport => $state.composableBuilder(
      column: $state.table.isStarredOnImport,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get lastReachedAt => $state.composableBuilder(
      column: $state.table.lastReachedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> emoji,
  required int frequencyDays,
  Value<int> streakCount,
  Value<String?> streakLastDay,
  Value<String> ragHealth,
  Value<int> sortOrder,
  required int createdAt,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> emoji,
  Value<int> frequencyDays,
  Value<int> streakCount,
  Value<String?> streakLastDay,
  Value<String> ragHealth,
  Value<int> sortOrder,
  Value<int> createdAt,
});

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GroupsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GroupsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> emoji = const Value.absent(),
            Value<int> frequencyDays = const Value.absent(),
            Value<int> streakCount = const Value.absent(),
            Value<String?> streakLastDay = const Value.absent(),
            Value<String> ragHealth = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            emoji: emoji,
            frequencyDays: frequencyDays,
            streakCount: streakCount,
            streakLastDay: streakLastDay,
            ragHealth: ragHealth,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> emoji = const Value.absent(),
            required int frequencyDays,
            Value<int> streakCount = const Value.absent(),
            Value<String?> streakLastDay = const Value.absent(),
            Value<String> ragHealth = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required int createdAt,
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            emoji: emoji,
            frequencyDays: frequencyDays,
            streakCount: streakCount,
            streakLastDay: streakLastDay,
            ragHealth: ragHealth,
            sortOrder: sortOrder,
            createdAt: createdAt,
          ),
        ));
}

class $$GroupsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get frequencyDays => $state.composableBuilder(
      column: $state.table.frequencyDays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get streakCount => $state.composableBuilder(
      column: $state.table.streakCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get streakLastDay => $state.composableBuilder(
      column: $state.table.streakLastDay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get ragHealth => $state.composableBuilder(
      column: $state.table.ragHealth,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter groupMembershipsRefs(
      ComposableFilter Function($$GroupMembershipsTableFilterComposer f) f) {
    final $$GroupMembershipsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.groupMemberships,
            getReferencedColumn: (t) => t.groupId,
            builder: (joinBuilder, parentComposers) =>
                $$GroupMembershipsTableFilterComposer(ComposerState($state.db,
                    $state.db.groupMemberships, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter messageTemplatesRefs(
      ComposableFilter Function($$MessageTemplatesTableFilterComposer f) f) {
    final $$MessageTemplatesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.messageTemplates,
            getReferencedColumn: (t) => t.groupId,
            builder: (joinBuilder, parentComposers) =>
                $$MessageTemplatesTableFilterComposer(ComposerState($state.db,
                    $state.db.messageTemplates, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get emoji => $state.composableBuilder(
      column: $state.table.emoji,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get frequencyDays => $state.composableBuilder(
      column: $state.table.frequencyDays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get streakCount => $state.composableBuilder(
      column: $state.table.streakCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get streakLastDay => $state.composableBuilder(
      column: $state.table.streakLastDay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get ragHealth => $state.composableBuilder(
      column: $state.table.ragHealth,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$GroupMembershipsTableCreateCompanionBuilder
    = GroupMembershipsCompanion Function({
  Value<int> id,
  required int contactId,
  required int groupId,
});
typedef $$GroupMembershipsTableUpdateCompanionBuilder
    = GroupMembershipsCompanion Function({
  Value<int> id,
  Value<int> contactId,
  Value<int> groupId,
});

class $$GroupMembershipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupMembershipsTable,
    GroupMembership,
    $$GroupMembershipsTableFilterComposer,
    $$GroupMembershipsTableOrderingComposer,
    $$GroupMembershipsTableCreateCompanionBuilder,
    $$GroupMembershipsTableUpdateCompanionBuilder> {
  $$GroupMembershipsTableTableManager(
      _$AppDatabase db, $GroupMembershipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GroupMembershipsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GroupMembershipsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> contactId = const Value.absent(),
            Value<int> groupId = const Value.absent(),
          }) =>
              GroupMembershipsCompanion(
            id: id,
            contactId: contactId,
            groupId: groupId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int contactId,
            required int groupId,
          }) =>
              GroupMembershipsCompanion.insert(
            id: id,
            contactId: contactId,
            groupId: groupId,
          ),
        ));
}

class $$GroupMembershipsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GroupMembershipsTable> {
  $$GroupMembershipsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableFilterComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $state.db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$GroupsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.groups, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$GroupMembershipsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GroupMembershipsTable> {
  $$GroupMembershipsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableOrderingComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $state.db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$GroupsTableOrderingComposer(ComposerState(
                $state.db, $state.db.groups, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$ContactFrequencyOverridesTableCreateCompanionBuilder
    = ContactFrequencyOverridesCompanion Function({
  Value<int> contactId,
  required int frequencyDays,
});
typedef $$ContactFrequencyOverridesTableUpdateCompanionBuilder
    = ContactFrequencyOverridesCompanion Function({
  Value<int> contactId,
  Value<int> frequencyDays,
});

class $$ContactFrequencyOverridesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactFrequencyOverridesTable,
    ContactFrequencyOverride,
    $$ContactFrequencyOverridesTableFilterComposer,
    $$ContactFrequencyOverridesTableOrderingComposer,
    $$ContactFrequencyOverridesTableCreateCompanionBuilder,
    $$ContactFrequencyOverridesTableUpdateCompanionBuilder> {
  $$ContactFrequencyOverridesTableTableManager(
      _$AppDatabase db, $ContactFrequencyOverridesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$ContactFrequencyOverridesTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$ContactFrequencyOverridesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> contactId = const Value.absent(),
            Value<int> frequencyDays = const Value.absent(),
          }) =>
              ContactFrequencyOverridesCompanion(
            contactId: contactId,
            frequencyDays: frequencyDays,
          ),
          createCompanionCallback: ({
            Value<int> contactId = const Value.absent(),
            required int frequencyDays,
          }) =>
              ContactFrequencyOverridesCompanion.insert(
            contactId: contactId,
            frequencyDays: frequencyDays,
          ),
        ));
}

class $$ContactFrequencyOverridesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ContactFrequencyOverridesTable> {
  $$ContactFrequencyOverridesTableFilterComposer(super.$state);
  ColumnFilters<int> get frequencyDays => $state.composableBuilder(
      column: $state.table.frequencyDays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableFilterComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ContactFrequencyOverridesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ContactFrequencyOverridesTable> {
  $$ContactFrequencyOverridesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get frequencyDays => $state.composableBuilder(
      column: $state.table.frequencyDays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableOrderingComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  required int periodStart,
  required int periodEnd,
  required String type,
  required String poolContactIds,
  required int kThreshold,
  Value<int> reachedCount,
  required String status,
  required int createdAt,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  Value<int> periodStart,
  Value<int> periodEnd,
  Value<String> type,
  Value<String> poolContactIds,
  Value<int> kThreshold,
  Value<int> reachedCount,
  Value<String> status,
  Value<int> createdAt,
});

class $$QuestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestsTable,
    Quest,
    $$QuestsTableFilterComposer,
    $$QuestsTableOrderingComposer,
    $$QuestsTableCreateCompanionBuilder,
    $$QuestsTableUpdateCompanionBuilder> {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$QuestsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$QuestsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> periodStart = const Value.absent(),
            Value<int> periodEnd = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> poolContactIds = const Value.absent(),
            Value<int> kThreshold = const Value.absent(),
            Value<int> reachedCount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              QuestsCompanion(
            id: id,
            periodStart: periodStart,
            periodEnd: periodEnd,
            type: type,
            poolContactIds: poolContactIds,
            kThreshold: kThreshold,
            reachedCount: reachedCount,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int periodStart,
            required int periodEnd,
            required String type,
            required String poolContactIds,
            required int kThreshold,
            Value<int> reachedCount = const Value.absent(),
            required String status,
            required int createdAt,
          }) =>
              QuestsCompanion.insert(
            id: id,
            periodStart: periodStart,
            periodEnd: periodEnd,
            type: type,
            poolContactIds: poolContactIds,
            kThreshold: kThreshold,
            reachedCount: reachedCount,
            status: status,
            createdAt: createdAt,
          ),
        ));
}

class $$QuestsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get periodStart => $state.composableBuilder(
      column: $state.table.periodStart,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get periodEnd => $state.composableBuilder(
      column: $state.table.periodEnd,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get poolContactIds => $state.composableBuilder(
      column: $state.table.poolContactIds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get kThreshold => $state.composableBuilder(
      column: $state.table.kThreshold,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get reachedCount => $state.composableBuilder(
      column: $state.table.reachedCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter questItemsRefs(
      ComposableFilter Function($$QuestItemsTableFilterComposer f) f) {
    final $$QuestItemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.questItems,
        getReferencedColumn: (t) => t.questId,
        builder: (joinBuilder, parentComposers) =>
            $$QuestItemsTableFilterComposer(ComposerState($state.db,
                $state.db.questItems, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter nudgeLogsRefs(
      ComposableFilter Function($$NudgeLogsTableFilterComposer f) f) {
    final $$NudgeLogsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.nudgeLogs,
        getReferencedColumn: (t) => t.questId,
        builder: (joinBuilder, parentComposers) =>
            $$NudgeLogsTableFilterComposer(ComposerState(
                $state.db, $state.db.nudgeLogs, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$QuestsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get periodStart => $state.composableBuilder(
      column: $state.table.periodStart,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get periodEnd => $state.composableBuilder(
      column: $state.table.periodEnd,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get poolContactIds => $state.composableBuilder(
      column: $state.table.poolContactIds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get kThreshold => $state.composableBuilder(
      column: $state.table.kThreshold,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get reachedCount => $state.composableBuilder(
      column: $state.table.reachedCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$QuestItemsTableCreateCompanionBuilder = QuestItemsCompanion Function({
  Value<int> id,
  required int questId,
  required int contactId,
  required int rank,
  Value<String> state,
  Value<int?> actedAt,
});
typedef $$QuestItemsTableUpdateCompanionBuilder = QuestItemsCompanion Function({
  Value<int> id,
  Value<int> questId,
  Value<int> contactId,
  Value<int> rank,
  Value<String> state,
  Value<int?> actedAt,
});

class $$QuestItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestItemsTable,
    QuestItem,
    $$QuestItemsTableFilterComposer,
    $$QuestItemsTableOrderingComposer,
    $$QuestItemsTableCreateCompanionBuilder,
    $$QuestItemsTableUpdateCompanionBuilder> {
  $$QuestItemsTableTableManager(_$AppDatabase db, $QuestItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$QuestItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$QuestItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> questId = const Value.absent(),
            Value<int> contactId = const Value.absent(),
            Value<int> rank = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<int?> actedAt = const Value.absent(),
          }) =>
              QuestItemsCompanion(
            id: id,
            questId: questId,
            contactId: contactId,
            rank: rank,
            state: state,
            actedAt: actedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int questId,
            required int contactId,
            required int rank,
            Value<String> state = const Value.absent(),
            Value<int?> actedAt = const Value.absent(),
          }) =>
              QuestItemsCompanion.insert(
            id: id,
            questId: questId,
            contactId: contactId,
            rank: rank,
            state: state,
            actedAt: actedAt,
          ),
        ));
}

class $$QuestItemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $QuestItemsTable> {
  $$QuestItemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get rank => $state.composableBuilder(
      column: $state.table.rank,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get actedAt => $state.composableBuilder(
      column: $state.table.actedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$QuestsTableFilterComposer get questId {
    final $$QuestsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questId,
        referencedTable: $state.db.quests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$QuestsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.quests, joinBuilder, parentComposers)));
    return composer;
  }

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableFilterComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$QuestItemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $QuestItemsTable> {
  $$QuestItemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get rank => $state.composableBuilder(
      column: $state.table.rank,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get actedAt => $state.composableBuilder(
      column: $state.table.actedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$QuestsTableOrderingComposer get questId {
    final $$QuestsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questId,
        referencedTable: $state.db.quests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestsTableOrderingComposer(ComposerState(
                $state.db, $state.db.quests, joinBuilder, parentComposers)));
    return composer;
  }

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableOrderingComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$NudgeLogsTableCreateCompanionBuilder = NudgeLogsCompanion Function({
  Value<int> id,
  required int contactId,
  Value<int?> questId,
  required int dueDate,
  required String action,
  required int actionAt,
});
typedef $$NudgeLogsTableUpdateCompanionBuilder = NudgeLogsCompanion Function({
  Value<int> id,
  Value<int> contactId,
  Value<int?> questId,
  Value<int> dueDate,
  Value<String> action,
  Value<int> actionAt,
});

class $$NudgeLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NudgeLogsTable,
    NudgeLog,
    $$NudgeLogsTableFilterComposer,
    $$NudgeLogsTableOrderingComposer,
    $$NudgeLogsTableCreateCompanionBuilder,
    $$NudgeLogsTableUpdateCompanionBuilder> {
  $$NudgeLogsTableTableManager(_$AppDatabase db, $NudgeLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NudgeLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NudgeLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> contactId = const Value.absent(),
            Value<int?> questId = const Value.absent(),
            Value<int> dueDate = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<int> actionAt = const Value.absent(),
          }) =>
              NudgeLogsCompanion(
            id: id,
            contactId: contactId,
            questId: questId,
            dueDate: dueDate,
            action: action,
            actionAt: actionAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int contactId,
            Value<int?> questId = const Value.absent(),
            required int dueDate,
            required String action,
            required int actionAt,
          }) =>
              NudgeLogsCompanion.insert(
            id: id,
            contactId: contactId,
            questId: questId,
            dueDate: dueDate,
            action: action,
            actionAt: actionAt,
          ),
        ));
}

class $$NudgeLogsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NudgeLogsTable> {
  $$NudgeLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get actionAt => $state.composableBuilder(
      column: $state.table.actionAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableFilterComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }

  $$QuestsTableFilterComposer get questId {
    final $$QuestsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questId,
        referencedTable: $state.db.quests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$QuestsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.quests, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$NudgeLogsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NudgeLogsTable> {
  $$NudgeLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dueDate => $state.composableBuilder(
      column: $state.table.dueDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get action => $state.composableBuilder(
      column: $state.table.action,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get actionAt => $state.composableBuilder(
      column: $state.table.actionAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableOrderingComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }

  $$QuestsTableOrderingComposer get questId {
    final $$QuestsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questId,
        referencedTable: $state.db.quests,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$QuestsTableOrderingComposer(ComposerState(
                $state.db, $state.db.quests, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$NotificationLedgersTableCreateCompanionBuilder
    = NotificationLedgersCompanion Function({
  Value<int> id,
  required String kind,
  required String subjectKey,
  required int lastScheduledAt,
});
typedef $$NotificationLedgersTableUpdateCompanionBuilder
    = NotificationLedgersCompanion Function({
  Value<int> id,
  Value<String> kind,
  Value<String> subjectKey,
  Value<int> lastScheduledAt,
});

class $$NotificationLedgersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationLedgersTable,
    NotificationLedger,
    $$NotificationLedgersTableFilterComposer,
    $$NotificationLedgersTableOrderingComposer,
    $$NotificationLedgersTableCreateCompanionBuilder,
    $$NotificationLedgersTableUpdateCompanionBuilder> {
  $$NotificationLedgersTableTableManager(
      _$AppDatabase db, $NotificationLedgersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$NotificationLedgersTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$NotificationLedgersTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> subjectKey = const Value.absent(),
            Value<int> lastScheduledAt = const Value.absent(),
          }) =>
              NotificationLedgersCompanion(
            id: id,
            kind: kind,
            subjectKey: subjectKey,
            lastScheduledAt: lastScheduledAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String kind,
            required String subjectKey,
            required int lastScheduledAt,
          }) =>
              NotificationLedgersCompanion.insert(
            id: id,
            kind: kind,
            subjectKey: subjectKey,
            lastScheduledAt: lastScheduledAt,
          ),
        ));
}

class $$NotificationLedgersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NotificationLedgersTable> {
  $$NotificationLedgersTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get subjectKey => $state.composableBuilder(
      column: $state.table.subjectKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get lastScheduledAt => $state.composableBuilder(
      column: $state.table.lastScheduledAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$NotificationLedgersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NotificationLedgersTable> {
  $$NotificationLedgersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get subjectKey => $state.composableBuilder(
      column: $state.table.subjectKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get lastScheduledAt => $state.composableBuilder(
      column: $state.table.lastScheduledAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SideQuestsTableCreateCompanionBuilder = SideQuestsCompanion Function({
  Value<int> id,
  required String dayKey,
  required String promptId,
  Value<int?> contactId,
  Value<int?> completedAt,
  required int createdAt,
});
typedef $$SideQuestsTableUpdateCompanionBuilder = SideQuestsCompanion Function({
  Value<int> id,
  Value<String> dayKey,
  Value<String> promptId,
  Value<int?> contactId,
  Value<int?> completedAt,
  Value<int> createdAt,
});

class $$SideQuestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SideQuestsTable,
    SideQuest,
    $$SideQuestsTableFilterComposer,
    $$SideQuestsTableOrderingComposer,
    $$SideQuestsTableCreateCompanionBuilder,
    $$SideQuestsTableUpdateCompanionBuilder> {
  $$SideQuestsTableTableManager(_$AppDatabase db, $SideQuestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SideQuestsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SideQuestsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> dayKey = const Value.absent(),
            Value<String> promptId = const Value.absent(),
            Value<int?> contactId = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              SideQuestsCompanion(
            id: id,
            dayKey: dayKey,
            promptId: promptId,
            contactId: contactId,
            completedAt: completedAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String dayKey,
            required String promptId,
            Value<int?> contactId = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            required int createdAt,
          }) =>
              SideQuestsCompanion.insert(
            id: id,
            dayKey: dayKey,
            promptId: promptId,
            contactId: contactId,
            completedAt: completedAt,
            createdAt: createdAt,
          ),
        ));
}

class $$SideQuestsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SideQuestsTable> {
  $$SideQuestsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get dayKey => $state.composableBuilder(
      column: $state.table.dayKey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get promptId => $state.composableBuilder(
      column: $state.table.promptId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableFilterComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$SideQuestsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SideQuestsTable> {
  $$SideQuestsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get dayKey => $state.composableBuilder(
      column: $state.table.dayKey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get promptId => $state.composableBuilder(
      column: $state.table.promptId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.contactId,
        referencedTable: $state.db.contacts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ContactsTableOrderingComposer(ComposerState(
                $state.db, $state.db.contacts, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$GlobalStreaksTableCreateCompanionBuilder = GlobalStreaksCompanion
    Function({
  Value<int> id,
  Value<int> currentStreak,
  Value<int> bestStreak,
  Value<int?> lastWinPeriod,
});
typedef $$GlobalStreaksTableUpdateCompanionBuilder = GlobalStreaksCompanion
    Function({
  Value<int> id,
  Value<int> currentStreak,
  Value<int> bestStreak,
  Value<int?> lastWinPeriod,
});

class $$GlobalStreaksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GlobalStreaksTable,
    GlobalStreak,
    $$GlobalStreaksTableFilterComposer,
    $$GlobalStreaksTableOrderingComposer,
    $$GlobalStreaksTableCreateCompanionBuilder,
    $$GlobalStreaksTableUpdateCompanionBuilder> {
  $$GlobalStreaksTableTableManager(_$AppDatabase db, $GlobalStreaksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$GlobalStreaksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$GlobalStreaksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> bestStreak = const Value.absent(),
            Value<int?> lastWinPeriod = const Value.absent(),
          }) =>
              GlobalStreaksCompanion(
            id: id,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            lastWinPeriod: lastWinPeriod,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> bestStreak = const Value.absent(),
            Value<int?> lastWinPeriod = const Value.absent(),
          }) =>
              GlobalStreaksCompanion.insert(
            id: id,
            currentStreak: currentStreak,
            bestStreak: bestStreak,
            lastWinPeriod: lastWinPeriod,
          ),
        ));
}

class $$GlobalStreaksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $GlobalStreaksTable> {
  $$GlobalStreaksTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get bestStreak => $state.composableBuilder(
      column: $state.table.bestStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get lastWinPeriod => $state.composableBuilder(
      column: $state.table.lastWinPeriod,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$GlobalStreaksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $GlobalStreaksTable> {
  $$GlobalStreaksTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get bestStreak => $state.composableBuilder(
      column: $state.table.bestStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get lastWinPeriod => $state.composableBuilder(
      column: $state.table.lastWinPeriod,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$MessageTemplatesTableCreateCompanionBuilder
    = MessageTemplatesCompanion Function({
  Value<int> id,
  Value<int?> groupId,
  required String body,
  Value<bool> isDefault,
});
typedef $$MessageTemplatesTableUpdateCompanionBuilder
    = MessageTemplatesCompanion Function({
  Value<int> id,
  Value<int?> groupId,
  Value<String> body,
  Value<bool> isDefault,
});

class $$MessageTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageTemplatesTable,
    MessageTemplate,
    $$MessageTemplatesTableFilterComposer,
    $$MessageTemplatesTableOrderingComposer,
    $$MessageTemplatesTableCreateCompanionBuilder,
    $$MessageTemplatesTableUpdateCompanionBuilder> {
  $$MessageTemplatesTableTableManager(
      _$AppDatabase db, $MessageTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$MessageTemplatesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$MessageTemplatesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
          }) =>
              MessageTemplatesCompanion(
            id: id,
            groupId: groupId,
            body: body,
            isDefault: isDefault,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> groupId = const Value.absent(),
            required String body,
            Value<bool> isDefault = const Value.absent(),
          }) =>
              MessageTemplatesCompanion.insert(
            id: id,
            groupId: groupId,
            body: body,
            isDefault: isDefault,
          ),
        ));
}

class $$MessageTemplatesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $MessageTemplatesTable> {
  $$MessageTemplatesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get body => $state.composableBuilder(
      column: $state.table.body,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $state.db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$GroupsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.groups, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$MessageTemplatesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $MessageTemplatesTable> {
  $$MessageTemplatesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get body => $state.composableBuilder(
      column: $state.table.body,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $state.db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$GroupsTableOrderingComposer(ComposerState(
                $state.db, $state.db.groups, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> questType,
  Value<int> questSizeN,
  Value<int> kThreshold,
  Value<int> notifyHour,
  Value<int> notifyMinute,
  Value<int?> quietHoursStart,
  Value<int?> quietHoursEnd,
  Value<bool> prefillStarter,
  Value<bool> onboardingDone,
  Value<String> whatsappTarget,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<int> id,
  Value<String> questType,
  Value<int> questSizeN,
  Value<int> kThreshold,
  Value<int> notifyHour,
  Value<int> notifyMinute,
  Value<int?> quietHoursStart,
  Value<int?> quietHoursEnd,
  Value<bool> prefillStarter,
  Value<bool> onboardingDone,
  Value<String> whatsappTarget,
});

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SettingsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SettingsTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> questType = const Value.absent(),
            Value<int> questSizeN = const Value.absent(),
            Value<int> kThreshold = const Value.absent(),
            Value<int> notifyHour = const Value.absent(),
            Value<int> notifyMinute = const Value.absent(),
            Value<int?> quietHoursStart = const Value.absent(),
            Value<int?> quietHoursEnd = const Value.absent(),
            Value<bool> prefillStarter = const Value.absent(),
            Value<bool> onboardingDone = const Value.absent(),
            Value<String> whatsappTarget = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            id: id,
            questType: questType,
            questSizeN: questSizeN,
            kThreshold: kThreshold,
            notifyHour: notifyHour,
            notifyMinute: notifyMinute,
            quietHoursStart: quietHoursStart,
            quietHoursEnd: quietHoursEnd,
            prefillStarter: prefillStarter,
            onboardingDone: onboardingDone,
            whatsappTarget: whatsappTarget,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> questType = const Value.absent(),
            Value<int> questSizeN = const Value.absent(),
            Value<int> kThreshold = const Value.absent(),
            Value<int> notifyHour = const Value.absent(),
            Value<int> notifyMinute = const Value.absent(),
            Value<int?> quietHoursStart = const Value.absent(),
            Value<int?> quietHoursEnd = const Value.absent(),
            Value<bool> prefillStarter = const Value.absent(),
            Value<bool> onboardingDone = const Value.absent(),
            Value<String> whatsappTarget = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            id: id,
            questType: questType,
            questSizeN: questSizeN,
            kThreshold: kThreshold,
            notifyHour: notifyHour,
            notifyMinute: notifyMinute,
            quietHoursStart: quietHoursStart,
            quietHoursEnd: quietHoursEnd,
            prefillStarter: prefillStarter,
            onboardingDone: onboardingDone,
            whatsappTarget: whatsappTarget,
          ),
        ));
}

class $$SettingsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get questType => $state.composableBuilder(
      column: $state.table.questType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get questSizeN => $state.composableBuilder(
      column: $state.table.questSizeN,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get kThreshold => $state.composableBuilder(
      column: $state.table.kThreshold,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get notifyHour => $state.composableBuilder(
      column: $state.table.notifyHour,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get notifyMinute => $state.composableBuilder(
      column: $state.table.notifyMinute,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quietHoursStart => $state.composableBuilder(
      column: $state.table.quietHoursStart,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quietHoursEnd => $state.composableBuilder(
      column: $state.table.quietHoursEnd,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get prefillStarter => $state.composableBuilder(
      column: $state.table.prefillStarter,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get onboardingDone => $state.composableBuilder(
      column: $state.table.onboardingDone,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get whatsappTarget => $state.composableBuilder(
      column: $state.table.whatsappTarget,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SettingsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get questType => $state.composableBuilder(
      column: $state.table.questType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get questSizeN => $state.composableBuilder(
      column: $state.table.questSizeN,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get kThreshold => $state.composableBuilder(
      column: $state.table.kThreshold,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get notifyHour => $state.composableBuilder(
      column: $state.table.notifyHour,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get notifyMinute => $state.composableBuilder(
      column: $state.table.notifyMinute,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quietHoursStart => $state.composableBuilder(
      column: $state.table.quietHoursStart,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quietHoursEnd => $state.composableBuilder(
      column: $state.table.quietHoursEnd,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get prefillStarter => $state.composableBuilder(
      column: $state.table.prefillStarter,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get onboardingDone => $state.composableBuilder(
      column: $state.table.onboardingDone,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get whatsappTarget => $state.composableBuilder(
      column: $state.table.whatsappTarget,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembershipsTableTableManager get groupMemberships =>
      $$GroupMembershipsTableTableManager(_db, _db.groupMemberships);
  $$ContactFrequencyOverridesTableTableManager get contactFrequencyOverrides =>
      $$ContactFrequencyOverridesTableTableManager(
          _db, _db.contactFrequencyOverrides);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$QuestItemsTableTableManager get questItems =>
      $$QuestItemsTableTableManager(_db, _db.questItems);
  $$NudgeLogsTableTableManager get nudgeLogs =>
      $$NudgeLogsTableTableManager(_db, _db.nudgeLogs);
  $$NotificationLedgersTableTableManager get notificationLedgers =>
      $$NotificationLedgersTableTableManager(_db, _db.notificationLedgers);
  $$SideQuestsTableTableManager get sideQuests =>
      $$SideQuestsTableTableManager(_db, _db.sideQuests);
  $$GlobalStreaksTableTableManager get globalStreaks =>
      $$GlobalStreaksTableTableManager(_db, _db.globalStreaks);
  $$MessageTemplatesTableTableManager get messageTemplates =>
      $$MessageTemplatesTableTableManager(_db, _db.messageTemplates);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
