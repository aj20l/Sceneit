import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/utils/Watchlist.dart';
import 'package:sceneit/utils/session.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  List<Media> results = [];
  int _currentPage = 0;
  bool _isRequesting = false;
  bool _isEnd = false;
  Timer? _debounce;
  String _currentQuery = '';
  int _currentQueryId = 0;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isRequesting &&
        !_isEnd) {
      _loadNextPage();
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _startNewSearch(value.trim());
    });
  }

  void _startNewSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        results.clear();
        _currentPage = 0;
        _isEnd = false;
        _currentQuery = '';
      });
      return;
    }

    _currentQueryId++;
    final int thisQueryId = _currentQueryId;

    setState(() {
      results = [];
      _currentPage = 0;
      _isEnd = false;
      _isRequesting = true;
      _currentQuery = query;
    });

    _fetchPage(query, 1, thisQueryId)
        .then((fetched) {
      if (!mounted) return;
      if (thisQueryId != _currentQueryId) return;

      setState(() {
        results = fetched;
        _currentPage = 1;
        _isRequesting = false;
        _isEnd = fetched.length < _pageSize;
      });


      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });


    })
        .catchError((err) {
      if (!mounted) return;
      setState(() {
        _isRequesting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $err')));
    });
  }

  Future<void> _loadNextPage() async {
    if (_isRequesting || _isEnd || _currentQuery.isEmpty) return;

    _isRequesting = true;
    final int nextPage = _currentPage + 1;
    final int thisQueryId = _currentQueryId;

    try {
      final List<Media> fetched = await _fetchPage(
        _currentQuery,
        nextPage,
        thisQueryId,
      );

      if (!mounted) return;
      if (thisQueryId != _currentQueryId) {
        _isRequesting = false;
        return;
      }

      setState(() {
        results.addAll(fetched);
        _currentPage = nextPage;
        _isEnd = fetched.length < _pageSize;
        _isRequesting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRequesting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Load more failed')));
    }
  }

  Future<List<Media>> _fetchPage(String query, int page, int queryId) async {
    final List<Media> resp = await APIHelper.searchMediaPage(
      query,
      page,
      pageSize: _pageSize,
    );
    return resp;
  }

  void _addToWatchlist(Media media) async {
    await WatchlistModel().insertItem(
      WatchlistItem(
        userId: Session.currentUser?.id,
        mediaId: media.id,
        title: media.title,
        mediaType: media.mediaType,
        mediaData: media.toMap(),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${media.title} added')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A30FF), Color(0xFF1D1A47)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: const Text(
                  '🔎 Search Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _textController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Colors.white),
                      hintText: 'Search movie or series...',
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _isRequesting && results.isEmpty
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                    : results.isEmpty
                    ? const Center(
                  child: Text(
                    'Start typing to search...',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: results.length +
                      (_isRequesting && !_isEnd ? 1 : 0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemBuilder: (context, idx) {
                    if (idx == results.length) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    final media = results[idx];
                    final posterUrl = media.posterPath == null
                        ? null
                        : 'https://image.tmdb.org/t/p/w200${media.posterPath}';
                    return Container(
                      margin:
                      const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 84,
                            height: 120,
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(10),
                              child: posterUrl == null
                                  ? Image.asset(
                                'assets/fallback.jpg',
                                width: 84,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                                  : Image.network(
                                posterUrl,
                                width: 84,
                                height: 120,
                                fit: BoxFit.cover,
                                cacheWidth: 84,
                                cacheHeight: 120,
                                errorBuilder: (context, error,
                                    stack) {
                                  return Image.asset(
                                    'assets/fallback.jpg',
                                    width: 84,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              media.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _addToWatchlist(media),
                            icon: const Icon(
                              Icons.bookmark_add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
