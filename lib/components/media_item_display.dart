import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';

class MediaItemDisplay extends StatelessWidget {

  const MediaItemDisplay({Key? key, required this.mediaItem})
      : super(key: key);

  final MediaItem mediaItem;

  @override
  Widget build(BuildContext context) {
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
            mediaItem.fileName ?? '',
            textAlign: TextAlign.left,
          ),
        ),

      ],
    );
  }

}

