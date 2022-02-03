import 'package:json_annotation/json_annotation.dart';

part 'media_item.g.dart';

@JsonSerializable()
class MediaItem {
  MediaItem(this.id, this.description, this.productUrl, this.baseUrl, this.fileName);

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  Map<String, dynamic> toJson() => _$MediaItemToJson(this);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
  String id;
  String? description;
  String? productUrl;
  String? baseUrl;
  String? fileName;
}
