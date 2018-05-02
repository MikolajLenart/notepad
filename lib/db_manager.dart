import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final String TABLE_NAME = "notes";
final String ID = "_id";
final String TITLE = "title";
final String DESCRIPTION = "description";

class DbManager {

  Database _database;

  Future openDb() async {
    if (_database == null) {
      Directory directory = await getApplicationDocumentsDirectory();
      _database = await openDatabase(
          join(directory.path, "notes.db"),
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''create table $TABLE_NAME ( 
          $ID integer primary key autoincrement, 
          $TITLE text not null,
          $DESCRIPTION text not null)''');
          });
    }
  }

  Future<int> insertNote(Note note) async {
    return await _database.insert(TABLE_NAME, note.toMap());
  }

  Future<List<Note>> getNotes() async {
    await openDb();
    List<Map> entities = await _database.rawQuery("select * from $TABLE_NAME");
    return entities
        .map((map) => new Note.fromMap(map))
        .toList();
  }

  Future deleteNote(int id) async {
    await openDb();
    await _database.delete(TABLE_NAME, where: "$ID = ?", whereArgs: [id]);
  }

  Future updateNote(Note note) async {
    await openDb();
    await _database.update(TABLE_NAME, note.toMap(), where: "$ID = ?", whereArgs: [note.id]);
  }

  closeDb() {
    _database.close();
  }
}

class Note {

  int id;
  String title;
  String descritpion;

  Note({@required this.title, @required this.descritpion, this.id});

  Map<String, String> toMap() {
    Map<String, String> map = {TITLE: title, DESCRIPTION: descritpion};
    return map;
  }

  Note.fromMap(Map map){
    id = map[ID];
    title = map[TITLE];
    descritpion = map[DESCRIPTION];
  }

  @override
  bool operator ==(other) {
    return other is Note && other.title == title && other.descritpion == descritpion && other.id == id;
  }
}