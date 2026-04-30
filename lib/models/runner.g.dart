// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Runner _$RunnerFromJson(Map<String, dynamic> json) => Runner(
  id: json['id'] as String,
  userId: json['userId'] as String,
  isOnline: json['isOnline'] as bool,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RunnerToJson(Runner instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'isOnline': instance.isOnline,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
