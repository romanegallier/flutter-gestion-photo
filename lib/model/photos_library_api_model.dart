

import 'dart:collection';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/constant.dart';
import 'package:sharing_codelab/photos_library_api/add_media_album_request.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/create_album_request.dart';
import 'package:sharing_codelab/photos_library_api/get_album_request.dart';
import 'package:sharing_codelab/photos_library_api/get_media_item_request.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_request.dart';
import 'package:sharing_codelab/photos_library_api/join_shared_album_response.dart';
import 'package:sharing_codelab/photos_library_api/list_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/list_shared_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/photos_library_api/photos_library_api_client.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/share_album_request.dart';
import 'package:sharing_codelab/photos_library_api/share_album_response.dart';
import 'package:sharing_codelab/sqlModel/album.dart' as sql;
import 'package:sharing_codelab/sqlModel/media_item.dart' as sql;
import 'package:sharing_codelab/sqlModel/sql_service.dart';

class PhotosLibraryApiModel extends Model {
  var _sqlService = GetIt.I<SqlService>();

  PhotosLibraryApiModel() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;

      if (_currentUser != null) {
        // Initialize the client with the new user credentials
        client = PhotosLibraryApiClient(_currentUser!.authHeaders);
      } else {
        // Reset the client
        client = null;
      }
      // Reinitialize the albums
      updateAlbums();
      updatePhotoPasDansUnAlbum();

      notifyListeners();
    });
  }

  Future<Album?> createAlbum(String title) async {
    final album =
    await client!.createAlbum(CreateAlbumRequest.fromTitle(title));
    updateAlbums();
    return album;
  }

  final LinkedHashSet<Album> _albums = LinkedHashSet<Album>();
  bool hasAlbums = false;

  final LinkedHashSet<MediaItem> _photoPasDansUnAlbum = LinkedHashSet<MediaItem>();

  PhotosLibraryApiClient? client;

  GoogleSignInAccount? _currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'profile',
    'https://www.googleapis.com/auth/photoslibrary',
    'https://www.googleapis.com/auth/photoslibrary.sharing',
    'https://www.googleapis.com/auth/photoslibrary.edit.appcreateddata'
  ]);
  GoogleSignInAccount? get user => _currentUser;

  bool isLoggedIn() {
    return _currentUser != null;
  }

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<GoogleSignInAccount?> signInSilently() =>
      _googleSignIn.signInSilently();

  Future<void> signOut() => _googleSignIn.disconnect();



Future<Album> getAlbum(String id) async =>
    client!.getAlbum(GetAlbumRequest.defaultOptions(id));

Future<JoinSharedAlbumResponse> joinSharedAlbum(String shareToken) async {
  final response =
      await client!.joinSharedAlbum(JoinSharedAlbumRequest(shareToken));
  updateAlbums();
  return response;
}

Future<ShareAlbumResponse> shareAlbum(String albumId) async {
  final response = await client!.shareAlbum(
      ShareAlbumRequest(albumId, SharedAlbumOptions.fullCollaboration()));

  updateAlbums();
  return response;
}

Future<SearchMediaItemsResponse> searchMediaItems(String? albumId) async =>
    client!.searchMediaItems(SearchMediaItemsRequest.albumId(albumId: albumId, pageSize: 100));

  Future<SearchMediaItemsResponse> searchMediaItems2(String? albumId,String? pageToken) async =>
      client!.searchMediaItems(SearchMediaItemsRequest(albumId: albumId, pageSize: 100, pageToken: pageToken));

  Future<List<MediaItem>> searchAllMediaItems(String? albumId) async {
    List<MediaItem> list = [];
    SearchMediaItemsResponse res = await searchMediaItems(albumId);
    if (res.mediaItems!= null){
      list.addAll(res.mediaItems!);
    }
    while (res.nextPageToken!= null) {
      res = await client!.searchMediaItems(SearchMediaItemsRequest(albumId: albumId, pageSize: 100, pageToken: res.nextPageToken));
      if (res.mediaItems!= null){
        list.addAll(res.mediaItems!);
      }
    }
    return list;

  }


Future<String> uploadMediaItem(File image) {
  return client!.uploadMediaItem(image);
}

  Future<BatchCreateMediaItemsResponse?> createMediaItem(
      String uploadToken, String? albumId, String? description) async {
    // Construct the request with the token, albumId and description.
    final request =
    BatchCreateMediaItemsRequest.inAlbum(uploadToken, albumId, description);

    // Make the API call to create the media item. The response contains a
    // media item.
    final response = await client!.batchCreateMediaItems(request);

    // Print and return the response.
    print(response.newMediaItemResults?[0].toJson());
    return response;
  }

UnmodifiableListView<Album> get albums =>
    UnmodifiableListView<Album>(_albums);

void updateAlbums() async {
  // Reset the flag before loading new albums
  hasAlbums = false;

  // Clear all albums
  _albums.clear();

  // Skip if not signed in
  if (!isLoggedIn()) {
    return;
  }

  // Add albums from the user's Google Photos account
  var ownedAlbums = await _loadAlbums(null);
  if (ownedAlbums.albums != null) {
    _albums.addAll(ownedAlbums.albums!);
  }

  /*
  // Load albums from owned and shared albums
  final list = await Future.wait([_loadSharedAlbums(), _loadAlbums()]);

  _albums.addAll(list.expand((a) => a ?? []));
  */

  notifyListeners();
  hasAlbums = true;
}

  UnmodifiableListView<MediaItem> get photoPasDansUnAlbum =>
      UnmodifiableListView<MediaItem>(_photoPasDansUnAlbum);

  void updatePhotoPasDansUnAlbum() async {
    List<Album> albumLocal =[];
    // Reset the flag before loading new albums

    List<MediaItem> photoDansAlbum = [];


    // Clear all albums
    _photoPasDansUnAlbum.clear();

    // Skip if not signed in
    if (!isLoggedIn()) {
      return;
    }

    // Add albums from the user's Google Photos account
    var ownedAlbums = await _loadAllAlbums();
    albumLocal.addAll(ownedAlbums);

    print("***********nb Album: " + ownedAlbums.length.toString());
    //ownedAlbums.forEach((element) => print(element.toStringCsv()));

    var sharedAlbum = await _loadAllSharedAlbums();
    for (var element in sharedAlbum) {
      if(!albumLocal.contains(element)){
        albumLocal.add(element);
      }
    }

    print("***********nb Album partage : " + sharedAlbum.length.toString());
    //sharedAlbum.forEach((element) => print(element.toStringCsv()));

    print("***********nb total album : " + albumLocal.length.toString());
    albumLocal.forEach((element) => print(element.toStringCsv()));

    List<Album> diffAlbum = [];
    albumLocal.forEach((element) {
      if(!sharedAlbum.contains(element) || ! ownedAlbums.contains(element)){
        diffAlbum.add(element);
      }
    });
    print("***********nb Album diff : " + diffAlbum.length.toString());
    diffAlbum.forEach((element) => print(element.toStringCsv()));



    // // // Load albums from owned and shared albums
    // // final list = await Future.wait([_loadSharedAlbums(), _loadAlbums()]);
    // //
    // // _albums.addAll(list.expand((a) => a ?? []));
    //
    // int nbPhotoDansAlbum = 0;
    // int index = 0;
    //
    // for (Album a in albumLocal){
    //   index ++;
    //   String nbPhotoAlbum = a.mediaItemsCount!=null? a.mediaItemsCount! :"0";
    //   String titreAlbum = a.title!=null? a.title! :"Sans titre";
    //   nbPhotoDansAlbum += int.parse(nbPhotoAlbum);
    //   List<MediaItem> l = await searchAllMediaItems(a.id);
    //   print("Chargement photo album "+ index.toString() +"/"+ albumLocal.length.toString() +": "+ titreAlbum + "; nb photo : " +  nbPhotoAlbum + "; nb photo charges : " +  l.length.toString());
    //   if (l != null){
    //     photoDansAlbum.addAll(l );
    //     // l.forEach((element) {
    //     //   print("---" + element.id + element.baseUrl.toString() + element.baseUrl.toString());
    //     // });
    //   }
    // }
    //
    // print("nbPhotoDansAlbumCharge : " + photoDansAlbum.length.toString());
    
    // List<MediaItem> toutPhoto = await _loadAllPhoto();
    //
    // print("nb Photo total : " + toutPhoto.length.toString());
    // if(toutPhoto!= null){
    //   toutPhoto.forEach((element) {
    //     if (!photoDansAlbum.contains(element)){
    //       _photoPasDansUnAlbum.add(element);
    //     }
    //   });
    // }
    //
    // print("nb Photo Pas dans album : " + _photoPasDansUnAlbum.length.toString());

    notifyListeners();
  }


/// Load Albums into the model by retrieving the list of all albums shared
/// with the user.
// ignore: unused_element
Future<ListSharedAlbumsResponse> _loadSharedAlbums(String? nextPageToken) {
  return client!.listSharedAlbums(nextPageToken).then(
    (ListSharedAlbumsResponse response) {
      return response;
    },
  );
}

  /// Load Albums into the model by retrieving the list of all albums shared
  /// with the user.
// ignore: unused_element
  Future<List<Album>> _loadAllSharedAlbums() async{
    List<Album> list = [];
    ListSharedAlbumsResponse res = await _loadSharedAlbums(null);
    if (res.sharedAlbums!= null){
      list.addAll(res.sharedAlbums!);
    }
    while(res.nextPageToken!= null){
      res = await _loadSharedAlbums(res.nextPageToken);
      if (res.sharedAlbums!= null){
        list.addAll(res.sharedAlbums!);
      }
    }
    return list;
  }

  /// Load all photo
  /// with the user.
// ignore: unused_element
  Future<SearchMediaItemsResponse> _loadPageAllPhoto(String? pageToken) async  {
    var res = await  client!.listAllPhoto(pageToken);
    return res;
  }

  /// Load all photo
  /// with the user.
// ignore: unused_element
  Future<List<MediaItem>> _loadAllPhoto() async  {
    List<MediaItem> list = [];
    SearchMediaItemsResponse res = await _loadPageAllPhoto(null);
    if (res.mediaItems!= null) {
      list.addAll( res.mediaItems!);
    }
    while( res.nextPageToken!= null){
      res = await _loadPageAllPhoto(res.nextPageToken);
      if (res.mediaItems!= null) {
        list.addAll( res.mediaItems!);
      }
    }
    return list;
  }

/// Load albums into the model by retrieving the list of all albums owned
/// by the user.
Future<ListAlbumsResponse> _loadAlbums(String? pageToken) async {
  ListAlbumsResponse res = await client!.listAlbums(pageToken);
  return res;

}

  /// Load albums into the model by retrieving the list of all albums owned
  /// by the user.
  Future<List<Album>> _loadAllAlbums() async {
    List<Album> list = [];
    ListAlbumsResponse res = await _loadAlbums(null);
    if (res.albums!= null) {
      list.addAll( res.albums!);
    }
    while( res.nextPageToken!= null){
      res = await _loadAlbums(res.nextPageToken);
      if (res.albums != null) {
        list.addAll(res.albums!);
      }
    }
    return list;
  }

  bool isReloadAlbumEnCours = false;
  bool isReloadMediaEnCours = false;

  String toString2(String? element) {
    return (element != null) ? element : "";
  }

  void createNewAlbum() {
    for (String albumName in albumACreer) {
      print("Creation album: " + albumName);
      createAlbum(albumName);
    }
  }


 //Ne fonctionne pas renvoie une 400 pour une raison inconnue
  void renameAlbum() async {

    // for (RenameAlbum album in listeAlbumRenomer){
    //   client!.renameAlbum(RenameAlbumRequest(album.newTitle), album.id);
    // }

    client!.renameAlbum(listeAlbumRenomer[0]);

  }

  void reloadAlbum() async {
    isReloadAlbumEnCours = true;
    List<Album> albumList =[];
    // Skip if not signed in
    if (!isLoggedIn()) {
      return;
    }

    // Add albums from the user's Google Photos account
    var ownedAlbums = await _loadAllAlbums();
    albumList.addAll(ownedAlbums);

    var sharedAlbum = await _loadAllSharedAlbums();
    for (var element in sharedAlbum) {
      if (!albumList.contains(element)) {
        albumList.add(element);
      }
    }

    _sqlService.removeAlbum();
    _sqlService.insertListAlbum(albumList);

    isReloadAlbumEnCours = false;
  }

  void reloadMedia() async {
    isReloadMediaEnCours = true;
    List<Album> albumList = [];
    // Skip if not signed in
    if (!isLoggedIn()) {
      return;
    }
    print("Recuperation des albums en base de données");
    List<sql.Album> listAlbum = await _sqlService.albums();
    print("Nb d'album recupere" + listAlbum.length.toString());

    List<MediaItem> toutPhotoAlbum = [];
    int index = 0;
    print("Chargement des photo par album");
    for (sql.Album a in listAlbum) {
      print("album " + index.toString() + "/" + listAlbum.length.toString());
      index++;
      List<MediaItem> l = await searchAllMediaItems(a.id);
      toutPhotoAlbum.addAll(l);
    }
    print("Fin de chargement des photo par album");

    print("Chargement de toutes les photos");
    List<MediaItem> toutPhoto = await _loadAllPhoto();
    List<sql.MediaItem> toutPhotoSql = toutPhoto
        .map((e) => sql.MediaItem.fromDto2(e, toutPhotoAlbum.contains(e)))
        .toList();
    print("Fin chargement de toutes les photo");

    _sqlService.removeMedia();
    _sqlService.insertListMedia(toutPhotoSql);

    isReloadMediaEnCours = false;
  }

  Future<List<sql.MediaItem>> listPhotoNotInAlbum() async {
    return (await _sqlService.mediaItems())
        .where((element) => element.isInAlbum == 0)
        .toList();
  }

  Future<MediaItem> getMediaItem(String id) async =>
      client!.getMediaItems(GetMediaItemRequest.defaultOptions(id));

  //Google ne laisse pas ajouter de photo a un album qui n'as pas ete creer par l'appli ...
  //TODO recreer tout les album par l'appli ?
  Future<void> addMediaToAlbum(String id, sql.Album newValue) async {
    return client!.addMediaToAlbum(AddMediaAlbumRequest(newValue.id, ["\"" + id + "\","] ));
  }
}
