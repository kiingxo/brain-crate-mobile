import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/database_helper.dart';
import '../services/document_service.dart';
import '../models/document.dart';

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