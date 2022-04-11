import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/media_item_display.dart';
import 'package:sharing_codelab/components/media_item_display2.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/components/trip_app_bar.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/sqlModel/media_item.dart' as sql;
import 'package:sharing_codelab/sqlModel/album.dart' as sql;
import 'package:sharing_codelab/sqlModel/sql_service.dart';



class ListPhotoNotInAlbumPage extends StatefulWidget {
  const ListPhotoNotInAlbumPage({Key? key}) : super(key: key);

  //TODO paginer
  //TODO ecriture de media item creation de transaction
  //TODO problemme ... on peut seulement ajouter des photo creer par l'application dans des albums creer par l'application ...

  @override
  State<ListPhotoNotInAlbumPage> createState() =>
      _ListPhotoNotInAlbumPageState();
}

class _ListPhotoNotInAlbumPageState extends State<ListPhotoNotInAlbumPage> {
  late PhotosLibraryApiModel model;

  late final Future<List<sql.MediaItem>> _listPhoto;
  late final Future<List<sql.Album>> _listAlbum;
  var _sqlService = GetIt.I<SqlService>();

  late int nbPhoto;
  late int nbPhotoNotInAlbum;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TripAppBar(),
      body: _buildTripList(),
    );
  }

  @override
  void initState() {
    _listPhoto = listPhotoNotInAlbum();
    _listAlbum = _sqlService.albums(); //TODO pagination

  }

  Future<List<sql.MediaItem>>listPhotoNotInAlbum() async {
    var l = await _sqlService.mediaItems();
    nbPhoto = l.length;
    var r = l.where((element) => !element.isInAlbum).toList();
    nbPhotoNotInAlbum = r.length;
    return r.sublist(0,10);
  }

  Widget _future(List<sql.Album> listAlbum) {
    return FutureBuilder<List<sql.MediaItem>>(
      future: _listPhoto, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<sql.MediaItem>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          return listMedia(snapshot.data!, listAlbum);
        } else if (snapshot.hasError) {
          return empty();
        } else {
          return error();
        }
      },
    );
  }

  Widget _future2() {
    return FutureBuilder<List<sql.Album>>(
      future: _listAlbum, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<sql.Album>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          return _future(snapshot.data!);
        } else if (snapshot.hasError) {
          return empty();
        } else {
          return error();
        }
      },
    );
  }

  Widget listMedia(List<sql.MediaItem> listMedia, List<sql.Album> listAlbum){
    return ListView.builder(
      itemCount: listMedia.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _buildButtons(context);
        }

        return _buildMediaItem(listMedia[index - 1], listAlbum);
      },
    );
  }

  Widget empty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(Icons.ac_unit),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "You're not currently a member of any trip albums. "
            'Create a new trip album or join an existing one below.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        _buildButtons(context),
      ],
    );
  }

  Widget error() {
    return
         Text(
            "Erreur",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          );

  }

  Widget _buildTripList() {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (BuildContext context, Widget? child,
          PhotosLibraryApiModel photosLibraryApi) {
        model = photosLibraryApi;
        return _future2();
      },
    );
  }

  Widget _buildMediaItem(sql.MediaItem mediaItem, List<sql.Album> listAlbum) {
    String? dropdownValue;
    return FutureBuilder<MediaItem>(
        future: model.getMediaItem(mediaItem.id),
        builder: (BuildContext context, AsyncSnapshot<MediaItem> snapshot) {
    if(snapshot.hasData){
      return MediaItemDisplay2(id: mediaItem.id,mediaItem: snapshot.data!, listAlbum: listAlbum,);
    }
    return Container();
    }
    );
  }



  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(nbPhoto.toString()),
          Text(nbPhotoNotInAlbum.toString())
        ],
      ),
    );
}

  Widget _buildSharedIcon(Album album) {
    if (album.shareInfo != null) {
      return const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(
            Icons.folder_shared,
            color: Colors.black38,
          ));
    } else {
      return Container();
    }
  }
}
