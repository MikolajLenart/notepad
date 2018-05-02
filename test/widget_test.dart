import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notepad/db_manager.dart';
import 'package:notepad/note_details_widget.dart';

void main() {

  DbManager manager;

  setUp((){
    manager = new MockDbManager();
    when(manager.insertNote(typed<Note>(any))).thenReturn(new Future.value(0));
    when(manager.updateNote(typed<Note>(any))).thenReturn(new Future.value(0));
  });

  testWidgets('Should insert data when note not specified', (WidgetTester tester) async {

    //given
    var noteDetailsWidget = new NoteDetailsWidget(manager);
    await pumpNoteDetailsWidget(noteDetailsWidget, tester);
    await tester.enterText(find.byKey(new Key("description")), "Description");
    await tester.enterText(find.byKey(new Key("title")), "Title");

    //when
    await tester.tap(find.byIcon(Icons.check));

    //then
    verify(manager.insertNote(typed<Note>(argThat(equals(new Note(title: "Title", descritpion: "Description"))))));
  });

  testWidgets('Should update data when note set', (WidgetTester tester) async {

    //given
    Note note = new Note(title: "Title", descritpion: "Description", id: 12);
    var noteDetailsWidget = new NoteDetailsWidget(manager, note: note);
    await pumpNoteDetailsWidget(noteDetailsWidget, tester);

    //when
    await tester.tap(find.byIcon(Icons.check));

    //then
    verify(manager.updateNote(typed<Note>(argThat(equals(new Note(title: "Title", descritpion: "Description", id: 12))))));
  });
}

Future pumpNoteDetailsWidget(NoteDetailsWidget noteDetailsWidget, WidgetTester tester) async {
   Widget testWidget = new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: noteDetailsWidget));
  await tester.pumpWidget(testWidget);
}

class MockDbManager extends Mock implements DbManager {
}
