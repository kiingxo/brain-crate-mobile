import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document.dart';
import '../providers/providers.dart';
import '../widgets/document_selection_card.dart';

class AddMaterialsDialog extends ConsumerStatefulWidget {
  const AddMaterialsDialog({super.key});

  @override
  ConsumerState<AddMaterialsDialog> createState() => _AddMaterialsDialogState();
}

class _AddMaterialsDialogState extends ConsumerState<AddMaterialsDialog> {
  String? _selectedCourse;

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsNotifierProvider);
    final coursesAsync = ref.watch(coursesNotifierProvider);
    final filteredDocs = ref.watch(filteredDocumentsProvider);
    final sessionState = ref.watch(tutorialSessionNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Materials for AI Tutor',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Select documents that the AI tutor will use to answer your questions',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Course filter
            coursesAsync.when(
              data: (courses) {
                if (courses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No documents in your library yet. Add some documents first!',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  value: _selectedCourse,
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
                    setState(() {
                      _selectedCourse = value;
                    });
                    ref.read(selectedCourseNotifierProvider.notifier).setCourse(value);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading courses: $error'),
            ),
            
            const SizedBox(height: 16),
            
            // Selected materials summary
            if (sessionState.selectedDocumentIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${sessionState.selectedDocumentIds.length} material${sessionState.selectedDocumentIds.length == 1 ? '' : 's'} selected',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(tutorialSessionNotifierProvider.notifier).clearSelection(),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Documents list
            Expanded(
              child: documentsAsync.when(
                data: (documents) {
                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_books,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCourse == null 
                                ? 'No documents in your library'
                                : 'No documents in this course',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedCourse == null
                                ? 'Add documents to your library first'
                                : 'Add documents to this course first',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final document = filteredDocs[index];
                      final isSelected = sessionState.selectedDocumentIds.contains(document.id);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DocumentSelectionCard(
                          document: document,
                          isSelected: isSelected,
                          onTap: () => _toggleDocumentSelection(document.id),
                        ),
                      );
                    },
                  );
                },
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
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: sessionState.selectedDocumentIds.isNotEmpty
                        ? () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${sessionState.selectedDocumentIds.length} material(s) added to AI tutor'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Materials'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDocumentSelection(String documentId) {
    final sessionNotifier = ref.read(tutorialSessionNotifierProvider.notifier);
    final sessionState = ref.read(tutorialSessionNotifierProvider);
    
    if (sessionState.selectedDocumentIds.contains(documentId)) {
      sessionNotifier.deselectDocument(documentId);
    } else {
      sessionNotifier.selectDocument(documentId);
    }
  }
} 