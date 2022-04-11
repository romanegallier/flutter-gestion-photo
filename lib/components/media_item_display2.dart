import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/photos_library_api/media_item.dart';
import 'package:sharing_codelab/sqlModel/album.dart';

import 'media_item_display.dart';

class MediaItemDisplay2 extends StatefulWidget {
  const MediaItemDisplay2({Key? key, required this.id, required this.mediaItem, required this.listAlbum})
      : super(key: key);

  final String id;
  final MediaItem mediaItem;
  final List<Album> listAlbum;

  @override
  State<StatefulWidget> createState() => _MediaItemDisplay2State();
}

class _MediaItemDisplay2State extends State<MediaItemDisplay2> {
  Album? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (BuildContext context, Widget? child,
          PhotosLibraryApiModel photosLibraryApi) {
        return Column(
          children: [
            MediaItemDisplay(mediaItem: widget.mediaItem),
            DropdownButton(
              value: dropdownValue,
              icon: Icon(Icons.keyboard_arrow_down),
              items: widget.listAlbum.map((items) {
                return DropdownMenuItem(value: items, child:Container(
                  width: 300,
                  child:
                 Text(items.title, overflow: TextOverflow.ellipsis,)));
              }).toList(),
              onChanged: (Album? newValue) {
                setState(() {
                  dropdownValue = newValue;
                  photosLibraryApi.addMediaToAlbum(widget.id, newValue!);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
