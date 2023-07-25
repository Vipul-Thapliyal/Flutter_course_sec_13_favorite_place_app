import 'dart:io';

import 'package:favorite_place_app_section_13/models/place.dart';

import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(
        dbPath, "places.db"
    ),
    onCreate: (db, version) {
      return db.execute("CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT)");
    },
    version: 1,
  );

  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query("user_places");

    final places = data.map(
      (row) => Place(
        id: row["id"] as String,
        title: row["title"] as String,
        image: File(row["image"] as String)
      )
    ).toList(); /// To Convert this Itterable to List

    state = places;
  }

  void addPlace(String title, File image) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory(); /// Getting systems directory
    final filename = path.basename(image.path); /// Getting name of the file
    final copiedImage = await image.copy("${appDir.path}/$filename"); /// Coo=pying image from sytems directory + filename

    final newPlace = Place(
      title: title,
      image: copiedImage
    );

    final db = await _getDatabase();

    db.insert("user_places", {
      "id": newPlace.id,
      "title": newPlace.title,
      "image": newPlace.image.path,
    });

    state = [newPlace, ...state];
  }
}

final userPlacesProvider = StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier()
);