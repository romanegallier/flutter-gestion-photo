import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/components/primary_raised_button.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/components/trip_app_bar.dart';
import 'package:sharing_codelab/pages/list_photo_not_in_album.dart';
import 'package:sharing_codelab/pages/trip_page.dart';
import 'package:sharing_codelab/photos_library_api/album.dart';


class TripListPage extends StatelessWidget {
  const TripListPage({Key? key}) : super(key: key);

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



            if (!photosLibraryApi.hasAlbums) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (photosLibraryApi.albums.isEmpty) {
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
              itemCount: photosLibraryApi.albums.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _buildButtons(context);
                }

                return _buildTripCard(
                    context, photosLibraryApi.albums[index - 1], photosLibraryApi);
              },
            );
      },
    );
  }

Widget _buildTripCard(BuildContext context, Album sharedAlbum,
    PhotosLibraryApiModel photosLibraryApi) {
  return Card(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    elevation: 3,
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 33,
    ),
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => TripPage(
            album: sharedAlbum,
            searchResponse: photosLibraryApi.searchMediaItems(sharedAlbum.id),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            child: _buildTripThumbnail(sharedAlbum),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              _buildSharedIcon(sharedAlbum),
              Flexible(
                child: Align(
                  alignment: const FractionalOffset(0, 0.5),
                  child: Text(
                    sharedAlbum.title ?? '[no title]',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              )

            ]),
          ),
        ],
      ),
    ),
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
        PrimaryRaisedButton(

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const ListPhotoNotInAlbumPage(),
              ),
            );
          },
          label: const Text('VIEW PHOTO NOT IN ALBUM'),
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
