// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AccountInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInfo _$AccountInfoFromJson(Map<String, dynamic> json) {
  return AccountInfo(
    json['primaryInfo'] as String,
    json['secondaryInfo'] as String,
  );
}

Map<String, dynamic> _$AccountInfoToJson(AccountInfo instance) =>
    <String, dynamic>{
      'primaryInfo': instance.primaryInfo,
      'secondaryInfo': instance.secondaryInfo,
    };
