// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlantsTable extends Plants with TableInfo<$PlantsTable, Plant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creationDateMeta = const VerificationMeta(
    'creationDate',
  );
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
    'creation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acquisitionDateMeta = const VerificationMeta(
    'acquisitionDate',
  );
  @override
  late final GeneratedColumn<DateTime> acquisitionDate =
      GeneratedColumn<DateTime>(
        'acquisition_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nickname,
    photoPath,
    creationDate,
    species,
    acquisitionDate,
    room,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('creation_date')) {
      context.handle(
        _creationDateMeta,
        creationDate.isAcceptableOrUnknown(
          data['creation_date']!,
          _creationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    }
    if (data.containsKey('acquisition_date')) {
      context.handle(
        _acquisitionDateMeta,
        acquisitionDate.isAcceptableOrUnknown(
          data['acquisition_date']!,
          _acquisitionDateMeta,
        ),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plant(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      creationDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}creation_date'],
          )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      ),
      acquisitionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquisition_date'],
      ),
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
    );
  }

  @override
  $PlantsTable createAlias(String alias) {
    return $PlantsTable(attachedDatabase, alias);
  }
}

class Plant extends DataClass implements Insertable<Plant> {
  final int id;
  final String name;
  final String? nickname;
  final String? photoPath;
  final DateTime creationDate;
  final String? species;
  final DateTime? acquisitionDate;
  final String? room;
  const Plant({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,
    required this.creationDate,
    this.species,
    this.acquisitionDate,
    this.room,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['creation_date'] = Variable<DateTime>(creationDate);
    if (!nullToAbsent || species != null) {
      map['species'] = Variable<String>(species);
    }
    if (!nullToAbsent || acquisitionDate != null) {
      map['acquisition_date'] = Variable<DateTime>(acquisitionDate);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    return map;
  }

  PlantsCompanion toCompanion(bool nullToAbsent) {
    return PlantsCompanion(
      id: Value(id),
      name: Value(name),
      nickname:
          nickname == null && nullToAbsent
              ? const Value.absent()
              : Value(nickname),
      photoPath:
          photoPath == null && nullToAbsent
              ? const Value.absent()
              : Value(photoPath),
      creationDate: Value(creationDate),
      species:
          species == null && nullToAbsent
              ? const Value.absent()
              : Value(species),
      acquisitionDate:
          acquisitionDate == null && nullToAbsent
              ? const Value.absent()
              : Value(acquisitionDate),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
    );
  }

  factory Plant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plant(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      species: serializer.fromJson<String?>(json['species']),
      acquisitionDate: serializer.fromJson<DateTime?>(json['acquisitionDate']),
      room: serializer.fromJson<String?>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'photoPath': serializer.toJson<String?>(photoPath),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'species': serializer.toJson<String?>(species),
      'acquisitionDate': serializer.toJson<DateTime?>(acquisitionDate),
      'room': serializer.toJson<String?>(room),
    };
  }

  Plant copyWith({
    int? id,
    String? name,
    Value<String?> nickname = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    DateTime? creationDate,
    Value<String?> species = const Value.absent(),
    Value<DateTime?> acquisitionDate = const Value.absent(),
    Value<String?> room = const Value.absent(),
  }) => Plant(
    id: id ?? this.id,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    creationDate: creationDate ?? this.creationDate,
    species: species.present ? species.value : this.species,
    acquisitionDate:
        acquisitionDate.present ? acquisitionDate.value : this.acquisitionDate,
    room: room.present ? room.value : this.room,
  );
  Plant copyWithCompanion(PlantsCompanion data) {
    return Plant(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      creationDate:
          data.creationDate.present
              ? data.creationDate.value
              : this.creationDate,
      species: data.species.present ? data.species.value : this.species,
      acquisitionDate:
          data.acquisitionDate.present
              ? data.acquisitionDate.value
              : this.acquisitionDate,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plant(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('creationDate: $creationDate, ')
          ..write('species: $species, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nickname,
    photoPath,
    creationDate,
    species,
    acquisitionDate,
    room,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plant &&
          other.id == this.id &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.photoPath == this.photoPath &&
          other.creationDate == this.creationDate &&
          other.species == this.species &&
          other.acquisitionDate == this.acquisitionDate &&
          other.room == this.room);
}

class PlantsCompanion extends UpdateCompanion<Plant> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String?> photoPath;
  final Value<DateTime> creationDate;
  final Value<String?> species;
  final Value<DateTime?> acquisitionDate;
  final Value<String?> room;
  const PlantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.species = const Value.absent(),
    this.acquisitionDate = const Value.absent(),
    this.room = const Value.absent(),
  });
  PlantsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    required DateTime creationDate,
    this.species = const Value.absent(),
    this.acquisitionDate = const Value.absent(),
    this.room = const Value.absent(),
  }) : name = Value(name),
       creationDate = Value(creationDate);
  static Insertable<Plant> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? photoPath,
    Expression<DateTime>? creationDate,
    Expression<String>? species,
    Expression<DateTime>? acquisitionDate,
    Expression<String>? room,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (photoPath != null) 'photo_path': photoPath,
      if (creationDate != null) 'creation_date': creationDate,
      if (species != null) 'species': species,
      if (acquisitionDate != null) 'acquisition_date': acquisitionDate,
      if (room != null) 'room': room,
    });
  }

  PlantsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String?>? photoPath,
    Value<DateTime>? creationDate,
    Value<String?>? species,
    Value<DateTime?>? acquisitionDate,
    Value<String?>? room,
  }) {
    return PlantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      creationDate: creationDate ?? this.creationDate,
      species: species ?? this.species,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      room: room ?? this.room,
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
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (acquisitionDate.present) {
      map['acquisition_date'] = Variable<DateTime>(acquisitionDate.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('creationDate: $creationDate, ')
          ..write('species: $species, ')
          ..write('acquisitionDate: $acquisitionDate, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }
}

class $PetsTable extends Pets with TableInfo<$PetsTable, Pet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creationDateMeta = const VerificationMeta(
    'creationDate',
  );
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
    'creation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Gender?, int> gender =
      GeneratedColumn<int>(
        'gender',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Gender?>($PetsTable.$convertergendern);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nickname,
    photoPath,
    creationDate,
    species,
    breed,
    birthDate,
    gender,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('creation_date')) {
      context.handle(
        _creationDateMeta,
        creationDate.isAcceptableOrUnknown(
          data['creation_date']!,
          _creationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pet(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      creationDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}creation_date'],
          )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      ),
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      gender: $PetsTable.$convertergendern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}gender'],
        ),
      ),
    );
  }

  @override
  $PetsTable createAlias(String alias) {
    return $PetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Gender, int, int> $convertergender =
      const EnumIndexConverter<Gender>(Gender.values);
  static JsonTypeConverter2<Gender?, int?, int?> $convertergendern =
      JsonTypeConverter2.asNullable($convertergender);
}

class Pet extends DataClass implements Insertable<Pet> {
  final int id;
  final String name;
  final String? nickname;
  final String? photoPath;
  final DateTime creationDate;
  final String? species;
  final String? breed;
  final DateTime? birthDate;
  final Gender? gender;
  const Pet({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,
    required this.creationDate,
    this.species,
    this.breed,
    this.birthDate,
    this.gender,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['creation_date'] = Variable<DateTime>(creationDate);
    if (!nullToAbsent || species != null) {
      map['species'] = Variable<String>(species);
    }
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<int>($PetsTable.$convertergendern.toSql(gender));
    }
    return map;
  }

  PetsCompanion toCompanion(bool nullToAbsent) {
    return PetsCompanion(
      id: Value(id),
      name: Value(name),
      nickname:
          nickname == null && nullToAbsent
              ? const Value.absent()
              : Value(nickname),
      photoPath:
          photoPath == null && nullToAbsent
              ? const Value.absent()
              : Value(photoPath),
      creationDate: Value(creationDate),
      species:
          species == null && nullToAbsent
              ? const Value.absent()
              : Value(species),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      birthDate:
          birthDate == null && nullToAbsent
              ? const Value.absent()
              : Value(birthDate),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
    );
  }

  factory Pet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      species: serializer.fromJson<String?>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      gender: $PetsTable.$convertergendern.fromJson(
        serializer.fromJson<int?>(json['gender']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'photoPath': serializer.toJson<String?>(photoPath),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'species': serializer.toJson<String?>(species),
      'breed': serializer.toJson<String?>(breed),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'gender': serializer.toJson<int?>(
        $PetsTable.$convertergendern.toJson(gender),
      ),
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    Value<String?> nickname = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    DateTime? creationDate,
    Value<String?> species = const Value.absent(),
    Value<String?> breed = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<Gender?> gender = const Value.absent(),
  }) => Pet(
    id: id ?? this.id,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    creationDate: creationDate ?? this.creationDate,
    species: species.present ? species.value : this.species,
    breed: breed.present ? breed.value : this.breed,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    gender: gender.present ? gender.value : this.gender,
  );
  Pet copyWithCompanion(PetsCompanion data) {
    return Pet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      creationDate:
          data.creationDate.present
              ? data.creationDate.value
              : this.creationDate,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      gender: data.gender.present ? data.gender.value : this.gender,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('creationDate: $creationDate, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nickname,
    photoPath,
    creationDate,
    species,
    breed,
    birthDate,
    gender,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pet &&
          other.id == this.id &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.photoPath == this.photoPath &&
          other.creationDate == this.creationDate &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.birthDate == this.birthDate &&
          other.gender == this.gender);
}

class PetsCompanion extends UpdateCompanion<Pet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String?> photoPath;
  final Value<DateTime> creationDate;
  final Value<String?> species;
  final Value<String?> breed;
  final Value<DateTime?> birthDate;
  final Value<Gender?> gender;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
  });
  PetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    required DateTime creationDate,
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.gender = const Value.absent(),
  }) : name = Value(name),
       creationDate = Value(creationDate);
  static Insertable<Pet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? photoPath,
    Expression<DateTime>? creationDate,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<DateTime>? birthDate,
    Expression<int>? gender,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (photoPath != null) 'photo_path': photoPath,
      if (creationDate != null) 'creation_date': creationDate,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender != null) 'gender': gender,
    });
  }

  PetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String?>? photoPath,
    Value<DateTime>? creationDate,
    Value<String?>? species,
    Value<String?>? breed,
    Value<DateTime?>? birthDate,
    Value<Gender?>? gender,
  }) {
    return PetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      creationDate: creationDate ?? this.creationDate,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
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
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (gender.present) {
      map['gender'] = Variable<int>(
        $PetsTable.$convertergendern.toSql(gender.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('creationDate: $creationDate, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('birthDate: $birthDate, ')
          ..write('gender: $gender')
          ..write(')'))
        .toString();
  }
}

class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<int> objectId = GeneratedColumn<int>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ObjectType, int> objectType =
      GeneratedColumn<int>(
        'object_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ObjectType>($LogEntriesTable.$converterobjectType);
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateTimeMeta = const VerificationMeta(
    'eventDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> eventDateTime =
      GeneratedColumn<DateTime>(
        'event_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathsMeta = const VerificationMeta(
    'photoPaths',
  );
  @override
  late final GeneratedColumn<String> photoPaths = GeneratedColumn<String>(
    'photo_paths',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creationDateMeta = const VerificationMeta(
    'creationDate',
  );
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
    'creation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    objectId,
    objectType,
    eventType,
    eventDateTime,
    notes,
    photoPaths,
    creationDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_date_time')) {
      context.handle(
        _eventDateTimeMeta,
        eventDateTime.isAcceptableOrUnknown(
          data['event_date_time']!,
          _eventDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventDateTimeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_paths')) {
      context.handle(
        _photoPathsMeta,
        photoPaths.isAcceptableOrUnknown(data['photo_paths']!, _photoPathsMeta),
      );
    }
    if (data.containsKey('creation_date')) {
      context.handle(
        _creationDateMeta,
        creationDate.isAcceptableOrUnknown(
          data['creation_date']!,
          _creationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      objectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}object_id'],
          )!,
      objectType: $LogEntriesTable.$converterobjectType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}object_type'],
        )!,
      ),
      eventType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}event_type'],
          )!,
      eventDateTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}event_date_time'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoPaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_paths'],
      ),
      creationDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}creation_date'],
          )!,
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ObjectType, int, int> $converterobjectType =
      const EnumIndexConverter<ObjectType>(ObjectType.values);
}

class LogEntry extends DataClass implements Insertable<LogEntry> {
  final int id;
  final int objectId;
  final ObjectType objectType;
  final String eventType;
  final DateTime eventDateTime;
  final String? notes;
  final String? photoPaths;
  final DateTime creationDate;
  const LogEntry({
    required this.id,
    required this.objectId,
    required this.objectType,
    required this.eventType,
    required this.eventDateTime,
    this.notes,
    this.photoPaths,
    required this.creationDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['object_id'] = Variable<int>(objectId);
    {
      map['object_type'] = Variable<int>(
        $LogEntriesTable.$converterobjectType.toSql(objectType),
      );
    }
    map['event_type'] = Variable<String>(eventType);
    map['event_date_time'] = Variable<DateTime>(eventDateTime);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPaths != null) {
      map['photo_paths'] = Variable<String>(photoPaths);
    }
    map['creation_date'] = Variable<DateTime>(creationDate);
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      objectId: Value(objectId),
      objectType: Value(objectType),
      eventType: Value(eventType),
      eventDateTime: Value(eventDateTime),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      photoPaths:
          photoPaths == null && nullToAbsent
              ? const Value.absent()
              : Value(photoPaths),
      creationDate: Value(creationDate),
    );
  }

  factory LogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntry(
      id: serializer.fromJson<int>(json['id']),
      objectId: serializer.fromJson<int>(json['objectId']),
      objectType: $LogEntriesTable.$converterobjectType.fromJson(
        serializer.fromJson<int>(json['objectType']),
      ),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDateTime: serializer.fromJson<DateTime>(json['eventDateTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPaths: serializer.fromJson<String?>(json['photoPaths']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'objectId': serializer.toJson<int>(objectId),
      'objectType': serializer.toJson<int>(
        $LogEntriesTable.$converterobjectType.toJson(objectType),
      ),
      'eventType': serializer.toJson<String>(eventType),
      'eventDateTime': serializer.toJson<DateTime>(eventDateTime),
      'notes': serializer.toJson<String?>(notes),
      'photoPaths': serializer.toJson<String?>(photoPaths),
      'creationDate': serializer.toJson<DateTime>(creationDate),
    };
  }

  LogEntry copyWith({
    int? id,
    int? objectId,
    ObjectType? objectType,
    String? eventType,
    DateTime? eventDateTime,
    Value<String?> notes = const Value.absent(),
    Value<String?> photoPaths = const Value.absent(),
    DateTime? creationDate,
  }) => LogEntry(
    id: id ?? this.id,
    objectId: objectId ?? this.objectId,
    objectType: objectType ?? this.objectType,
    eventType: eventType ?? this.eventType,
    eventDateTime: eventDateTime ?? this.eventDateTime,
    notes: notes.present ? notes.value : this.notes,
    photoPaths: photoPaths.present ? photoPaths.value : this.photoPaths,
    creationDate: creationDate ?? this.creationDate,
  );
  LogEntry copyWithCompanion(LogEntriesCompanion data) {
    return LogEntry(
      id: data.id.present ? data.id.value : this.id,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      objectType:
          data.objectType.present ? data.objectType.value : this.objectType,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDateTime:
          data.eventDateTime.present
              ? data.eventDateTime.value
              : this.eventDateTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPaths:
          data.photoPaths.present ? data.photoPaths.value : this.photoPaths,
      creationDate:
          data.creationDate.present
              ? data.creationDate.value
              : this.creationDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntry(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('objectType: $objectType, ')
          ..write('eventType: $eventType, ')
          ..write('eventDateTime: $eventDateTime, ')
          ..write('notes: $notes, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('creationDate: $creationDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    objectId,
    objectType,
    eventType,
    eventDateTime,
    notes,
    photoPaths,
    creationDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntry &&
          other.id == this.id &&
          other.objectId == this.objectId &&
          other.objectType == this.objectType &&
          other.eventType == this.eventType &&
          other.eventDateTime == this.eventDateTime &&
          other.notes == this.notes &&
          other.photoPaths == this.photoPaths &&
          other.creationDate == this.creationDate);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntry> {
  final Value<int> id;
  final Value<int> objectId;
  final Value<ObjectType> objectType;
  final Value<String> eventType;
  final Value<DateTime> eventDateTime;
  final Value<String?> notes;
  final Value<String?> photoPaths;
  final Value<DateTime> creationDate;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.objectId = const Value.absent(),
    this.objectType = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDateTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPaths = const Value.absent(),
    this.creationDate = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int objectId,
    required ObjectType objectType,
    required String eventType,
    required DateTime eventDateTime,
    this.notes = const Value.absent(),
    this.photoPaths = const Value.absent(),
    required DateTime creationDate,
  }) : objectId = Value(objectId),
       objectType = Value(objectType),
       eventType = Value(eventType),
       eventDateTime = Value(eventDateTime),
       creationDate = Value(creationDate);
  static Insertable<LogEntry> custom({
    Expression<int>? id,
    Expression<int>? objectId,
    Expression<int>? objectType,
    Expression<String>? eventType,
    Expression<DateTime>? eventDateTime,
    Expression<String>? notes,
    Expression<String>? photoPaths,
    Expression<DateTime>? creationDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (objectId != null) 'object_id': objectId,
      if (objectType != null) 'object_type': objectType,
      if (eventType != null) 'event_type': eventType,
      if (eventDateTime != null) 'event_date_time': eventDateTime,
      if (notes != null) 'notes': notes,
      if (photoPaths != null) 'photo_paths': photoPaths,
      if (creationDate != null) 'creation_date': creationDate,
    });
  }

  LogEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? objectId,
    Value<ObjectType>? objectType,
    Value<String>? eventType,
    Value<DateTime>? eventDateTime,
    Value<String?>? notes,
    Value<String?>? photoPaths,
    Value<DateTime>? creationDate,
  }) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      objectId: objectId ?? this.objectId,
      objectType: objectType ?? this.objectType,
      eventType: eventType ?? this.eventType,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<int>(objectId.value);
    }
    if (objectType.present) {
      map['object_type'] = Variable<int>(
        $LogEntriesTable.$converterobjectType.toSql(objectType.value),
      );
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDateTime.present) {
      map['event_date_time'] = Variable<DateTime>(eventDateTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPaths.present) {
      map['photo_paths'] = Variable<String>(photoPaths.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('objectType: $objectType, ')
          ..write('eventType: $eventType, ')
          ..write('eventDateTime: $eventDateTime, ')
          ..write('notes: $notes, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('creationDate: $creationDate')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<int> objectId = GeneratedColumn<int>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ObjectType, int> objectType =
      GeneratedColumn<int>(
        'object_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ObjectType>($RemindersTable.$converterobjectType);
  static const VerificationMeta _taskNameMeta = const VerificationMeta(
    'taskName',
  );
  @override
  late final GeneratedColumn<String> taskName = GeneratedColumn<String>(
    'task_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyRuleMeta = const VerificationMeta(
    'frequencyRule',
  );
  @override
  late final GeneratedColumn<String> frequencyRule = GeneratedColumn<String>(
    'frequency_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _creationDateMeta = const VerificationMeta(
    'creationDate',
  );
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
    'creation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    objectId,
    objectType,
    taskName,
    frequencyRule,
    nextDueDate,
    notes,
    isActive,
    creationDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('task_name')) {
      context.handle(
        _taskNameMeta,
        taskName.isAcceptableOrUnknown(data['task_name']!, _taskNameMeta),
      );
    } else if (isInserting) {
      context.missing(_taskNameMeta);
    }
    if (data.containsKey('frequency_rule')) {
      context.handle(
        _frequencyRuleMeta,
        frequencyRule.isAcceptableOrUnknown(
          data['frequency_rule']!,
          _frequencyRuleMeta,
        ),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('creation_date')) {
      context.handle(
        _creationDateMeta,
        creationDate.isAcceptableOrUnknown(
          data['creation_date']!,
          _creationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      objectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}object_id'],
          )!,
      objectType: $RemindersTable.$converterobjectType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}object_type'],
        )!,
      ),
      taskName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}task_name'],
          )!,
      frequencyRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_rule'],
      ),
      nextDueDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}next_due_date'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
      creationDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}creation_date'],
          )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ObjectType, int, int> $converterobjectType =
      const EnumIndexConverter<ObjectType>(ObjectType.values);
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int objectId;
  final ObjectType objectType;
  final String taskName;
  final String? frequencyRule;
  final DateTime nextDueDate;
  final String? notes;
  final bool isActive;
  final DateTime creationDate;
  const Reminder({
    required this.id,
    required this.objectId,
    required this.objectType,
    required this.taskName,
    this.frequencyRule,
    required this.nextDueDate,
    this.notes,
    required this.isActive,
    required this.creationDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['object_id'] = Variable<int>(objectId);
    {
      map['object_type'] = Variable<int>(
        $RemindersTable.$converterobjectType.toSql(objectType),
      );
    }
    map['task_name'] = Variable<String>(taskName);
    if (!nullToAbsent || frequencyRule != null) {
      map['frequency_rule'] = Variable<String>(frequencyRule);
    }
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['creation_date'] = Variable<DateTime>(creationDate);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      objectId: Value(objectId),
      objectType: Value(objectType),
      taskName: Value(taskName),
      frequencyRule:
          frequencyRule == null && nullToAbsent
              ? const Value.absent()
              : Value(frequencyRule),
      nextDueDate: Value(nextDueDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isActive: Value(isActive),
      creationDate: Value(creationDate),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      objectId: serializer.fromJson<int>(json['objectId']),
      objectType: $RemindersTable.$converterobjectType.fromJson(
        serializer.fromJson<int>(json['objectType']),
      ),
      taskName: serializer.fromJson<String>(json['taskName']),
      frequencyRule: serializer.fromJson<String?>(json['frequencyRule']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'objectId': serializer.toJson<int>(objectId),
      'objectType': serializer.toJson<int>(
        $RemindersTable.$converterobjectType.toJson(objectType),
      ),
      'taskName': serializer.toJson<String>(taskName),
      'frequencyRule': serializer.toJson<String?>(frequencyRule),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'creationDate': serializer.toJson<DateTime>(creationDate),
    };
  }

  Reminder copyWith({
    int? id,
    int? objectId,
    ObjectType? objectType,
    String? taskName,
    Value<String?> frequencyRule = const Value.absent(),
    DateTime? nextDueDate,
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    DateTime? creationDate,
  }) => Reminder(
    id: id ?? this.id,
    objectId: objectId ?? this.objectId,
    objectType: objectType ?? this.objectType,
    taskName: taskName ?? this.taskName,
    frequencyRule:
        frequencyRule.present ? frequencyRule.value : this.frequencyRule,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    creationDate: creationDate ?? this.creationDate,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      objectType:
          data.objectType.present ? data.objectType.value : this.objectType,
      taskName: data.taskName.present ? data.taskName.value : this.taskName,
      frequencyRule:
          data.frequencyRule.present
              ? data.frequencyRule.value
              : this.frequencyRule,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      creationDate:
          data.creationDate.present
              ? data.creationDate.value
              : this.creationDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('objectType: $objectType, ')
          ..write('taskName: $taskName, ')
          ..write('frequencyRule: $frequencyRule, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('creationDate: $creationDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    objectId,
    objectType,
    taskName,
    frequencyRule,
    nextDueDate,
    notes,
    isActive,
    creationDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.objectId == this.objectId &&
          other.objectType == this.objectType &&
          other.taskName == this.taskName &&
          other.frequencyRule == this.frequencyRule &&
          other.nextDueDate == this.nextDueDate &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.creationDate == this.creationDate);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> objectId;
  final Value<ObjectType> objectType;
  final Value<String> taskName;
  final Value<String?> frequencyRule;
  final Value<DateTime> nextDueDate;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> creationDate;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.objectId = const Value.absent(),
    this.objectType = const Value.absent(),
    this.taskName = const Value.absent(),
    this.frequencyRule = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.creationDate = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int objectId,
    required ObjectType objectType,
    required String taskName,
    this.frequencyRule = const Value.absent(),
    required DateTime nextDueDate,
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime creationDate,
  }) : objectId = Value(objectId),
       objectType = Value(objectType),
       taskName = Value(taskName),
       nextDueDate = Value(nextDueDate),
       creationDate = Value(creationDate);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? objectId,
    Expression<int>? objectType,
    Expression<String>? taskName,
    Expression<String>? frequencyRule,
    Expression<DateTime>? nextDueDate,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? creationDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (objectId != null) 'object_id': objectId,
      if (objectType != null) 'object_type': objectType,
      if (taskName != null) 'task_name': taskName,
      if (frequencyRule != null) 'frequency_rule': frequencyRule,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (creationDate != null) 'creation_date': creationDate,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? objectId,
    Value<ObjectType>? objectType,
    Value<String>? taskName,
    Value<String?>? frequencyRule,
    Value<DateTime>? nextDueDate,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<DateTime>? creationDate,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      objectId: objectId ?? this.objectId,
      objectType: objectType ?? this.objectType,
      taskName: taskName ?? this.taskName,
      frequencyRule: frequencyRule ?? this.frequencyRule,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<int>(objectId.value);
    }
    if (objectType.present) {
      map['object_type'] = Variable<int>(
        $RemindersTable.$converterobjectType.toSql(objectType.value),
      );
    }
    if (taskName.present) {
      map['task_name'] = Variable<String>(taskName.value);
    }
    if (frequencyRule.present) {
      map['frequency_rule'] = Variable<String>(frequencyRule.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('objectId: $objectId, ')
          ..write('objectType: $objectType, ')
          ..write('taskName: $taskName, ')
          ..write('frequencyRule: $frequencyRule, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('creationDate: $creationDate')
          ..write(')'))
        .toString();
  }
}

class $CustomEventTypesTable extends CustomEventTypes
    with TableInfo<$CustomEventTypesTable, CustomEventType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomEventTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _iconCodepointMeta = const VerificationMeta(
    'iconCodepoint',
  );
  @override
  late final GeneratedColumn<int> iconCodepoint = GeneratedColumn<int>(
    'icon_codepoint',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconFontFamilyMeta = const VerificationMeta(
    'iconFontFamily',
  );
  @override
  late final GeneratedColumn<String> iconFontFamily = GeneratedColumn<String>(
    'icon_font_family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconCodepoint,
    iconFontFamily,
    isPreset,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_event_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomEventType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_codepoint')) {
      context.handle(
        _iconCodepointMeta,
        iconCodepoint.isAcceptableOrUnknown(
          data['icon_codepoint']!,
          _iconCodepointMeta,
        ),
      );
    }
    if (data.containsKey('icon_font_family')) {
      context.handle(
        _iconFontFamilyMeta,
        iconFontFamily.isAcceptableOrUnknown(
          data['icon_font_family']!,
          _iconFontFamilyMeta,
        ),
      );
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomEventType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomEventType(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      iconCodepoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_codepoint'],
      ),
      iconFontFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_font_family'],
      ),
      isPreset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_preset'],
          )!,
    );
  }

  @override
  $CustomEventTypesTable createAlias(String alias) {
    return $CustomEventTypesTable(attachedDatabase, alias);
  }
}

class CustomEventType extends DataClass implements Insertable<CustomEventType> {
  final int id;
  final String name;
  final int? iconCodepoint;
  final String? iconFontFamily;
  final bool isPreset;
  const CustomEventType({
    required this.id,
    required this.name,
    this.iconCodepoint,
    this.iconFontFamily,
    required this.isPreset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconCodepoint != null) {
      map['icon_codepoint'] = Variable<int>(iconCodepoint);
    }
    if (!nullToAbsent || iconFontFamily != null) {
      map['icon_font_family'] = Variable<String>(iconFontFamily);
    }
    map['is_preset'] = Variable<bool>(isPreset);
    return map;
  }

  CustomEventTypesCompanion toCompanion(bool nullToAbsent) {
    return CustomEventTypesCompanion(
      id: Value(id),
      name: Value(name),
      iconCodepoint:
          iconCodepoint == null && nullToAbsent
              ? const Value.absent()
              : Value(iconCodepoint),
      iconFontFamily:
          iconFontFamily == null && nullToAbsent
              ? const Value.absent()
              : Value(iconFontFamily),
      isPreset: Value(isPreset),
    );
  }

  factory CustomEventType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomEventType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCodepoint: serializer.fromJson<int?>(json['iconCodepoint']),
      iconFontFamily: serializer.fromJson<String?>(json['iconFontFamily']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconCodepoint': serializer.toJson<int?>(iconCodepoint),
      'iconFontFamily': serializer.toJson<String?>(iconFontFamily),
      'isPreset': serializer.toJson<bool>(isPreset),
    };
  }

  CustomEventType copyWith({
    int? id,
    String? name,
    Value<int?> iconCodepoint = const Value.absent(),
    Value<String?> iconFontFamily = const Value.absent(),
    bool? isPreset,
  }) => CustomEventType(
    id: id ?? this.id,
    name: name ?? this.name,
    iconCodepoint:
        iconCodepoint.present ? iconCodepoint.value : this.iconCodepoint,
    iconFontFamily:
        iconFontFamily.present ? iconFontFamily.value : this.iconFontFamily,
    isPreset: isPreset ?? this.isPreset,
  );
  CustomEventType copyWithCompanion(CustomEventTypesCompanion data) {
    return CustomEventType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCodepoint:
          data.iconCodepoint.present
              ? data.iconCodepoint.value
              : this.iconCodepoint,
      iconFontFamily:
          data.iconFontFamily.present
              ? data.iconFontFamily.value
              : this.iconFontFamily,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomEventType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodepoint: $iconCodepoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('isPreset: $isPreset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconCodepoint, iconFontFamily, isPreset);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomEventType &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCodepoint == this.iconCodepoint &&
          other.iconFontFamily == this.iconFontFamily &&
          other.isPreset == this.isPreset);
}

class CustomEventTypesCompanion extends UpdateCompanion<CustomEventType> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> iconCodepoint;
  final Value<String?> iconFontFamily;
  final Value<bool> isPreset;
  const CustomEventTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCodepoint = const Value.absent(),
    this.iconFontFamily = const Value.absent(),
    this.isPreset = const Value.absent(),
  });
  CustomEventTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iconCodepoint = const Value.absent(),
    this.iconFontFamily = const Value.absent(),
    this.isPreset = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CustomEventType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? iconCodepoint,
    Expression<String>? iconFontFamily,
    Expression<bool>? isPreset,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCodepoint != null) 'icon_codepoint': iconCodepoint,
      if (iconFontFamily != null) 'icon_font_family': iconFontFamily,
      if (isPreset != null) 'is_preset': isPreset,
    });
  }

  CustomEventTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? iconCodepoint,
    Value<String?>? iconFontFamily,
    Value<bool>? isPreset,
  }) {
    return CustomEventTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodepoint: iconCodepoint ?? this.iconCodepoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      isPreset: isPreset ?? this.isPreset,
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
    if (iconCodepoint.present) {
      map['icon_codepoint'] = Variable<int>(iconCodepoint.value);
    }
    if (iconFontFamily.present) {
      map['icon_font_family'] = Variable<String>(iconFontFamily.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomEventTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodepoint: $iconCodepoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('isPreset: $isPreset')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlantsTable plants = $PlantsTable(this);
  late final $PetsTable pets = $PetsTable(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $CustomEventTypesTable customEventTypes = $CustomEventTypesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    plants,
    pets,
    logEntries,
    reminders,
    customEventTypes,
  ];
}

typedef $$PlantsTableCreateCompanionBuilder =
    PlantsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> nickname,
      Value<String?> photoPath,
      required DateTime creationDate,
      Value<String?> species,
      Value<DateTime?> acquisitionDate,
      Value<String?> room,
    });
typedef $$PlantsTableUpdateCompanionBuilder =
    PlantsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> nickname,
      Value<String?> photoPath,
      Value<DateTime> creationDate,
      Value<String?> species,
      Value<DateTime?> acquisitionDate,
      Value<String?> room,
    });

class $$PlantsTableFilterComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquisitionDate => $composableBuilder(
    column: $table.acquisitionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlantsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquisitionDate => $composableBuilder(
    column: $table.acquisitionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantsTable> {
  $$PlantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<DateTime> get acquisitionDate => $composableBuilder(
    column: $table.acquisitionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);
}

class $$PlantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantsTable,
          Plant,
          $$PlantsTableFilterComposer,
          $$PlantsTableOrderingComposer,
          $$PlantsTableAnnotationComposer,
          $$PlantsTableCreateCompanionBuilder,
          $$PlantsTableUpdateCompanionBuilder,
          (Plant, BaseReferences<_$AppDatabase, $PlantsTable, Plant>),
          Plant,
          PrefetchHooks Function()
        > {
  $$PlantsTableTableManager(_$AppDatabase db, $PlantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PlantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PlantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PlantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> creationDate = const Value.absent(),
                Value<String?> species = const Value.absent(),
                Value<DateTime?> acquisitionDate = const Value.absent(),
                Value<String?> room = const Value.absent(),
              }) => PlantsCompanion(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                creationDate: creationDate,
                species: species,
                acquisitionDate: acquisitionDate,
                room: room,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required DateTime creationDate,
                Value<String?> species = const Value.absent(),
                Value<DateTime?> acquisitionDate = const Value.absent(),
                Value<String?> room = const Value.absent(),
              }) => PlantsCompanion.insert(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                creationDate: creationDate,
                species: species,
                acquisitionDate: acquisitionDate,
                room: room,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantsTable,
      Plant,
      $$PlantsTableFilterComposer,
      $$PlantsTableOrderingComposer,
      $$PlantsTableAnnotationComposer,
      $$PlantsTableCreateCompanionBuilder,
      $$PlantsTableUpdateCompanionBuilder,
      (Plant, BaseReferences<_$AppDatabase, $PlantsTable, Plant>),
      Plant,
      PrefetchHooks Function()
    >;
typedef $$PetsTableCreateCompanionBuilder =
    PetsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> nickname,
      Value<String?> photoPath,
      required DateTime creationDate,
      Value<String?> species,
      Value<String?> breed,
      Value<DateTime?> birthDate,
      Value<Gender?> gender,
    });
typedef $$PetsTableUpdateCompanionBuilder =
    PetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> nickname,
      Value<String?> photoPath,
      Value<DateTime> creationDate,
      Value<String?> species,
      Value<String?> breed,
      Value<DateTime?> birthDate,
      Value<Gender?> gender,
    });

class $$PetsTableFilterComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Gender?, Gender, int> get gender =>
      $composableBuilder(
        column: $table.gender,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$PetsTableOrderingComposer extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PetsTable> {
  $$PetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Gender?, int> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);
}

class $$PetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PetsTable,
          Pet,
          $$PetsTableFilterComposer,
          $$PetsTableOrderingComposer,
          $$PetsTableAnnotationComposer,
          $$PetsTableCreateCompanionBuilder,
          $$PetsTableUpdateCompanionBuilder,
          (Pet, BaseReferences<_$AppDatabase, $PetsTable, Pet>),
          Pet,
          PrefetchHooks Function()
        > {
  $$PetsTableTableManager(_$AppDatabase db, $PetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> creationDate = const Value.absent(),
                Value<String?> species = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<Gender?> gender = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                creationDate: creationDate,
                species: species,
                breed: breed,
                birthDate: birthDate,
                gender: gender,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required DateTime creationDate,
                Value<String?> species = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<Gender?> gender = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                creationDate: creationDate,
                species: species,
                breed: breed,
                birthDate: birthDate,
                gender: gender,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PetsTable,
      Pet,
      $$PetsTableFilterComposer,
      $$PetsTableOrderingComposer,
      $$PetsTableAnnotationComposer,
      $$PetsTableCreateCompanionBuilder,
      $$PetsTableUpdateCompanionBuilder,
      (Pet, BaseReferences<_$AppDatabase, $PetsTable, Pet>),
      Pet,
      PrefetchHooks Function()
    >;
typedef $$LogEntriesTableCreateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<int> id,
      required int objectId,
      required ObjectType objectType,
      required String eventType,
      required DateTime eventDateTime,
      Value<String?> notes,
      Value<String?> photoPaths,
      required DateTime creationDate,
    });
typedef $$LogEntriesTableUpdateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<int> id,
      Value<int> objectId,
      Value<ObjectType> objectType,
      Value<String> eventType,
      Value<DateTime> eventDateTime,
      Value<String?> notes,
      Value<String?> photoPaths,
      Value<DateTime> creationDate,
    });

class $$LogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ObjectType, ObjectType, int> get objectType =>
      $composableBuilder(
        column: $table.objectType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDateTime => $composableBuilder(
    column: $table.eventDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPaths => $composableBuilder(
    column: $table.photoPaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get objectType => $composableBuilder(
    column: $table.objectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDateTime => $composableBuilder(
    column: $table.eventDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPaths => $composableBuilder(
    column: $table.photoPaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ObjectType, int> get objectType =>
      $composableBuilder(
        column: $table.objectType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDateTime => $composableBuilder(
    column: $table.eventDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPaths => $composableBuilder(
    column: $table.photoPaths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => column,
  );
}

class $$LogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogEntriesTable,
          LogEntry,
          $$LogEntriesTableFilterComposer,
          $$LogEntriesTableOrderingComposer,
          $$LogEntriesTableAnnotationComposer,
          $$LogEntriesTableCreateCompanionBuilder,
          $$LogEntriesTableUpdateCompanionBuilder,
          (LogEntry, BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntry>),
          LogEntry,
          PrefetchHooks Function()
        > {
  $$LogEntriesTableTableManager(_$AppDatabase db, $LogEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> objectId = const Value.absent(),
                Value<ObjectType> objectType = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> eventDateTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPaths = const Value.absent(),
                Value<DateTime> creationDate = const Value.absent(),
              }) => LogEntriesCompanion(
                id: id,
                objectId: objectId,
                objectType: objectType,
                eventType: eventType,
                eventDateTime: eventDateTime,
                notes: notes,
                photoPaths: photoPaths,
                creationDate: creationDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int objectId,
                required ObjectType objectType,
                required String eventType,
                required DateTime eventDateTime,
                Value<String?> notes = const Value.absent(),
                Value<String?> photoPaths = const Value.absent(),
                required DateTime creationDate,
              }) => LogEntriesCompanion.insert(
                id: id,
                objectId: objectId,
                objectType: objectType,
                eventType: eventType,
                eventDateTime: eventDateTime,
                notes: notes,
                photoPaths: photoPaths,
                creationDate: creationDate,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogEntriesTable,
      LogEntry,
      $$LogEntriesTableFilterComposer,
      $$LogEntriesTableOrderingComposer,
      $$LogEntriesTableAnnotationComposer,
      $$LogEntriesTableCreateCompanionBuilder,
      $$LogEntriesTableUpdateCompanionBuilder,
      (LogEntry, BaseReferences<_$AppDatabase, $LogEntriesTable, LogEntry>),
      LogEntry,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int objectId,
      required ObjectType objectType,
      required String taskName,
      Value<String?> frequencyRule,
      required DateTime nextDueDate,
      Value<String?> notes,
      Value<bool> isActive,
      required DateTime creationDate,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> objectId,
      Value<ObjectType> objectType,
      Value<String> taskName,
      Value<String?> frequencyRule,
      Value<DateTime> nextDueDate,
      Value<String?> notes,
      Value<bool> isActive,
      Value<DateTime> creationDate,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ObjectType, ObjectType, int> get objectType =>
      $composableBuilder(
        column: $table.objectType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get taskName => $composableBuilder(
    column: $table.taskName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyRule => $composableBuilder(
    column: $table.frequencyRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get objectType => $composableBuilder(
    column: $table.objectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskName => $composableBuilder(
    column: $table.taskName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyRule => $composableBuilder(
    column: $table.frequencyRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ObjectType, int> get objectType =>
      $composableBuilder(
        column: $table.objectType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get taskName =>
      $composableBuilder(column: $table.taskName, builder: (column) => column);

  GeneratedColumn<String> get frequencyRule => $composableBuilder(
    column: $table.frequencyRule,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => column,
  );
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> objectId = const Value.absent(),
                Value<ObjectType> objectType = const Value.absent(),
                Value<String> taskName = const Value.absent(),
                Value<String?> frequencyRule = const Value.absent(),
                Value<DateTime> nextDueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> creationDate = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                objectId: objectId,
                objectType: objectType,
                taskName: taskName,
                frequencyRule: frequencyRule,
                nextDueDate: nextDueDate,
                notes: notes,
                isActive: isActive,
                creationDate: creationDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int objectId,
                required ObjectType objectType,
                required String taskName,
                Value<String?> frequencyRule = const Value.absent(),
                required DateTime nextDueDate,
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime creationDate,
              }) => RemindersCompanion.insert(
                id: id,
                objectId: objectId,
                objectType: objectType,
                taskName: taskName,
                frequencyRule: frequencyRule,
                nextDueDate: nextDueDate,
                notes: notes,
                isActive: isActive,
                creationDate: creationDate,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;
typedef $$CustomEventTypesTableCreateCompanionBuilder =
    CustomEventTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> iconCodepoint,
      Value<String?> iconFontFamily,
      Value<bool> isPreset,
    });
typedef $$CustomEventTypesTableUpdateCompanionBuilder =
    CustomEventTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> iconCodepoint,
      Value<String?> iconFontFamily,
      Value<bool> isPreset,
    });

class $$CustomEventTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomEventTypesTable> {
  $$CustomEventTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconFontFamily => $composableBuilder(
    column: $table.iconFontFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomEventTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomEventTypesTable> {
  $$CustomEventTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconFontFamily => $composableBuilder(
    column: $table.iconFontFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomEventTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomEventTypesTable> {
  $$CustomEventTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodepoint => $composableBuilder(
    column: $table.iconCodepoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconFontFamily => $composableBuilder(
    column: $table.iconFontFamily,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);
}

class $$CustomEventTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomEventTypesTable,
          CustomEventType,
          $$CustomEventTypesTableFilterComposer,
          $$CustomEventTypesTableOrderingComposer,
          $$CustomEventTypesTableAnnotationComposer,
          $$CustomEventTypesTableCreateCompanionBuilder,
          $$CustomEventTypesTableUpdateCompanionBuilder,
          (
            CustomEventType,
            BaseReferences<
              _$AppDatabase,
              $CustomEventTypesTable,
              CustomEventType
            >,
          ),
          CustomEventType,
          PrefetchHooks Function()
        > {
  $$CustomEventTypesTableTableManager(
    _$AppDatabase db,
    $CustomEventTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CustomEventTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CustomEventTypesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CustomEventTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> iconCodepoint = const Value.absent(),
                Value<String?> iconFontFamily = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
              }) => CustomEventTypesCompanion(
                id: id,
                name: name,
                iconCodepoint: iconCodepoint,
                iconFontFamily: iconFontFamily,
                isPreset: isPreset,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> iconCodepoint = const Value.absent(),
                Value<String?> iconFontFamily = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
              }) => CustomEventTypesCompanion.insert(
                id: id,
                name: name,
                iconCodepoint: iconCodepoint,
                iconFontFamily: iconFontFamily,
                isPreset: isPreset,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomEventTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomEventTypesTable,
      CustomEventType,
      $$CustomEventTypesTableFilterComposer,
      $$CustomEventTypesTableOrderingComposer,
      $$CustomEventTypesTableAnnotationComposer,
      $$CustomEventTypesTableCreateCompanionBuilder,
      $$CustomEventTypesTableUpdateCompanionBuilder,
      (
        CustomEventType,
        BaseReferences<_$AppDatabase, $CustomEventTypesTable, CustomEventType>,
      ),
      CustomEventType,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlantsTableTableManager get plants =>
      $$PlantsTableTableManager(_db, _db.plants);
  $$PetsTableTableManager get pets => $$PetsTableTableManager(_db, _db.pets);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$CustomEventTypesTableTableManager get customEventTypes =>
      $$CustomEventTypesTableTableManager(_db, _db.customEventTypes);
}
