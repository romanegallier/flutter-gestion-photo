

import 'dart:collection';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/batch_create_media_items_response.dart';
import 'package:sharing_codelab/photos_library_api/list_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/list_shared_albums_response.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/photos_library_api/photos_library_api_client.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_request.dart';
import 'package:sharing_codelab/photos_library_api/search_media_items_response.dart';


class PhotosLibraryApiModel extends Model {
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
      //updateAlbums();
      updatePhotoPasDansUnAlbum();

      notifyListeners();
    });
  }

  final LinkedHashSet<Album> _albums = LinkedHashSet<Album>();
  bool hasAlbums = false;

  final LinkedHashSet<MediaItem> _photoPasDansUnAlbum = LinkedHashSet<MediaItem>();
  bool hasPhotoPasDansAlbum = false;

  PhotosLibraryApiClient? client;

  GoogleSignInAccount? _currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'profile',
    'https://www.googleapis.com/auth/photoslibrary',
    'https://www.googleapis.com/auth/photoslibrary.sharing'
  ]);
  GoogleSignInAccount? get user => _currentUser;

  bool isLoggedIn() {
    return _currentUser != null;
  }

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<GoogleSignInAccount?> signInSilently() =>
      _googleSignIn.signInSilently();

  Future<void> signOut() => _googleSignIn.disconnect();

// Future<Album?> createAlbum(String title) async {
//   // TODO(codelab): Implement this call.
//
//   return null;
// }

// Future<Album> getAlbum(String id) async =>
//     client!.getAlbum(GetAlbumRequest.defaultOptions(id));
//
// Future<JoinSharedAlbumResponse> joinSharedAlbum(String shareToken) async {
//   final response =
//       await client!.joinSharedAlbum(JoinSharedAlbumRequest(shareToken));
//   updateAlbums();
//   return response;
// }
//
// Future<ShareAlbumResponse> shareAlbum(String albumId) async {
//   final response = await client!.shareAlbum(
//       ShareAlbumRequest(albumId, SharedAlbumOptions.fullCollaboration()));
//
//   updateAlbums();
//   return response;
// }

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


// Future<String> uploadMediaItem(File image) {
//   return client!.uploadMediaItem(image);
// }

Future<BatchCreateMediaItemsResponse?> createMediaItem(
    String uploadToken, String? albumId, String? description) async {
  // TODO(codelab): Implement this method.

  return null;

  // Construct the request with the token, albumId and description.

  // Make the API call to create the media item. The response contains a
  // media item.
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
    hasPhotoPasDansAlbum = false;
    List<MediaItem> photoDansAlbum = [];


    // Clear all albums
    _photoPasDansUnAlbum.clear();

    // Skip if not signed in
    if (!isLoggedIn()) {
      return;
    }

    // // Add albums from the user's Google Photos account
    // var ownedAlbums = await _loadAllAlbums();
    // if (ownedAlbums != null) {
    //   albumLocal.addAll(ownedAlbums);
    // }
    // print("***********nb Album: " + ownedAlbums!.length.toString());
    //
    // ownedAlbums.forEach((element) {
    //   var nbItem = element.mediaItemsCount!=null? element.mediaItemsCount! : "0";
    //   print(element.title.toString()+" ; "+ element.id.toString() + " ; "+ nbItem);
    // });
    //
    // var sharedAlbum = await _loadAllSharedAlbums();
    // if (sharedAlbum != null) {
    //   sharedAlbum.forEach((element) {
    //     if(!albumLocal.contains(element)){
    //       albumLocal.add(element);
    //     }
    //   });
    //
    // }
    // print("***********nb Album partage : " + sharedAlbum!.length.toString());
    //
    // sharedAlbum.forEach((element) {
    //   var nbItem = element.mediaItemsCount!=null? element.mediaItemsCount! : "0";
    //   print(element.title.toString()+" ; "+ element.id.toString() + " ; "+ nbItem);
    // });
    //
    // print("***********nb total album : " + albumLocal.length.toString());
    //
    //
    //
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
    
    List<MediaItem> toutPhoto = await _loadAllPhoto();

    print("nb Photo total : " + toutPhoto.length.toString());
    if(toutPhoto!= null){
      toutPhoto.forEach((element) {
        if (!photoDansAlbum.contains(element)){
          _photoPasDansUnAlbum.add(element);
        }
      });
    }

    print("nb Photo Pas dans album : " + _photoPasDansUnAlbum.length.toString());

    hasPhotoPasDansAlbum = true;
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
      if (res.albums!= null) {
        list.addAll( res.albums!);
      }
    }
    return list;

  }
}
