import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document.dart';
import '../providers/providers.dart';
import '../widgets/chat_message.dart';
import '../widgets/add_materials_dialog.dart';

class TutorScreen extends ConsumerStatefulWidget {
  const TutorScreen({super.key});

  @override
  ConsumerState<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends ConsumerState<TutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: "Hello! I'm your AI tutor. I'm here to help you learn. You can ask me questions about your course materials, and I'll use the documents you've selected to provide personalized answers. To get started, tap the 'Add Materials' button to select your study resources.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(tutorialSessionNotifierProvider);
    final selectedDocuments = ref.watch(selectedDocumentsForSessionProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header with materials info
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Tutor',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedDocuments.isEmpty 
                              ? 'No materials selected'
                              : '${selectedDocuments.length} material${selectedDocuments.length == 1 ? '' : 's'} loaded',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddMaterialsDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Materials'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                // Selected materials preview
                if (selectedDocuments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.library_books, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Active Materials:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: selectedDocuments.take(3).map((doc) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              doc.name,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                        ),
                        if (selectedDocuments.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+${selectedDocuments.length - 3} more',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const ChatMessage(
                    text: "AI is typing...",
                    isUser: false,
                    isTyping: true,
                    timestamp: null,
                  );
                }
                return _messages[index];
              },
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: selectedDocuments.isEmpty 
                          ? 'Add materials first to start chatting...'
                          : 'Ask me anything about your materials...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabled: selectedDocuments.isNotEmpty,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: selectedDocuments.isNotEmpty ? (value) => _sendMessage() : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: selectedDocuments.isNotEmpty ? _sendMessage : null,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: selectedDocuments.isNotEmpty ? Colors.blue : Colors.grey[300],
                    foregroundColor: selectedDocuments.isNotEmpty ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialsDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddMaterialsDialog(),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    _messages.add(
      ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response (replace with actual AI integration)
    _simulateAIResponse(message);
  }

  void _simulateAIResponse(String userMessage) {
    setState(() {
      _isTyping = true;
    });

    // Simulate typing delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        
        // Add AI response (replace with actual AI response)
        _messages.add(
          ChatMessage(
            text: _generateAIResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      
      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    final selectedDocuments = ref.read(selectedDocumentsForSessionProvider);
    
    if (selectedDocuments.isEmpty) {
      return "I don't have any materials to work with yet. Please add some documents first so I can help you with your questions.";
    }

    // Simple response generation (replace with actual AI integration)
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! I'm ready to help you with your studies. I have access to ${selectedDocuments.length} document(s) that I can use to answer your questions.";
    } else if (lowerMessage.contains('help') || lowerMessage.contains('what can you do')) {
      return "I can help you understand concepts from your materials, answer questions, explain topics, and provide examples. Just ask me anything about the content in your selected documents!";
    } else if (lowerMessage.contains('materials') || lowerMessage.contains('documents')) {
      final materialNames = selectedDocuments.map((doc) => doc.name).join(', ');
      return "I'm currently working with these materials: $materialNames. You can ask me questions about any of these topics.";
    } else {
      return "That's an interesting question! Based on the materials you've provided, I can help you understand this topic. Could you be more specific about what aspect you'd like me to explain?";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
} 