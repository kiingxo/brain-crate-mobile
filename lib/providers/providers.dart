import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_helper.dart';
import '../services/document_service.dart';
import '../models/document.dart';
import '../models/tutorial_session_state.dart';

part 'providers.g.dart';

@riverpod
DatabaseHelper databaseHelper( Ref ref) {
  return DatabaseHelper();
}

@riverpod
DocumentService documentService(Ref ref) {
  return DocumentService();
}

@riverpod
class DocumentsNotifier extends _$DocumentsNotifier {
  @override
  Future<List<Document>> build() async {
    final dbHelper = ref.read(databaseHelperProvider);
    return await dbHelper.getAllDocuments();
  }

  Future<void> addDocument(Document document) async {
    final dbHelper = ref.read(databaseHelperProvider);
    await dbHelper.insertDocument(document);
    ref.invalidateSelf();
  }

  Future<void> deleteDocument(String id) async {
    final dbHelper = ref.read(databaseHelperProvider);
    await dbHelper.deleteDocument(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class CoursesNotifier extends _$CoursesNotifier {
  @override
  Future<List<String>> build() async {
    final dbHelper = ref.read(databaseHelperProvider);
    return await dbHelper.getAllCourses();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class SelectedCourseNotifier extends _$SelectedCourseNotifier {
  @override
  String? build() {
    return null;
  }

  void setCourse(String? course) {
    state = course;
  }
}

@riverpod
class TutorialSessionNotifier extends _$TutorialSessionNotifier {
  @override
  TutorialSessionState build() {
    return const TutorialSessionState();
  }

  void selectDocument(String documentId) {
    final currentSelection = state.selectedDocumentIds.toSet();
    currentSelection.add(documentId);
    state = state.copyWith(selectedDocumentIds: currentSelection);
  }

  void deselectDocument(String documentId) {
    final currentSelection = state.selectedDocumentIds.toSet();
    currentSelection.remove(documentId);
    state = state.copyWith(selectedDocumentIds: currentSelection);
  }

  void clearSelection() {
    state = state.copyWith(selectedDocumentIds: {});
  }

  void startSession() {
    state = state.copyWith(isActive: true);
  }

  void endSession() {
    state = state.copyWith(isActive: false, selectedDocumentIds: {});
  }

  List<Document> getSelectedDocuments(List<Document> allDocuments) {
    return allDocuments.where((doc) => state.selectedDocumentIds.contains(doc.id)).toList();
  }
}

@riverpod
List<Document> filteredDocuments(Ref ref) {
  final documentsAsync = ref.watch(documentsNotifierProvider);
  final selectedCourse = ref.watch(selectedCourseNotifierProvider);
  
  return documentsAsync.when(
    data: (documents) {
      if (selectedCourse == null) {
        return documents;
      }
      return documents.where((doc) => doc.course == selectedCourse).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<Document> selectedDocumentsForSession(Ref ref) {
  final sessionState = ref.watch(tutorialSessionNotifierProvider);
  final documentsAsync = ref.watch(documentsNotifierProvider);
  
  return documentsAsync.when(
    data: (documents) {
      return documents.where((doc) => sessionState.selectedDocumentIds.contains(doc.id)).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}