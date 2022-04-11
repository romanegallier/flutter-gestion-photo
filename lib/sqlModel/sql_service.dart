import 'package:sharing_codelab/photos_library_api/album.dart';

import 'package:sharing_codelab/photos_library_api/media_item.dart' as mediaItemApi;

import 'package:sharing_codelab/sqlModel/album.dart' as sql ;
import 'package:sharing_codelab/sqlModel/media_item.dart' as sql ;

import 'dog.dart';
import 'media_item.dart';

abstract class SqlService {
  Future<void> createDogTable();

  // Define a function that inserts dogs into the database
  Future<void> insertDog(Dog dog);

  void test();

  void removeAlbum();

  void removeMedia();

  void insertListAlbum(List<Album> albumList);

  void insertListMedia(List<MediaItem> mediaList);

  Future<List<sql.Album>> albums();

  Future<List<sql.MediaItem>> mediaItems();
}