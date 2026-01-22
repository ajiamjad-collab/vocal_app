// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCacheEntryCollection on Isar {
  IsarCollection<CacheEntry> get cacheEntrys => this.collection();
}

const CacheEntrySchema = CollectionSchema(
  name: r'CacheEntry',
  id: 1901957776030515961,
  properties: {
    r'etag': PropertySchema(id: 0, name: r'etag', type: IsarType.string),
    r'isExpired': PropertySchema(
      id: 1,
      name: r'isExpired',
      type: IsarType.bool,
    ),
    r'json': PropertySchema(id: 2, name: r'json', type: IsarType.string),
    r'key': PropertySchema(id: 3, name: r'key', type: IsarType.string),
    r'savedAtMs': PropertySchema(
      id: 4,
      name: r'savedAtMs',
      type: IsarType.long,
    ),
    r'ttlSeconds': PropertySchema(
      id: 5,
      name: r'ttlSeconds',
      type: IsarType.long,
    ),
  },

  estimateSize: _cacheEntryEstimateSize,
  serialize: _cacheEntrySerialize,
  deserialize: _cacheEntryDeserialize,
  deserializeProp: _cacheEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _cacheEntryGetId,
  getLinks: _cacheEntryGetLinks,
  attach: _cacheEntryAttach,
  version: '3.3.0',
);

int _cacheEntryEstimateSize(
  CacheEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.etag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.json.length * 3;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _cacheEntrySerialize(
  CacheEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.etag);
  writer.writeBool(offsets[1], object.isExpired);
  writer.writeString(offsets[2], object.json);
  writer.writeString(offsets[3], object.key);
  writer.writeLong(offsets[4], object.savedAtMs);
  writer.writeLong(offsets[5], object.ttlSeconds);
}

CacheEntry _cacheEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CacheEntry();
  object.etag = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.json = reader.readString(offsets[2]);
  object.key = reader.readString(offsets[3]);
  object.savedAtMs = reader.readLong(offsets[4]);
  object.ttlSeconds = reader.readLong(offsets[5]);
  return object;
}

P _cacheEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cacheEntryGetId(CacheEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cacheEntryGetLinks(CacheEntry object) {
  return [];
}

void _cacheEntryAttach(IsarCollection<dynamic> col, Id id, CacheEntry object) {
  object.id = id;
}

extension CacheEntryByIndex on IsarCollection<CacheEntry> {
  Future<CacheEntry?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  CacheEntry? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<CacheEntry?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<CacheEntry?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(CacheEntry object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(CacheEntry object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<CacheEntry> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<CacheEntry> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension CacheEntryQueryWhereSort
    on QueryBuilder<CacheEntry, CacheEntry, QWhere> {
  QueryBuilder<CacheEntry, CacheEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CacheEntryQueryWhere
    on QueryBuilder<CacheEntry, CacheEntry, QWhereClause> {
  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> keyEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'key', value: [key]),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterWhereClause> keyNotEqualTo(
    String key,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [key],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'key',
                lower: [],
                upper: [key],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CacheEntryQueryFilter
    on QueryBuilder<CacheEntry, CacheEntry, QFilterCondition> {
  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'etag'),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'etag'),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'etag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'etag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'etag', value: ''),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> etagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'etag', value: ''),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> isExpiredEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isExpired', value: value),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'json',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'json',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'json',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'json', value: ''),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> jsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'json', value: ''),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'key',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'key',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'key',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'key', value: ''),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> savedAtMsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedAtMs', value: value),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition>
  savedAtMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'savedAtMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> savedAtMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'savedAtMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> savedAtMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'savedAtMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> ttlSecondsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ttlSeconds', value: value),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition>
  ttlSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ttlSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition>
  ttlSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ttlSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterFilterCondition> ttlSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ttlSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CacheEntryQueryObject
    on QueryBuilder<CacheEntry, CacheEntry, QFilterCondition> {}

extension CacheEntryQueryLinks
    on QueryBuilder<CacheEntry, CacheEntry, QFilterCondition> {}

extension CacheEntryQuerySortBy
    on QueryBuilder<CacheEntry, CacheEntry, QSortBy> {
  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortBySavedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMs', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortBySavedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMs', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> sortByTtlSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.desc);
    });
  }
}

extension CacheEntryQuerySortThenBy
    on QueryBuilder<CacheEntry, CacheEntry, QSortThenBy> {
  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByIsExpiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isExpired', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'json', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenBySavedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMs', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenBySavedAtMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAtMs', Sort.desc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.asc);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QAfterSortBy> thenByTtlSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.desc);
    });
  }
}

extension CacheEntryQueryWhereDistinct
    on QueryBuilder<CacheEntry, CacheEntry, QDistinct> {
  QueryBuilder<CacheEntry, CacheEntry, QDistinct> distinctByEtag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'etag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QDistinct> distinctByIsExpired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isExpired');
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QDistinct> distinctByJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'json', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QDistinct> distinctByKey({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QDistinct> distinctBySavedAtMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAtMs');
    });
  }

  QueryBuilder<CacheEntry, CacheEntry, QDistinct> distinctByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ttlSeconds');
    });
  }
}

extension CacheEntryQueryProperty
    on QueryBuilder<CacheEntry, CacheEntry, QQueryProperty> {
  QueryBuilder<CacheEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CacheEntry, String?, QQueryOperations> etagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'etag');
    });
  }

  QueryBuilder<CacheEntry, bool, QQueryOperations> isExpiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isExpired');
    });
  }

  QueryBuilder<CacheEntry, String, QQueryOperations> jsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'json');
    });
  }

  QueryBuilder<CacheEntry, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<CacheEntry, int, QQueryOperations> savedAtMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAtMs');
    });
  }

  QueryBuilder<CacheEntry, int, QQueryOperations> ttlSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ttlSeconds');
    });
  }
}
