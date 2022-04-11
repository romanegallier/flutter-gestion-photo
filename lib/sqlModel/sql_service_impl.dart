import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sharing_codelab/photos_library_api/album.dart' as albumApi;
import 'package:sharing_codelab/photos_library_api/media_item.dart' as mediaItemApi;
import 'package:sharing_codelab/sqlModel/media_item.dart';
import 'package:sharing_codelab/sqlModel/sql_service.dart';
import 'package:sqflite/sqflite.dart';

import 'album.dart';
import 'dog.dart';

class SqlServiceImpl extends SqlService {
  String dataBaseName = 'gestion_photo.db';
  String dogsTable = 'dogs';
  String albumTable = 'albums';
  String mediaItemTable = 'mediaItems';
  late Future<Database> database;

  Future<void> createDogTable() async{
    WidgetsFlutterBinding.ensureInitialized();
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dataBaseName);
    database = openDatabase(
        path,
        onCreate: _createDb,
    version: 1,
    );
    await database;
    return;
  }

  Future<void> _createDb(Database db, int newVersion) async{
    await db.execute(
      'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
    );
    await db.execute(
      'CREATE TABLE albums( id TEXT PRIMARY KEY, title TEXT, productUrl TEXT, isWriteable INTEGER, mediaItemsCount INTEGER, coverPhotoBaseUrl TEXT,coverPhotoMediaItemId TEXT)',
    );
    await db.execute(
      'CREATE TABLE mediaItems( id TEXT PRIMARY KEY, description TEXT, productUrl TEXT, baseUrl TEXT, fileName STRING, isInAlbum INTEGER)',
    );


  }

  // void _createDb(Database db, int newVersion) async {
  //   await db.execute('''
  //  create table $carTable (
  //   $columnCarId integer primary key autoincrement,
  //   $columnCarTitle text not null
  //  )''');
  //   await db.execute('''
  //  create table $userTable(
  //   $userId integer primary key autoincrement,
  //   $name text not null
  //  )''');
  // }

  // Define a function that inserts dogs into the database
  @override
  Future<void> insertDog(Dog dog) async {
    final db = await database;
    await db.insert(
      dogsTable,
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Define a function that inserts an album into the database
  @override
  Future<void> insertAlbum(Album album) async {
    final db = await database;
    await db.insert(
      albumTable,
      album.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Define a function that inserts an media item into the database
  @override
  Future<void> insertMediaItem(MediaItem mediaItem) async {
    final db = await database;
    await db.insert(
      mediaItemTable,
      mediaItem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void test() async{
    // Create a Dog and add it to the dogs table
    var fido = Dog(
      id: 0,
      name: 'Fido',
      age: 35,
    );

    await insertDog(fido);
    // Now, use the method above to retrieve all the dogs.
    print(await dogs()); // Prints a list that include Fido.

    var album = Album (
      id: '0',
      coverPhotoBaseUrl: '',
      coverPhotoMediaItemId: '',
      isWriteable: 0,
      mediaItemsCount: 0,
      productUrl: '',
      title: '',
    );
    await insertAlbum(album);
    print(await albums());

    var mediaItem = MediaItem (
      id: '0',
      description: 'description',
      productUrl: 'productUrl',
      baseUrl: 'baseUrl',
      fileName: 'fileName',
      isInAlbum: false,
    );
    await insertMediaItem(mediaItem);
    print(await mediaItems());

    // Update Fido's age and save it to the database.
    fido = Dog(
      id: fido.id,
      name: fido.name,
      age: fido.age + 7,
    );
    await updateDog(fido);

// Print the updated results.
    print(await dogs()); // Prints Fido with age 42.
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> dogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  // A method that retrieves all the albums from the albums table.
  Future<List<Album>> albums() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(albumTable);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Album(
        id: maps[i]['id'],
        coverPhotoBaseUrl: maps[i]['coverPhotoBaseUrl'],
        coverPhotoMediaItemId: maps[i]['coverPhotoMediaItemId'],
        isWriteable: maps[i]['isWriteable'],
        mediaItemsCount: maps[i]['mediaItemsCount'],
        productUrl: maps[i]['productUrl'],
        title: maps[i]['title'],
      );
    });
  }

  // A method that retrieves all the mediaitems from the albums table.
  Future<List<MediaItem>> mediaItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(mediaItemTable);
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return MediaItem(
        id: maps[i]['id'],
        description: maps[i]['description'],
        productUrl: maps[i]['productUrl'],
        fileName: maps[i]['fileName'],
        baseUrl: maps[i]['baseUrl'],
        isInAlbum: maps[i]['isInAlbum']==1
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await database;
    await db.update(
      'dogs',
      dog.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [dog.id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await database;
    await db.delete(
      'dogs',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  @override
  void insertListAlbum(List<albumApi.Album> albumList) async{
      print("nbAlbum a inserer" + albumList.length.toString());
      //removeAlbum();
      for (albumApi.Album dto in albumList){
        insertAlbum(Album.fromDto(dto));
      }
      List<Album> l = await albums();
      print(l.length );
  }

  @override
  void insertListMedia(List<MediaItem> mediaList) async{
    print("nbMedia a inserer" + mediaList.length.toString());
    //removeAlbum();
    for (MediaItem dto in mediaList){
      insertMediaItem(dto);
    }
    List<MediaItem> l = await mediaItems();
    print(l.length );
  }






  @override
  void removeAlbum() async{
    final db = await database;
    await db.delete(
      albumTable,
    );
  }

  @override
  void removeMedia() async{
    final db = await database;
    await db.delete(
      mediaItemTable,
    );
  }



}