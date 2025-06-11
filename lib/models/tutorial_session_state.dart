class TutorialSessionState {
  final Set<String> selectedDocumentIds;
  final bool isActive;

  const TutorialSessionState({
    this.selectedDocumentIds = const {},
    this.isActive = false,
  });

  TutorialSessionState copyWith({
    Set<String>? selectedDocumentIds,
    bool? isActive,
  }) {
    return TutorialSessionState(
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorialSessionState &&
        other.selectedDocumentIds == selectedDocumentIds &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => selectedDocumentIds.hashCode ^ isActive.hashCode;

  @override
  String toString() {
    return 'TutorialSessionState(selectedDocumentIds: $selectedDocumentIds, isActive: $isActive)';
  }
} 