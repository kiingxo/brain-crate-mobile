# Brain Crate

A Flutter study app: build a library of course documents, then choose which ones an AI tutor uses to answer your questions.

## Features (in `lib/`)
- **Library**: import PDF, DOC and DOCX files (`file_picker`), store them locally, and keep their metadata in SQLite (`sqflite`)
- **AI Tutor**: a chat screen where you pick study materials to give the tutor context
- State management with Riverpod (`riverpod_generator`)

## Structure
```
lib/
  models/     document, tutorial session state
  providers/  Riverpod providers
  screens/    library_screen, tutor_screen
  services/   database_helper, document_service
  widgets/    chat message, document cards, dialogs
```

## Run
```bash
flutter pub get
dart run build_runner build
flutter run
```

Status: prototype.
