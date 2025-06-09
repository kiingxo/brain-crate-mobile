// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHelperHash() => r'd9a91b257d3ed9a4f2d87bd829e17dc900678685';

/// See also [databaseHelper].
@ProviderFor(databaseHelper)
final databaseHelperProvider = AutoDisposeProvider<DatabaseHelper>.internal(
  databaseHelper,
  name: r'databaseHelperProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$databaseHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseHelperRef = AutoDisposeProviderRef<DatabaseHelper>;
String _$documentServiceHash() => r'f03445cbb72dc326047d7aa39a340b5be8040446';

/// See also [documentService].
@ProviderFor(documentService)
final documentServiceProvider = AutoDisposeProvider<DocumentService>.internal(
  documentService,
  name: r'documentServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$documentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DocumentServiceRef = AutoDisposeProviderRef<DocumentService>;
String _$filteredDocumentsHash() => r'68261cea706a9f204f3d891015b6d9f4cbba5720';

/// See also [filteredDocuments].
@ProviderFor(filteredDocuments)
final filteredDocumentsProvider = AutoDisposeProvider<List<Document>>.internal(
  filteredDocuments,
  name: r'filteredDocumentsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredDocumentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredDocumentsRef = AutoDisposeProviderRef<List<Document>>;
String _$documentsNotifierHash() => r'5bdf80c70cfaadff07f4a5a034d2eb432e7355ab';

/// See also [DocumentsNotifier].
@ProviderFor(DocumentsNotifier)
final documentsNotifierProvider = AutoDisposeAsyncNotifierProvider<
  DocumentsNotifier,
  List<Document>
>.internal(
  DocumentsNotifier.new,
  name: r'documentsNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$documentsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DocumentsNotifier = AutoDisposeAsyncNotifier<List<Document>>;
String _$coursesNotifierHash() => r'd46919f36c48beb6e6558d64b77e2d13508483da';

/// See also [CoursesNotifier].
@ProviderFor(CoursesNotifier)
final coursesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CoursesNotifier, List<String>>.internal(
      CoursesNotifier.new,
      name: r'coursesNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$coursesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CoursesNotifier = AutoDisposeAsyncNotifier<List<String>>;
String _$selectedCourseNotifierHash() =>
    r'cd4c2af9ec35e5eabba2d3c6e24754e28d1b6d71';

/// See also [SelectedCourseNotifier].
@ProviderFor(SelectedCourseNotifier)
final selectedCourseNotifierProvider =
    AutoDisposeNotifierProvider<SelectedCourseNotifier, String?>.internal(
      SelectedCourseNotifier.new,
      name: r'selectedCourseNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedCourseNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCourseNotifier = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
