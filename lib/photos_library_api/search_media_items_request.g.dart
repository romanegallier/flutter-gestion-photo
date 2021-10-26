// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_media_items_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchMediaItemsRequest _$SearchMediaItemsRequestFromJson(
    Map<String, dynamic> json) {
  return SearchMediaItemsRequest(
    albumId: json['albumId'] as String?,
    pageSize: json['pageSize'] as int?,
    pageToken: json['pageToken'] as String?,
  );
}

Map<String, dynamic> _$SearchMediaItemsRequestToJson(
    SearchMediaItemsRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('albumId', instance.albumId);
  writeNotNull('pageSize', instance.pageSize);
  writeNotNull('pageToken', instance.pageToken);
  return val;
}
