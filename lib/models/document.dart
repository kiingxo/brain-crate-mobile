class Document {
  final String id;
  final String name;
  final String course;
  final String topic;
  final String filePath;
  final String fileType;
  final DateTime dateAdded;
  final int fileSize;

  Document({
    required this.id,
    required this.name,
    required this.course,
    required this.topic,
    required this.filePath,
    required this.fileType,
    required this.dateAdded,
    required this.fileSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course': course,
      'topic': topic,
      'filePath': filePath,
      'fileType': fileType,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'fileSize': fileSize,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      name: map['name'],
      course: map['course'],
      topic: map['topic'],
      filePath: map['filePath'],
      fileType: map['fileType'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      fileSize: map['fileSize'],
    );
  }
} 