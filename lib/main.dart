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


