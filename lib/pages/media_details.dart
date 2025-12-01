import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/widgets/media_tile.dart';
import 'package:sceneit/utils/person.dart';

import '../utils/Watchlist.dart';
import '../utils/session.dart';

class MediaDetailsPage extends StatelessWidget {
  final Media baseMedia;
  const MediaDetailsPage({super.key, required this.baseMedia});

  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';

  Future<Media> _fetchData() async {
    return await APIHelper.fetchMediaDetails(baseMedia);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3A30FF), Color(0xFF1D1A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(.08),
          elevation: 0,
          title: const Text(
            "SceneIt",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 12, color: Colors.white30)],
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Media>(
            future: _fetchData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final media = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _glassCard(child: _header(media)),
                  const SizedBox(height: 18),

                  _sectionTitle("Overview"),
                  _glassCard(
                    child: Text(
                      media.overview,
                      style: TextStyle(color: Colors.white.withOpacity(.9)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _sectionTitle("Cast"),
                  _glassCard(child: _castList(media.cast ?? [])),
                  const SizedBox(height: 18),

                  _sectionTitle("Recommendations"),
                  _glassCard(
                    child: _recommendationList(media.recommendations ?? []),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.09),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.white24, blurRadius: 8)],
      ),
    );
  }

  Widget _header(Media media) {
    final date = DateTime.tryParse(media.releaseDate);
    final year = date?.year ?? 0;
    final genres = media.genres.join(", ");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(_imgBaseUrl + media.posterPath, height: 220),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${media.title} ($year)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.white30)],
                ),
              ),
              const SizedBox(height: 10),

              Text(
                "Genres: $genres",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),

              Text(
                "Popularity: ${media.popularity.round()}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    "Rating:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _rating(media.rating),
                ],
              ),

              const SizedBox(height: 14),
              Bookmark(media: media, size: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _castList(List<Person> cast) {
    cast.sort((a, b) => a.order.compareTo(b.order));
    cast = cast.take(12).toList();

    if (cast.isEmpty) {
      return const Text(
        "Cast not available",
        style: TextStyle(color: Colors.white70),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: cast.length,
        itemBuilder: (_, i) {
          final p = cast[i];
          return SizedBox(
            width: 120,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(_imgBaseUrl + p.profilePath),
                ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  p.character ?? p.job ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _recommendationList(List<Media> list) {
    if (list.isEmpty) {
      return const Text(
        "No recommendations available",
        style: TextStyle(color: Colors.white70),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: list.length,
        itemBuilder: (_, i) {
          return MediaTile(width: 130, media: list[i], imgBaseUrl: _imgBaseUrl);
        },
      ),
    );
  }

  Widget _rating(double rating) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 46,
          height: 46,
          child: CircularProgressIndicator(
            value: rating / 10,
            strokeWidth: 5,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
          ),
        ),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class Bookmark extends StatefulWidget {
  final Media media;
  final double? size;
  const Bookmark({super.key, required this.media, this.size});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  bool _isWatchlist = false;
  WatchlistModel model = WatchlistModel();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final items = await model.getWatchlistItem(
      Session.currentUser?.id,
      widget.media.id,
    );

    if (!mounted) return;

    setState(() => _isWatchlist = items.isNotEmpty);
  }

  void _toggle() async {
    if (_isWatchlist) {
      final items = await model.getWatchlistItem(
        Session.currentUser?.id,
        widget.media.id,
      );

      for (final item in items) {
        model.deleteItem(item.id!);
      }

      setState(() => _isWatchlist = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Removed ${widget.media.title} from watchlist")),
      );
    } else {
      await model.insertItem(
        WatchlistItem(
          userId: Session.currentUser?.id,
          mediaId: widget.media.id,
          title: widget.media.title,
          mediaType: widget.media.mediaType,
          mediaData: widget.media.toMap(),
        ),
      );

      setState(() => _isWatchlist = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added ${widget.media.title} to watchlist")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Icon(
        _isWatchlist ? Icons.bookmark : Icons.bookmark_border,
        color: Colors.white,
        size: widget.size ?? 22,
      ),
    );
  }
}
