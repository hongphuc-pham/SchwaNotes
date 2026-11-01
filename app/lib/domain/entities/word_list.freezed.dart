// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordList {

/// UUID v4.
 String get id;/// What the user called it.
 String get name;/// Card colour. Reuses the IPA palette tokens so the app has one set of
/// colours, stored by name so a theme change recolours existing lists.
 IpaColorToken get color;/// Position in the grid; lower sorts first. Long-press to reorder.
 int get sortOrder;/// When it was created.
 DateTime get createdAt;/// When it was last renamed, recoloured or reordered.
 DateTime get updatedAt;/// Optional icon identifier, for a later release.
 String? get iconKey;/// A list or a tag.
 ListKind get kind;
/// Create a copy of WordList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordListCopyWith<WordList> get copyWith => _$WordListCopyWithImpl<WordList>(this as WordList, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WordList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordList&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.kind, _this.kind) || other.kind == _this.kind));
}


@override
int get hashCode {
  final _this = this as WordList;
  return Object.hash(runtimeType,_this.id,_this.name,_this.color,_this.sortOrder,_this.createdAt,_this.updatedAt,_this.iconKey,_this.kind);
}

@override
String toString() {
  final _this = this as WordList;
  return 'WordList(id: ${_this.id}, name: ${_this.name}, color: ${_this.color}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, iconKey: ${_this.iconKey}, kind: ${_this.kind})';
}


}

/// @nodoc
abstract mixin class $WordListCopyWith<$Res>  {
  factory $WordListCopyWith(WordList value, $Res Function(WordList) _then) = _$WordListCopyWithImpl;
@useResult
$Res call({
 String id, String name, IpaColorToken color, int sortOrder, DateTime createdAt, DateTime updatedAt, String? iconKey, ListKind kind
});




}
/// @nodoc
class _$WordListCopyWithImpl<$Res>
    implements $WordListCopyWith<$Res> {
  _$WordListCopyWithImpl(this._self, this._then);

  final WordList _self;
  final $Res Function(WordList) _then;

/// Create a copy of WordList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? iconKey = freezed,Object? kind = null,}) {
  return _then(WordList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as IpaColorToken,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ListKind,
  ));
}

}


/// Adds pattern-matching-related methods to [WordList].
extension WordListPatterns on WordList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordList value)  $default,){
final _that = this;
switch (_that) {
case _WordList():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordList value)?  $default,){
final _that = this;
switch (_that) {
case _WordList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  IpaColorToken color,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  String? iconKey,  ListKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordList() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.iconKey,_that.kind);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  IpaColorToken color,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  String? iconKey,  ListKind kind)  $default,) {final _that = this;
switch (_that) {
case _WordList():
return $default(_that.id,_that.name,_that.color,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.iconKey,_that.kind);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  IpaColorToken color,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  String? iconKey,  ListKind kind)?  $default,) {final _that = this;
switch (_that) {
case _WordList() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.iconKey,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _WordList extends WordList {
  const _WordList({required this.id, required this.name, required this.color, required this.sortOrder, required this.createdAt, required this.updatedAt, this.iconKey, this.kind = ListKind.list}): super._();
  

/// UUID v4.
@override final  String id;
/// What the user called it.
@override final  String name;
/// Card colour. Reuses the IPA palette tokens so the app has one set of
/// colours, stored by name so a theme change recolours existing lists.
@override final  IpaColorToken color;
/// Position in the grid; lower sorts first. Long-press to reorder.
@override final  int sortOrder;
/// When it was created.
@override final  DateTime createdAt;
/// When it was last renamed, recoloured or reordered.
@override final  DateTime updatedAt;
/// Optional icon identifier, for a later release.
@override final  String? iconKey;
/// A list or a tag.
@override@JsonKey() final  ListKind kind;

/// Create a copy of WordList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordListCopyWith<_WordList> get copyWith => __$WordListCopyWithImpl<_WordList>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordList&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,color,sortOrder,createdAt,updatedAt,iconKey,kind);
}

@override
String toString() {
    return 'WordList(id: $id, name: $name, color: $color, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, iconKey: $iconKey, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$WordListCopyWith<$Res> implements $WordListCopyWith<$Res> {
  factory _$WordListCopyWith(_WordList value, $Res Function(_WordList) _then) = __$WordListCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, IpaColorToken color, int sortOrder, DateTime createdAt, DateTime updatedAt, String? iconKey, ListKind kind
});




}
/// @nodoc
class __$WordListCopyWithImpl<$Res>
    implements _$WordListCopyWith<$Res> {
  __$WordListCopyWithImpl(this._self, this._then);

  final _WordList _self;
  final $Res Function(_WordList) _then;

/// Create a copy of WordList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? iconKey = freezed,Object? kind = null,}) {
  return _then(_WordList(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as IpaColorToken,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,iconKey: freezed == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ListKind,
  ));
}


}

/// @nodoc
mixin _$WordListSummary {

/// The list itself.
 WordList get list;/// How many words are in it, excluding soft-deleted ones.
 int get wordCount;/// How many of those have a study card due now - the due-today badge.
 int get dueCount;
/// Create a copy of WordListSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordListSummaryCopyWith<WordListSummary> get copyWith => _$WordListSummaryCopyWithImpl<WordListSummary>(this as WordListSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WordListSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordListSummary&&(identical(other.list, _this.list) || other.list == _this.list)&&(identical(other.wordCount, _this.wordCount) || other.wordCount == _this.wordCount)&&(identical(other.dueCount, _this.dueCount) || other.dueCount == _this.dueCount));
}


@override
int get hashCode {
  final _this = this as WordListSummary;
  return Object.hash(runtimeType,_this.list,_this.wordCount,_this.dueCount);
}

@override
String toString() {
  final _this = this as WordListSummary;
  return 'WordListSummary(list: ${_this.list}, wordCount: ${_this.wordCount}, dueCount: ${_this.dueCount})';
}


}

/// @nodoc
abstract mixin class $WordListSummaryCopyWith<$Res>  {
  factory $WordListSummaryCopyWith(WordListSummary value, $Res Function(WordListSummary) _then) = _$WordListSummaryCopyWithImpl;
@useResult
$Res call({
 WordList list, int wordCount, int dueCount
});


$WordListCopyWith<$Res> get list;

}
/// @nodoc
class _$WordListSummaryCopyWithImpl<$Res>
    implements $WordListSummaryCopyWith<$Res> {
  _$WordListSummaryCopyWithImpl(this._self, this._then);

  final WordListSummary _self;
  final $Res Function(WordListSummary) _then;

/// Create a copy of WordListSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? list = null,Object? wordCount = null,Object? dueCount = null,}) {
  return _then(WordListSummary(
list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as WordList,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of WordListSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordListCopyWith<$Res> get list {
  
  return $WordListCopyWith<$Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}


/// Adds pattern-matching-related methods to [WordListSummary].
extension WordListSummaryPatterns on WordListSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordListSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordListSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordListSummary value)  $default,){
final _that = this;
switch (_that) {
case _WordListSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordListSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WordListSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WordList list,  int wordCount,  int dueCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordListSummary() when $default != null:
return $default(_that.list,_that.wordCount,_that.dueCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WordList list,  int wordCount,  int dueCount)  $default,) {final _that = this;
switch (_that) {
case _WordListSummary():
return $default(_that.list,_that.wordCount,_that.dueCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WordList list,  int wordCount,  int dueCount)?  $default,) {final _that = this;
switch (_that) {
case _WordListSummary() when $default != null:
return $default(_that.list,_that.wordCount,_that.dueCount);case _:
  return null;

}
}

}

/// @nodoc


class _WordListSummary extends WordListSummary {
  const _WordListSummary({required this.list, required this.wordCount, required this.dueCount}): super._();
  

/// The list itself.
@override final  WordList list;
/// How many words are in it, excluding soft-deleted ones.
@override final  int wordCount;
/// How many of those have a study card due now - the due-today badge.
@override final  int dueCount;

/// Create a copy of WordListSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordListSummaryCopyWith<_WordListSummary> get copyWith => __$WordListSummaryCopyWithImpl<_WordListSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordListSummary&&(identical(other.list, list) || other.list == list)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.dueCount, dueCount) || other.dueCount == dueCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,list,wordCount,dueCount);
}

@override
String toString() {
    return 'WordListSummary(list: $list, wordCount: $wordCount, dueCount: $dueCount)';
}


}

/// @nodoc
abstract mixin class _$WordListSummaryCopyWith<$Res> implements $WordListSummaryCopyWith<$Res> {
  factory _$WordListSummaryCopyWith(_WordListSummary value, $Res Function(_WordListSummary) _then) = __$WordListSummaryCopyWithImpl;
@override @useResult
$Res call({
 WordList list, int wordCount, int dueCount
});


@override $WordListCopyWith<$Res> get list;

}
/// @nodoc
class __$WordListSummaryCopyWithImpl<$Res>
    implements _$WordListSummaryCopyWith<$Res> {
  __$WordListSummaryCopyWithImpl(this._self, this._then);

  final _WordListSummary _self;
  final $Res Function(_WordListSummary) _then;

/// Create a copy of WordListSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? list = null,Object? wordCount = null,Object? dueCount = null,}) {
  return _then(_WordListSummary(
list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as WordList,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of WordListSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WordListCopyWith<$Res> get list {
  
  return $WordListCopyWith<$Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}

// dart format on
