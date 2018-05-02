import 'package:flutter/material.dart';
import 'package:notepad/db_manager.dart';
import 'package:notepad/note_details_widget.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new NotesList()
    );
  }
}

class NotesList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new NotesListState();
  }
}

class NotesListState extends State<NotesList> {

  final DbManager manager = new DbManager();
  List<Note> notes;

  @override
  void dispose() {
    super.dispose();
    manager.closeDb();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Note>>(
      future: manager.getNotes(),
      builder: (context, snapshot) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Notepad"),
          ),
          body: buildNotesList(snapshot),
          floatingActionButton: new FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (_) => new NoteDetailsWidget(manager))),
              child: new Icon(Icons.add)),
        );
      },
    );
  }

  Widget buildNotesList(AsyncSnapshot<List<Note>> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return new CircularProgressIndicator();
      default:
        if (snapshot.hasError) {
          return new Text("Unexected error occurs: ${snapshot.error}");
        }
        notes = snapshot.data;
        return new ListView.builder(
            itemBuilder: (BuildContext context, int index) => _createItem(index),
            itemCount: notes.length);
    }
  }

  Widget _createItem(int index) {
    return new Dismissible(
      key: new UniqueKey(),
      onDismissed: (direction) {
        manager.deleteNote(notes[index].id)
        .then((dynamic) => print("Deleted!"));
      },
      child: new ListTile(
        title: new Text(notes[index].title),
        subtitle: new Text(notes[index].descritpion.length > 50
            ? notes[index].descritpion.substring(0, 50)
            : notes[index].descritpion),
        onTap: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (_) => new NoteDetailsWidget(manager, note: notes[index])));
        },
      ),
    );
  }
}

