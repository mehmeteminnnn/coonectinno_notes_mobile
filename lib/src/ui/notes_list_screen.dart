import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectinno_notes/src/state/providers.dart';
import 'package:connectinno_notes/src/data/notes_repository.dart';
import 'package:connectinno_notes/src/routes.dart';
import 'package:connectinno_notes/src/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> with SingleTickerProviderStateMixin {
  int _reload = 0;
  bool _isLoading = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
        _focusNode.unfocus();
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_focusNode);
          }
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _reload++);
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Uygulamadan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        final auth = ref.read(authRepoProvider);
        auth.signOut();
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authRepoProvider);
    final notesRepoAsync = ref.watch(notesRepoProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: _isSearching 
                  ? TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: theme.textTheme.titleMedium,
                      decoration: InputDecoration(
                        hintText: 'Notlarda ara...',
                        border: InputBorder.none,
                        hintStyle: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    )
                  : const Text('Notlarım'),
              centerTitle: false,
              floating: true,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Çıkış Yap',
                  onPressed: _handleSignOut,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: notesRepoAsync.when(
            data: (repo) => FutureBuilder<List<NoteDto>>(
              future: Future(() => _reload)
                  .then((_) => repo.listNotes(auth.idToken ?? '')),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data ?? [];
                
                // Filter notes based on search query
                final filteredNotes = _searchQuery.isEmpty
                    ? notes
                    : notes.where((note) {
                        return note.title.toLowerCase().contains(_searchQuery) ||
                            note.content.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty 
                              ? Icons.note_add_outlined 
                              : Icons.search_off_rounded,
                          size: 64,
                          color: theme.colorScheme.outline.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Henüz not yok'
                              : 'Arama sonucu bulunamadı',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"$_searchQuery" için sonuç bulunamadı',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return _buildNoteItem(context, note);
                  },
                );
              },
            ),
            error: (_, __) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Notlar yüklenirken bir hata oluştu',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      floatingActionButton: FadeTransition(
        opacity: _fadeAnimation,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).pushNamed(Routes.edit);
            if (mounted) setState(() => _reload++);
          },
          icon: const Icon(Icons.add),
          label: const Text('Yeni Not'),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, NoteDto note) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = note.updatedAt != null 
        ? dateFormat.format(note.updatedAt! as DateTime)
        : note.createdAt != null 
            ? dateFormat.format(note.createdAt! as DateTime)
            : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).pushNamed(
            Routes.edit,
            arguments: {'id': note.id},
          );
          if (mounted) setState(() => _reload++);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              if (note.content.isNotEmpty) ...[
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              if (formattedDate.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
