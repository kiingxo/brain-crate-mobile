import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document.dart';
import '../providers/providers.dart';
import '../services/document_service.dart';
import '../widgets/add_document_dialog.dart';
import '../widgets/document_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsNotifierProvider);
    final coursesAsync = ref.watch(coursesNotifierProvider);
    final selectedCourse = ref.watch(selectedCourseNotifierProvider);
    final filteredDocs = ref.watch(filteredDocumentsProvider);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Library',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _addDocument,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Course filter dropdown
                coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) return const SizedBox.shrink();
                    return DropdownButtonFormField<String>(
                      value: selectedCourse,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Course',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Courses'),
                        ),
                        ...courses.map((course) => DropdownMenuItem<String>(
                          value: course,
                          child: Text(course),
                        )),
                      ],
                      onChanged: (value) {
                        ref.read(selectedCourseNotifierProvider.notifier).setCourse(value);
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading courses: $error'),
                ),
              ],
            ),
          ),
          
          // Documents list
          Expanded(
            child: documentsAsync.when(
              data: (documents) => filteredDocs.isEmpty
                  ? _buildEmptyState(selectedCourse)
                  : _buildDocumentsList(filteredDocs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading documents',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(documentsNotifierProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDocument() async {
    try {
      final document = await _documentService.pickAndSaveDocument();
      if (document != null) {
        final result = await showDialog<Map<String, String>>(
          context: context,
          builder: (context) => AddDocumentDialog(document: document),
        );

        if (result != null) {
          final updatedDocument = Document(
            id: document.id,
            name: document.name,
            course: result['course']!,
            topic: result['topic']!,
            filePath: document.filePath,
            fileType: document.fileType,
            dateAdded: document.dateAdded,
            fileSize: document.fileSize,
          );

          await ref.read(documentsNotifierProvider.notifier).addDocument(updatedDocument);
          await ref.read(coursesNotifierProvider.notifier).refresh();
          _showSuccessSnackBar('Document added successfully!');
        } else {
          // User cancelled, delete the copied file
          await _documentService.deleteDocumentFile(document.filePath);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error adding document: $e');
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(documentsNotifierProvider.notifier).deleteDocument(document.id);
        await _documentService.deleteDocumentFile(document.filePath);
        await ref.read(coursesNotifierProvider.notifier).refresh();
        _showSuccessSnackBar('Document deleted successfully!');
      } catch (e) {
        _showErrorSnackBar('Error deleting document: $e');
      }
    }
  }

  Widget _buildEmptyState(String? selectedCourse) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            selectedCourse == null ? 'No documents yet' : 'No documents in this course',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedCourse == null 
                ? 'Tap the + button to add your first document'
                : 'Add documents to this course to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (selectedCourse == null)
            ElevatedButton.icon(
              onPressed: _addDocument,
              icon: const Icon(Icons.add),
              label: const Text('Add Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(List<Document> documents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DocumentCard(
            document: document,
            onDelete: () => _deleteDocument(document),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 