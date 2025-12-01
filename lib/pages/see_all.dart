import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/genre_data.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/widgets/media_tile.dart';

class SeeAllPage extends StatelessWidget {
  final Future<List<Media>> Function(String mediaChoice) apiFunc;
  final String type;
  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';

  const SeeAllPage({super.key, required this.apiFunc, required this.type});

  Future<List<Media>> _fetchData() async {
    if (GenreData.movieGenres.isEmpty || GenreData.tvGenres.isEmpty) {
      await APIHelper.fetchGenres();
    }
    return await apiFunc(type);
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white24),
                ),

                child: FutureBuilder<List<Media>>(
                  future: _fetchData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final list = snapshot.data!;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.52,
                          ),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        return MediaTile(
                          width: 130,
                          media: list[i],
                          imgBaseUrl: _imgBaseUrl,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
