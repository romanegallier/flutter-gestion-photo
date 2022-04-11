import 'package:sharing_codelab/photos_library_api/album.dart' as albumApi;
import 'package:sharing_codelab/photos_library_api/media_item.dart' as mediaItemApi;


class Album {
  String id;
  String title;
  String productUrl;
  int isWriteable;
  int mediaItemsCount;
  String coverPhotoBaseUrl;
  String coverPhotoMediaItemId;

  Album({required this.id,required this.title, required this.productUrl, required this.isWriteable,
    required this.mediaItemsCount, required this.coverPhotoBaseUrl, required this.coverPhotoMediaItemId});

  Map<String, dynamic> toMap() {
    return {
     'id': id ,
     'title': title ,
     'productUrl': productUrl ,
     'isWriteable': isWriteable,
     'mediaItemsCount': mediaItemsCount ,
     'coverPhotoBaseUrl': coverPhotoBaseUrl ,
     'coverPhotoMediaItemId': coverPhotoMediaItemId ,
    };
  }

  Album.fromDto(albumApi.Album dto): this(
      id: dto.id!,
      title: dto.title!,
      productUrl: dto.productUrl!,
      isWriteable: dto.isWriteable!=null? 1:0,
      mediaItemsCount: dto.mediaItemsCount!=null ? int.parse(dto.mediaItemsCount!):0,
      coverPhotoBaseUrl: dto.coverPhotoBaseUrl!=null ? dto.coverPhotoBaseUrl!: "",
      coverPhotoMediaItemId: dto.coverPhotoMediaItemId!=null ? dto.coverPhotoMediaItemId!: ""
  );



  @override
  String toString() {
    return 'Album{id: $id, title: $title, productUrl: $productUrl, isWriteable: $isWriteable, mediaItemsCount: $mediaItemsCount, coverPhotoBaseUrl: $coverPhotoBaseUrl, coverPhotoMediaItemId: $coverPhotoMediaItemId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;


}



