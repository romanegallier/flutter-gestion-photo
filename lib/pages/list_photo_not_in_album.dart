import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/components/trip_app_bar.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';


class ListPhotoNotInAlbumPage extends StatelessWidget {
  const ListPhotoNotInAlbumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TripAppBar(),
      body: _buildTripList(),
    );
  }

  Widget _buildTripList() {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (BuildContext context, Widget? child,
          PhotosLibraryApiModel photosLibraryApi) {



            if (!photosLibraryApi.hasPhotoPasDansAlbum) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (photosLibraryApi.photoPasDansUnAlbum.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                      Icons.ac_unit
                  ),
                  // SvgPicture.asset(
                  //   'assets/ic_fieldTrippa.svg',
                  //   color: Colors.grey[300],
                  //   height: 148,
                  // ),
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

            return ListView.builder(
              itemCount: photosLibraryApi.photoPasDansUnAlbum.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _buildButtons(context);
                }

                return _buildMediaItem(
                     photosLibraryApi.photoPasDansUnAlbum[index - 1]);
              },
            );
      },
    );
  }

  Widget _buildMediaItem(MediaItem mediaItem) {
    return Column(
      children: <Widget>[
        Center(
          child: CachedNetworkImage(
            imageUrl: '${mediaItem.baseUrl}=w364',
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (BuildContext context, String url, Object? error) {
              print(error);
              return const Icon(Icons.error);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 2),
          width: 364,
          child: Text(
            mediaItem.description ?? '',
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

Widget _buildTripThumbnail(Album sharedAlbum) {
  if (sharedAlbum.coverPhotoBaseUrl == null ||
      sharedAlbum.mediaItemsCount == null) {
    return Container(
      height: 160,
      width: 346,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(5),
      child: SvgPicture.asset(
        'assets/ic_fieldTrippa.svg',
        color: Colors.grey[350],
      ),
    );
  }

  return CachedNetworkImage(
    imageUrl: '${sharedAlbum.coverPhotoBaseUrl}=w346-h160-c',
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (BuildContext context, String url, Object? error) {
      print(error);
      return const Icon(Icons.error);
    },
  );
}

Widget _buildButtons(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryRaisedButton(

          // onPressed: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (BuildContext context) => const CreateTripPage(),
          //     ),
          //   );
          // },
          label: const Text('CREATE A TRIP ALBUM'),
        ),

        Container(
          padding: const EdgeInsets.only(top: 10),
          child: const Text(
            ' - or - ',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed:() => {},
          // onPressed: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (BuildContext context) => const JoinTripPage(),
          //     ),
          //   );
          // },
          child: const Text('JOIN A TRIP ALBUM'),
        ),
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
