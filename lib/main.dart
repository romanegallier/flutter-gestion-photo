import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/model/photos_library_api_model.dart';
import 'package:sharing_codelab/pages/home_page.dart';
import 'package:sharing_codelab/sqlModel/sql_service.dart';
import 'package:sharing_codelab/sqlModel/sql_service_impl.dart';

void main() {
  /** Initialisation des services */
  GetIt.instance.registerSingleton<SqlService>(SqlServiceImpl());

  final apiModel = PhotosLibraryApiModel();
  apiModel.signInSilently();
  testDataBase();

  runApp(
    ScopedModel<PhotosLibraryApiModel>(
      model: apiModel,
      child: MyApp(),
    ),
  );
}

void testDataBase() async {
  final _sqlService = GetIt.I.get<SqlService>();
  await _sqlService.createDogTable();
  _sqlService.test();
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Trippa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}




class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Album>? _albums;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      List<Album> albums =
      await PhotoGallery.listAlbums(mediumType: MediumType.image);
      setState(() {
        _albums = albums;
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS &&
        await Permission.storage.request().isGranted &&
        await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Photo gallery example'),
        ),
        body: _loading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            double gridWidth = (constraints.maxWidth - 20) / 3;
            double gridHeight = gridWidth + 33;
            double ratio = gridWidth / gridHeight;
            return Container(
              padding: EdgeInsets.all(5),
              child: GridView.count(
                childAspectRatio: ratio,
                crossAxisCount: 3,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                children: <Widget>[
                  ...?_albums?.map(
                        (album) => GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AlbumPage(album))),
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Container(
                              color: Colors.grey[300],
                              height: gridWidth,
                              width: gridWidth,
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                placeholder:
                                MemoryImage(kTransparentImage),
                                image: AlbumThumbnailProvider(
                                  albumId: album.id,
                                  mediumType: album.mediumType,
                                  highQuality: true,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              album.name ?? "Unnamed Album",
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                height: 1.2,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.only(left: 2.0),
                            child: Text(
                              album.count.toString(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                height: 1.2,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


