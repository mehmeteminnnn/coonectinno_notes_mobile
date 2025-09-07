import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectinno_notes/src/state/providers.dart';
import 'package:connectinno_notes/src/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoteEditScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  bool _isSaving = false;
  bool _isLoading = false;
  bool _isAiEnhancing = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  
 final String _openAiKey = 'ApiKeyBurayaGelecek'; 

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _loadNoteIfExists();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNoteIfExists() async {
    if (widget.noteId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final auth = ref.read(authRepoProvider);
      final notesRepo = await ref.read(notesRepoProvider.future);
      final notes = await notesRepo.listNotes(auth.idToken ?? '');
      final note = notes.firstWhere((n) => n.id == widget.noteId);
      
      if (mounted) {
        setState(() {
          _titleController.text = note.title;
          _contentController.text = note.content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Not yüklenirken hata oluştu: $e');
      }
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final auth = ref.read(authRepoProvider);
      final notesRepo = await ref.read(notesRepoProvider.future);
      final token = auth.idToken ?? '';
      
      if (widget.noteId == null) {
        await notesRepo.createNote(
          token,
          title: _titleController.text,
          content: _contentController.text,
        );
      } else {
        await notesRepo.updateNote(
          token,
          widget.noteId!,
          title: _titleController.text,
          content: _contentController.text,
        );
      }
      
      if (!mounted) return;
      Navigator.of(context).pop(true); // Return true to indicate success
      
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Kayıt sırasında hata oluştu: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  
  Future<void> _enhanceWithAI() async {
    if (_contentController.text.isEmpty) return;
    
    setState(() => _isAiEnhancing = true);
    
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that enhances and improves notes. '
                  'Make the note more professional, well-structured, and clear while preserving the original meaning. '
                  'Return only the enhanced note content without any additional text or explanations.'
            },
            {
              'role': 'user',
              'content': _contentController.text,
            },
          ],
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final enhancedContent = data['choices'][0]['message']['content'] as String;
        
        if (mounted) {
          setState(() {
            _contentController.text = enhancedContent;
          });
          _showSuccessSnackBar('Not başarıyla geliştirildi');
        }
      } else {
        throw Exception('AI işlemi başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('AI ile geliştirme başarısız: $e');
      }
    } finally {
      if (mounted) setState(() => _isAiEnhancing = false);
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Yeni Not' : 'Notu Düzenle'),
        actions: [
          if (_contentController.text.isNotEmpty)
            IconButton(
              icon: _isAiEnhancing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              tooltip: 'AI ile Geliştir',
              onPressed: _isAiEnhancing ? null : _enhanceWithAI,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      style: theme.textTheme.titleMedium,
                      decoration: InputDecoration(
                        labelText: 'Başlık',
                        hintText: 'Not başlığını giriniz',
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen bir başlık giriniz';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Content Field
                    Expanded(
                      child: TextFormField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: 'İçerik',
                          hintText: 'Not içeriğinizi yazın...',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen bir içerik giriniz';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        children: [
                          // Save Button
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _saveNote,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // AI Suggestion Chip
                    if (!_isAiEnhancing && _contentController.text.isNotEmpty)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: InkWell(
                          onTap: _enhanceWithAI,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI ile Geliştir',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
