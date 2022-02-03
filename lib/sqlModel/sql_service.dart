import 'package:sharing_codelab/photos_library_api/album.dart';

import 'dog.dart';

abstract class SqlService {
  Future<void> createDogTable();

  // Define a function that inserts dogs into the database
  Future<void> insertDog(Dog dog);

  void test();

  void removeAlbum();

  void insertListAlbum(List<Album> albumList);
}