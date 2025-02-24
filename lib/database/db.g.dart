// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $PlatformsTable extends Platforms
    with TableInfo<$PlatformsTable, PlatformEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatformsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _networkMeta =
      const VerificationMeta('network');
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
      'network', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [reference, latitude, longitude, status, model, network, isFavorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'platforms';
  @override
  VerificationContext validateIntegrity(Insertable<PlatformEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('network')) {
      context.handle(_networkMeta,
          network.isAcceptableOrUnknown(data['network']!, _networkMeta));
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PlatformEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlatformEntity(
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      network: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}network'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
    );
  }

  @override
  $PlatformsTable createAlias(String alias) {
    return $PlatformsTable(attachedDatabase, alias);
  }
}

class PlatformEntity extends DataClass implements Insertable<PlatformEntity> {
  final String reference;
  final double latitude;
  final double longitude;
  final String status;
  final String model;
  final String network;
  final bool isFavorite;
  const PlatformEntity(
      {required this.reference,
      required this.latitude,
      required this.longitude,
      required this.status,
      required this.model,
      required this.network,
      required this.isFavorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reference'] = Variable<String>(reference);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['status'] = Variable<String>(status);
    map['model'] = Variable<String>(model);
    map['network'] = Variable<String>(network);
    map['is_favorite'] = Variable<bool>(isFavorite);
    return map;
  }

  PlatformsCompanion toCompanion(bool nullToAbsent) {
    return PlatformsCompanion(
      reference: Value(reference),
      latitude: Value(latitude),
      longitude: Value(longitude),
      status: Value(status),
      model: Value(model),
      network: Value(network),
      isFavorite: Value(isFavorite),
    );
  }

  factory PlatformEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlatformEntity(
      reference: serializer.fromJson<String>(json['reference']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      status: serializer.fromJson<String>(json['status']),
      model: serializer.fromJson<String>(json['model']),
      network: serializer.fromJson<String>(json['network']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reference': serializer.toJson<String>(reference),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'status': serializer.toJson<String>(status),
      'model': serializer.toJson<String>(model),
      'network': serializer.toJson<String>(network),
      'isFavorite': serializer.toJson<bool>(isFavorite),
    };
  }

  PlatformEntity copyWith(
          {String? reference,
          double? latitude,
          double? longitude,
          String? status,
          String? model,
          String? network,
          bool? isFavorite}) =>
      PlatformEntity(
        reference: reference ?? this.reference,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        status: status ?? this.status,
        model: model ?? this.model,
        network: network ?? this.network,
        isFavorite: isFavorite ?? this.isFavorite,
      );
  PlatformEntity copyWithCompanion(PlatformsCompanion data) {
    return PlatformEntity(
      reference: data.reference.present ? data.reference.value : this.reference,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      status: data.status.present ? data.status.value : this.status,
      model: data.model.present ? data.model.value : this.model,
      network: data.network.present ? data.network.value : this.network,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlatformEntity(')
          ..write('reference: $reference, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('model: $model, ')
          ..write('network: $network, ')
          ..write('isFavorite: $isFavorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      reference, latitude, longitude, status, model, network, isFavorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlatformEntity &&
          other.reference == this.reference &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.status == this.status &&
          other.model == this.model &&
          other.network == this.network &&
          other.isFavorite == this.isFavorite);
}

class PlatformsCompanion extends UpdateCompanion<PlatformEntity> {
  final Value<String> reference;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> status;
  final Value<String> model;
  final Value<String> network;
  final Value<bool> isFavorite;
  final Value<int> rowid;
  const PlatformsCompanion({
    this.reference = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.status = const Value.absent(),
    this.model = const Value.absent(),
    this.network = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlatformsCompanion.insert({
    required String reference,
    required double latitude,
    required double longitude,
    required String status,
    required String model,
    required String network,
    this.isFavorite = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : reference = Value(reference),
        latitude = Value(latitude),
        longitude = Value(longitude),
        status = Value(status),
        model = Value(model),
        network = Value(network);
  static Insertable<PlatformEntity> custom({
    Expression<String>? reference,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? status,
    Expression<String>? model,
    Expression<String>? network,
    Expression<bool>? isFavorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reference != null) 'reference': reference,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (status != null) 'status': status,
      if (model != null) 'model': model,
      if (network != null) 'network': network,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlatformsCompanion copyWith(
      {Value<String>? reference,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String>? status,
      Value<String>? model,
      Value<String>? network,
      Value<bool>? isFavorite,
      Value<int>? rowid}) {
    return PlatformsCompanion(
      reference: reference ?? this.reference,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      model: model ?? this.model,
      network: network ?? this.network,
      isFavorite: isFavorite ?? this.isFavorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatformsCompanion(')
          ..write('reference: $reference, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('status: $status, ')
          ..write('model: $model, ')
          ..write('network: $network, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlatformsTable platforms = $PlatformsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [platforms];
}

typedef $$PlatformsTableCreateCompanionBuilder = PlatformsCompanion Function({
  required String reference,
  required double latitude,
  required double longitude,
  required String status,
  required String model,
  required String network,
  Value<bool> isFavorite,
  Value<int> rowid,
});
typedef $$PlatformsTableUpdateCompanionBuilder = PlatformsCompanion Function({
  Value<String> reference,
  Value<double> latitude,
  Value<double> longitude,
  Value<String> status,
  Value<String> model,
  Value<String> network,
  Value<bool> isFavorite,
  Value<int> rowid,
});

class $$PlatformsTableFilterComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));
}

class $$PlatformsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get network => $composableBuilder(
      column: $table.network, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));
}

class $$PlatformsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);
}

class $$PlatformsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlatformsTable,
    PlatformEntity,
    $$PlatformsTableFilterComposer,
    $$PlatformsTableOrderingComposer,
    $$PlatformsTableAnnotationComposer,
    $$PlatformsTableCreateCompanionBuilder,
    $$PlatformsTableUpdateCompanionBuilder,
    (
      PlatformEntity,
      BaseReferences<_$AppDatabase, $PlatformsTable, PlatformEntity>
    ),
    PlatformEntity,
    PrefetchHooks Function()> {
  $$PlatformsTableTableManager(_$AppDatabase db, $PlatformsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatformsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatformsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatformsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> reference = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<String> network = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlatformsCompanion(
            reference: reference,
            latitude: latitude,
            longitude: longitude,
            status: status,
            model: model,
            network: network,
            isFavorite: isFavorite,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String reference,
            required double latitude,
            required double longitude,
            required String status,
            required String model,
            required String network,
            Value<bool> isFavorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlatformsCompanion.insert(
            reference: reference,
            latitude: latitude,
            longitude: longitude,
            status: status,
            model: model,
            network: network,
            isFavorite: isFavorite,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlatformsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlatformsTable,
    PlatformEntity,
    $$PlatformsTableFilterComposer,
    $$PlatformsTableOrderingComposer,
    $$PlatformsTableAnnotationComposer,
    $$PlatformsTableCreateCompanionBuilder,
    $$PlatformsTableUpdateCompanionBuilder,
    (
      PlatformEntity,
      BaseReferences<_$AppDatabase, $PlatformsTable, PlatformEntity>
    ),
    PlatformEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlatformsTableTableManager get platforms =>
      $$PlatformsTableTableManager(_db, _db.platforms);
}
