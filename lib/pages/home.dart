import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sceneit/pages/see_all.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/genre_data.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/widgets/media_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';

  Future<List<Media>> _fetch(
    String type,
    Future<List<Media>> Function(String mediaChoice) func,
  ) async {
    if (GenreData.movieGenres.isEmpty || GenreData.tvGenres.isEmpty) {
      await APIHelper.fetchGenres();
    }
    return await func(type);
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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _glassSection(
                context,
                label: "Trending Movies",
                type: "movie",
                api: APIHelper.fetchTrendingMedia,
              ),
              const SizedBox(height: 18),

              _glassSection(
                context,
                label: "Trending TV Shows",
                type: "tv",
                api: APIHelper.fetchTrendingMedia,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassSection(
    BuildContext context, {
    required String label,
    required String type,
    required Future<List<Media>> Function(String) api,
  }) {
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

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.white24)],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeeAllPage(apiFunc: api, type: type),
                      ),
                    ),
                    child: const Text(
                      "See All →",
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 250,
                child: FutureBuilder<List<Media>>(
                  future: _fetch(type, api),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, i) {
                        final media = snapshot.data![i];
                        return MediaTile(
                          width: 130,
                          media: media,
                          imgBaseUrl: _imgBaseUrl,
                        );
                      },
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
