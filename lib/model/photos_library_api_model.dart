

import 'dart:collection';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/photos_library_api/photos_library_api_client.dart';


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
      //updateAlbums();//TODO remetre

      notifyListeners();
    });
  }

  //final LinkedHashSet<Album> _albums = LinkedHashSet<Album>();
  bool hasAlbums = false;
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

// Future<SearchMediaItemsResponse> searchMediaItems(String? albumId) async =>
//     client!.searchMediaItems(SearchMediaItemsRequest.albumId(albumId));

// Future<String> uploadMediaItem(File image) {
//   return client!.uploadMediaItem(image);
// }

// Future<BatchCreateMediaItemsResponse?> createMediaItem(
//     String uploadToken, String? albumId, String? description) async {
//   // TODO(codelab): Implement this method.
//
//   return null;
//
//   // Construct the request with the token, albumId and description.
//
//   // Make the API call to create the media item. The response contains a
//   // media item.
// }

// UnmodifiableListView<Album> get albums =>
//     UnmodifiableListView<Album>(_albums);

// void updateAlbums() async {
//   // Reset the flag before loading new albums
//   hasAlbums = false;
//
//   // Clear all albums
//   _albums.clear();
//
//   // Skip if not signed in
//   if (!isLoggedIn()) {
//     return;
//   }
//
//   // Add albums from the user's Google Photos account
//   var ownedAlbums = await _loadAlbums();
//   if (ownedAlbums != null) {
//     _albums.addAll(ownedAlbums);
//   }
//
//   /*
//   // Load albums from owned and shared albums
//   final list = await Future.wait([_loadSharedAlbums(), _loadAlbums()]);
//
//   _albums.addAll(list.expand((a) => a ?? []));
//   */
//
//   notifyListeners();
//   hasAlbums = true;
// }

// /// Load Albums into the model by retrieving the list of all albums shared
// /// with the user.
// // ignore: unused_element
// Future<List<Album>?> _loadSharedAlbums() {
//   return client!.listSharedAlbums().then(
//     (ListSharedAlbumsResponse response) {
//       return response.sharedAlbums;
//     },
//   );
// }

// /// Load albums into the model by retrieving the list of all albums owned
// /// by the user.
// Future<List<Album>?> _loadAlbums() {
//   return client!.listAlbums().then(
//     (ListAlbumsResponse response) {
//       return response.albums;
//     },
//   );
// }
}
