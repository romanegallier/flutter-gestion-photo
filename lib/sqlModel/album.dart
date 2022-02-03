class Album {
  String id;
  String title;
  String productUrl;
  int isWriteable;
  String mediaItemsCount;
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



