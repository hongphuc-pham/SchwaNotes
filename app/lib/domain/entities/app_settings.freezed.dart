// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

/// Light, dark or follow the system.
 ThemePreference get themeMode;/// Preferred speech voice.
 TtsLocale get ttsLocale;/// Speech rate, 0.0-1.0 as flutter_tts defines it. 0.5 is normal pace.
 double get ttsRate;/// Speech pitch, 0.5-2.0. 1.0 is unmodified.
 double get ttsPitch;/// Speak the word automatically when its detail screen opens.
 bool get autoplayOnOpen;/// Cards to aim for each day. Caps the daily review pool.
 int get dailyGoal;/// Off by default, and permission is only requested when the user turns it
/// on (F-066, RULES §6 - no forced notifications).
 bool get reminderEnabled;/// Minutes after local midnight for the reminder. Null when never set.
 int? get reminderTimeMinutes;/// Which face of a practice card is shown first.
 PromptSide get promptSide;/// The faces a [PromptSide.mix] prompt draws from. Always a valid mix
/// when read from the database (`PromptSide.decodeMix`).
 Set<PromptSide> get mixSides;/// How a [PromptSide.mix] prompt picks each card's face.
 MixOrder get mixOrder;/// Whether the *Look up* button is offered on the word form.
///
/// Turning it off makes the app entirely offline by choice, not just by
/// circumstance.
 bool get lookupEnabled;/// The interval each Leitner box waits, as a JSON array of seven integers.
///
/// Kept as the stored string here rather than a parsed object: `domain`
/// may not import `application`, and `ReviewSchedule` lives there with the
/// scheduler it serves. `ReviewSchedule.fromJson` does the parsing, and
/// falls back to the documented default if this is ever unusable.
 String get reviewScheduleJson;/// How many extra times a card graded *again* returns in the same session.
///
/// Session-local: it touches no scheduling column. 0 disables it.
 int get againRepeats;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.ttsLocale, _this.ttsLocale) || other.ttsLocale == _this.ttsLocale)&&(identical(other.ttsRate, _this.ttsRate) || other.ttsRate == _this.ttsRate)&&(identical(other.ttsPitch, _this.ttsPitch) || other.ttsPitch == _this.ttsPitch)&&(identical(other.autoplayOnOpen, _this.autoplayOnOpen) || other.autoplayOnOpen == _this.autoplayOnOpen)&&(identical(other.dailyGoal, _this.dailyGoal) || other.dailyGoal == _this.dailyGoal)&&(identical(other.reminderEnabled, _this.reminderEnabled) || other.reminderEnabled == _this.reminderEnabled)&&(identical(other.reminderTimeMinutes, _this.reminderTimeMinutes) || other.reminderTimeMinutes == _this.reminderTimeMinutes)&&(identical(other.promptSide, _this.promptSide) || other.promptSide == _this.promptSide)&&const DeepCollectionEquality().equals(other.mixSides, _this.mixSides)&&(identical(other.mixOrder, _this.mixOrder) || other.mixOrder == _this.mixOrder)&&(identical(other.lookupEnabled, _this.lookupEnabled) || other.lookupEnabled == _this.lookupEnabled)&&(identical(other.reviewScheduleJson, _this.reviewScheduleJson) || other.reviewScheduleJson == _this.reviewScheduleJson)&&(identical(other.againRepeats, _this.againRepeats) || other.againRepeats == _this.againRepeats));
}


@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hash(runtimeType,_this.themeMode,_this.ttsLocale,_this.ttsRate,_this.ttsPitch,_this.autoplayOnOpen,_this.dailyGoal,_this.reminderEnabled,_this.reminderTimeMinutes,_this.promptSide,const DeepCollectionEquality().hash(_this.mixSides),_this.mixOrder,_this.lookupEnabled,_this.reviewScheduleJson,_this.againRepeats);
}

@override
String toString() {
  final _this = this as AppSettings;
  return 'AppSettings(themeMode: ${_this.themeMode}, ttsLocale: ${_this.ttsLocale}, ttsRate: ${_this.ttsRate}, ttsPitch: ${_this.ttsPitch}, autoplayOnOpen: ${_this.autoplayOnOpen}, dailyGoal: ${_this.dailyGoal}, reminderEnabled: ${_this.reminderEnabled}, reminderTimeMinutes: ${_this.reminderTimeMinutes}, promptSide: ${_this.promptSide}, mixSides: ${_this.mixSides}, mixOrder: ${_this.mixOrder}, lookupEnabled: ${_this.lookupEnabled}, reviewScheduleJson: ${_this.reviewScheduleJson}, againRepeats: ${_this.againRepeats})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 ThemePreference themeMode, TtsLocale ttsLocale, double ttsRate, double ttsPitch, bool autoplayOnOpen, int dailyGoal, bool reminderEnabled, int? reminderTimeMinutes, PromptSide promptSide, Set<PromptSide> mixSides, MixOrder mixOrder, bool lookupEnabled, String reviewScheduleJson, int againRepeats
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? ttsLocale = null,Object? ttsRate = null,Object? ttsPitch = null,Object? autoplayOnOpen = null,Object? dailyGoal = null,Object? reminderEnabled = null,Object? reminderTimeMinutes = freezed,Object? promptSide = null,Object? mixSides = null,Object? mixOrder = null,Object? lookupEnabled = null,Object? reviewScheduleJson = null,Object? againRepeats = null,}) {
  return _then(AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemePreference,ttsLocale: null == ttsLocale ? _self.ttsLocale : ttsLocale // ignore: cast_nullable_to_non_nullable
as TtsLocale,ttsRate: null == ttsRate ? _self.ttsRate : ttsRate // ignore: cast_nullable_to_non_nullable
as double,ttsPitch: null == ttsPitch ? _self.ttsPitch : ttsPitch // ignore: cast_nullable_to_non_nullable
as double,autoplayOnOpen: null == autoplayOnOpen ? _self.autoplayOnOpen : autoplayOnOpen // ignore: cast_nullable_to_non_nullable
as bool,dailyGoal: null == dailyGoal ? _self.dailyGoal : dailyGoal // ignore: cast_nullable_to_non_nullable
as int,reminderEnabled: null == reminderEnabled ? _self.reminderEnabled : reminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderTimeMinutes: freezed == reminderTimeMinutes ? _self.reminderTimeMinutes : reminderTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,promptSide: null == promptSide ? _self.promptSide : promptSide // ignore: cast_nullable_to_non_nullable
as PromptSide,mixSides: null == mixSides ? _self.mixSides : mixSides // ignore: cast_nullable_to_non_nullable
as Set<PromptSide>,mixOrder: null == mixOrder ? _self.mixOrder : mixOrder // ignore: cast_nullable_to_non_nullable
as MixOrder,lookupEnabled: null == lookupEnabled ? _self.lookupEnabled : lookupEnabled // ignore: cast_nullable_to_non_nullable
as bool,reviewScheduleJson: null == reviewScheduleJson ? _self.reviewScheduleJson : reviewScheduleJson // ignore: cast_nullable_to_non_nullable
as String,againRepeats: null == againRepeats ? _self.againRepeats : againRepeats // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemePreference themeMode,  TtsLocale ttsLocale,  double ttsRate,  double ttsPitch,  bool autoplayOnOpen,  int dailyGoal,  bool reminderEnabled,  int? reminderTimeMinutes,  PromptSide promptSide,  Set<PromptSide> mixSides,  MixOrder mixOrder,  bool lookupEnabled,  String reviewScheduleJson,  int againRepeats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.ttsLocale,_that.ttsRate,_that.ttsPitch,_that.autoplayOnOpen,_that.dailyGoal,_that.reminderEnabled,_that.reminderTimeMinutes,_that.promptSide,_that.mixSides,_that.mixOrder,_that.lookupEnabled,_that.reviewScheduleJson,_that.againRepeats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemePreference themeMode,  TtsLocale ttsLocale,  double ttsRate,  double ttsPitch,  bool autoplayOnOpen,  int dailyGoal,  bool reminderEnabled,  int? reminderTimeMinutes,  PromptSide promptSide,  Set<PromptSide> mixSides,  MixOrder mixOrder,  bool lookupEnabled,  String reviewScheduleJson,  int againRepeats)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.themeMode,_that.ttsLocale,_that.ttsRate,_that.ttsPitch,_that.autoplayOnOpen,_that.dailyGoal,_that.reminderEnabled,_that.reminderTimeMinutes,_that.promptSide,_that.mixSides,_that.mixOrder,_that.lookupEnabled,_that.reviewScheduleJson,_that.againRepeats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemePreference themeMode,  TtsLocale ttsLocale,  double ttsRate,  double ttsPitch,  bool autoplayOnOpen,  int dailyGoal,  bool reminderEnabled,  int? reminderTimeMinutes,  PromptSide promptSide,  Set<PromptSide> mixSides,  MixOrder mixOrder,  bool lookupEnabled,  String reviewScheduleJson,  int againRepeats)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.ttsLocale,_that.ttsRate,_that.ttsPitch,_that.autoplayOnOpen,_that.dailyGoal,_that.reminderEnabled,_that.reminderTimeMinutes,_that.promptSide,_that.mixSides,_that.mixOrder,_that.lookupEnabled,_that.reviewScheduleJson,_that.againRepeats);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings extends AppSettings {
  const _AppSettings({this.themeMode = ThemePreference.system, this.ttsLocale = TtsLocale.enGb, this.ttsRate = 0.5, this.ttsPitch = 1, this.autoplayOnOpen = false, this.dailyGoal = 20, this.reminderEnabled = false, this.reminderTimeMinutes, this.promptSide = PromptSide.wordFirst,  Set<PromptSide> mixSides = PromptSide.defaultMixSides, this.mixOrder = MixOrder.random, this.lookupEnabled = true, this.reviewScheduleJson = '[0,1,2,4,7,15,30]', this.againRepeats = 1}): _mixSides = mixSides,super._();
  

/// Light, dark or follow the system.
@override@JsonKey() final  ThemePreference themeMode;
/// Preferred speech voice.
@override@JsonKey() final  TtsLocale ttsLocale;
/// Speech rate, 0.0-1.0 as flutter_tts defines it. 0.5 is normal pace.
@override@JsonKey() final  double ttsRate;
/// Speech pitch, 0.5-2.0. 1.0 is unmodified.
@override@JsonKey() final  double ttsPitch;
/// Speak the word automatically when its detail screen opens.
@override@JsonKey() final  bool autoplayOnOpen;
/// Cards to aim for each day. Caps the daily review pool.
@override@JsonKey() final  int dailyGoal;
/// Off by default, and permission is only requested when the user turns it
/// on (F-066, RULES §6 - no forced notifications).
@override@JsonKey() final  bool reminderEnabled;
/// Minutes after local midnight for the reminder. Null when never set.
@override final  int? reminderTimeMinutes;
/// Which face of a practice card is shown first.
@override@JsonKey() final  PromptSide promptSide;
/// The faces a [PromptSide.mix] prompt draws from. Always a valid mix
/// when read from the database (`PromptSide.decodeMix`).
 final  Set<PromptSide> _mixSides;
/// The faces a [PromptSide.mix] prompt draws from. Always a valid mix
/// when read from the database (`PromptSide.decodeMix`).
@override@JsonKey() Set<PromptSide> get mixSides {
  if (_mixSides is EqualUnmodifiableSetView) return _mixSides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_mixSides);
}

/// How a [PromptSide.mix] prompt picks each card's face.
@override@JsonKey() final  MixOrder mixOrder;
/// Whether the *Look up* button is offered on the word form.
///
/// Turning it off makes the app entirely offline by choice, not just by
/// circumstance.
@override@JsonKey() final  bool lookupEnabled;
/// The interval each Leitner box waits, as a JSON array of seven integers.
///
/// Kept as the stored string here rather than a parsed object: `domain`
/// may not import `application`, and `ReviewSchedule` lives there with the
/// scheduler it serves. `ReviewSchedule.fromJson` does the parsing, and
/// falls back to the documented default if this is ever unusable.
@override@JsonKey() final  String reviewScheduleJson;
/// How many extra times a card graded *again* returns in the same session.
///
/// Session-local: it touches no scheduling column. 0 disables it.
@override@JsonKey() final  int againRepeats;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.ttsLocale, ttsLocale) || other.ttsLocale == ttsLocale)&&(identical(other.ttsRate, ttsRate) || other.ttsRate == ttsRate)&&(identical(other.ttsPitch, ttsPitch) || other.ttsPitch == ttsPitch)&&(identical(other.autoplayOnOpen, autoplayOnOpen) || other.autoplayOnOpen == autoplayOnOpen)&&(identical(other.dailyGoal, dailyGoal) || other.dailyGoal == dailyGoal)&&(identical(other.reminderEnabled, reminderEnabled) || other.reminderEnabled == reminderEnabled)&&(identical(other.reminderTimeMinutes, reminderTimeMinutes) || other.reminderTimeMinutes == reminderTimeMinutes)&&(identical(other.promptSide, promptSide) || other.promptSide == promptSide)&&const DeepCollectionEquality().equals(other.mixSides, _mixSides)&&(identical(other.mixOrder, mixOrder) || other.mixOrder == mixOrder)&&(identical(other.lookupEnabled, lookupEnabled) || other.lookupEnabled == lookupEnabled)&&(identical(other.reviewScheduleJson, reviewScheduleJson) || other.reviewScheduleJson == reviewScheduleJson)&&(identical(other.againRepeats, againRepeats) || other.againRepeats == againRepeats));
}


@override
int get hashCode {
    return Object.hash(runtimeType,themeMode,ttsLocale,ttsRate,ttsPitch,autoplayOnOpen,dailyGoal,reminderEnabled,reminderTimeMinutes,promptSide,const DeepCollectionEquality().hash(_mixSides),mixOrder,lookupEnabled,reviewScheduleJson,againRepeats);
}

@override
String toString() {
    return 'AppSettings(themeMode: $themeMode, ttsLocale: $ttsLocale, ttsRate: $ttsRate, ttsPitch: $ttsPitch, autoplayOnOpen: $autoplayOnOpen, dailyGoal: $dailyGoal, reminderEnabled: $reminderEnabled, reminderTimeMinutes: $reminderTimeMinutes, promptSide: $promptSide, mixSides: $mixSides, mixOrder: $mixOrder, lookupEnabled: $lookupEnabled, reviewScheduleJson: $reviewScheduleJson, againRepeats: $againRepeats)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 ThemePreference themeMode, TtsLocale ttsLocale, double ttsRate, double ttsPitch, bool autoplayOnOpen, int dailyGoal, bool reminderEnabled, int? reminderTimeMinutes, PromptSide promptSide, Set<PromptSide> mixSides, MixOrder mixOrder, bool lookupEnabled, String reviewScheduleJson, int againRepeats
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? ttsLocale = null,Object? ttsRate = null,Object? ttsPitch = null,Object? autoplayOnOpen = null,Object? dailyGoal = null,Object? reminderEnabled = null,Object? reminderTimeMinutes = freezed,Object? promptSide = null,Object? mixSides = null,Object? mixOrder = null,Object? lookupEnabled = null,Object? reviewScheduleJson = null,Object? againRepeats = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemePreference,ttsLocale: null == ttsLocale ? _self.ttsLocale : ttsLocale // ignore: cast_nullable_to_non_nullable
as TtsLocale,ttsRate: null == ttsRate ? _self.ttsRate : ttsRate // ignore: cast_nullable_to_non_nullable
as double,ttsPitch: null == ttsPitch ? _self.ttsPitch : ttsPitch // ignore: cast_nullable_to_non_nullable
as double,autoplayOnOpen: null == autoplayOnOpen ? _self.autoplayOnOpen : autoplayOnOpen // ignore: cast_nullable_to_non_nullable
as bool,dailyGoal: null == dailyGoal ? _self.dailyGoal : dailyGoal // ignore: cast_nullable_to_non_nullable
as int,reminderEnabled: null == reminderEnabled ? _self.reminderEnabled : reminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderTimeMinutes: freezed == reminderTimeMinutes ? _self.reminderTimeMinutes : reminderTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,promptSide: null == promptSide ? _self.promptSide : promptSide // ignore: cast_nullable_to_non_nullable
as PromptSide,mixSides: null == mixSides ? _self._mixSides : mixSides // ignore: cast_nullable_to_non_nullable
as Set<PromptSide>,mixOrder: null == mixOrder ? _self.mixOrder : mixOrder // ignore: cast_nullable_to_non_nullable
as MixOrder,lookupEnabled: null == lookupEnabled ? _self.lookupEnabled : lookupEnabled // ignore: cast_nullable_to_non_nullable
as bool,reviewScheduleJson: null == reviewScheduleJson ? _self.reviewScheduleJson : reviewScheduleJson // ignore: cast_nullable_to_non_nullable
as String,againRepeats: null == againRepeats ? _self.againRepeats : againRepeats // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
