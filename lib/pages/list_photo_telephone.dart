import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_gallery/photo_gallery.dart' as tel;
import 'package:photo_gallery/photo_gallery.dart';
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



class ListPhotoTelephonePage extends StatefulWidget {
  const ListPhotoTelephonePage({Key? key}) : super(key: key);


  @override
  State<ListPhotoTelephonePage> createState() =>
      _ListPhotoNotInAlbumPageState();
}

class _ListPhotoNotInAlbumPageState extends State<ListPhotoTelephonePage> {
  late PhotosLibraryApiModel model;

  late final Future<List<tel.Album>> _listAlbum;
  var _sqlService = GetIt.I<SqlService>();




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
    _listAlbum = PhotoGallery.listAlbums(
      mediumType: mediumType.image,
    );

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







class AlbumPage extends StatefulWidget {
  final Album album;

  AlbumPage(Album album) : album = album;

  @override
  State<StatefulWidget> createState() => AlbumPageState();
}

class AlbumPageState extends State<AlbumPage> {
  List<Medium>? _media;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    MediaPage mediaPage = await widget.album.listMedia();
    setState(() {
      _media = mediaPage.items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.album.name ?? "Unnamed Album"),
        ),
        body: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          children: <Widget>[
            ...?_media?.map(
                  (medium) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ViewerPage(medium))),
                child: Container(
                  color: Colors.grey[300],
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: MemoryImage(kTransparentImage),
                    image: ThumbnailProvider(
                      mediumId: medium.id,
                      mediumType: medium.mediumType,
                      highQuality: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewerPage extends StatelessWidget {
  final Medium medium;

  ViewerPage(Medium medium) : medium = medium;

  @override
  Widget build(BuildContext context) {
    DateTime? date = medium.creationDate ?? medium.modifiedDate;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: date != null ? Text(date.toLocal().toString()) : null,
        ),
        body: Container(
          alignment: Alignment.center,
          child: medium.mediumType == MediumType.image
              ? FadeInImage(
            fit: BoxFit.cover,
            placeholder: MemoryImage(kTransparentImage),
            image: PhotoProvider(mediumId: medium.id),
          )
              : VideoProvider(
            mediumId: medium.id,
          ),
        ),
      ),
    );
  }
}

class VideoProvider extends StatefulWidget {
  final String mediumId;

  const VideoProvider({
    required this.mediumId,
  });

  @override
  _VideoProviderState createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  VideoPlayerController? _controller;
  File? _file;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);
      _controller = VideoPlayerController.file(_file!);
      _controller?.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null || !_controller!.value.isInitialized
        ? Container()
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        FlatButton(
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying
                  ? _controller!.pause()
                  : _controller!.play();
            });
          },
          child: Icon(
            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ],
    );
  }
}
