import 'package:sharing_codelab/photos_library_api/album.dart' as albumApi;
import 'package:sharing_codelab/photos_library_api/media_item.dart' as mediaItemApi;

class MediaItem {

  String id;
  String description;
  String productUrl;
  String baseUrl;
  String fileName;
  bool isInAlbum;

  MediaItem({required this.id,required this.description, required this.productUrl, required this.baseUrl,
    required this.fileName, required this.isInAlbum});

  Map<String, dynamic> toMap() {
    return {
     'id': id ,
     'description': description ,
     'productUrl': productUrl ,
     'baseUrl': baseUrl,
     'fileName': fileName ,
      'isInAlbum': isInAlbum ? 0 : 1,
    };
  }


  @override
  String toString() {
    return 'MediaItem{id: $id, description: $description, productUrl: $productUrl, baseUrl: $baseUrl, fileName: $fileName, isInAlbum: $isInAlbum}';
  }

  MediaItem.fromDto(mediaItemApi.MediaItem dto): this.fromDto2(dto, false);

  MediaItem.fromDto2(mediaItemApi.MediaItem dto, bool isInAlbum): this(
    id: dto.id,
    description: dto.description!= null ? dto.description! : "",
    productUrl: dto.productUrl!= null ? dto.productUrl! : "",
    baseUrl:  dto.baseUrl!= null ? dto.baseUrl! : "",
    fileName: dto.fileName!= null ? dto.fileName! : "",
    isInAlbum: isInAlbum,
  );


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;


}



