import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final Uuid _uuid = const Uuid();

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<Document?> pickAndSaveDocument() async {
    try {
      // Request permissions first
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();
        final fileExtension = fileName.split('.').last.toLowerCase();

        // Validate file type
        if (!['pdf', 'doc', 'docx'].contains(fileExtension)) {
          throw Exception('Unsupported file type. Please select PDF or Word documents only.');
        }

        // Get app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final documentsDir = Directory('${appDir.path}/documents');
        if (!await documentsDir.exists()) {
          await documentsDir.create(recursive: true);
        }

        // Generate unique filename
        final uniqueFileName = '${_uuid.v4()}_$fileName';
        final destinationPath = '${documentsDir.path}/$uniqueFileName';

        // Copy file to app directory
        await file.copy(destinationPath);

        // Create document object
        return Document(
          id: _uuid.v4(),
          name: fileName,
          course: '', // Will be set by user
          topic: '', // Will be set by user
          filePath: destinationPath,
          fileType: fileExtension,
          dateAdded: DateTime.now(),
          fileSize: fileSize,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error picking document: $e');
    }
  }

  Future<void> deleteDocumentFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      default:
        return '📄';
    }
  }
} 