import 'package:flutter/material.dart';
import 'package:sceneit/pages/see_all.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/genre_data.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/widgets/media_tile.dart';

class HomePage extends StatelessWidget {

  const HomePage({super.key});

  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';

  Future<List<Media>> _fetchData(String type,
      Future<List<Media>> Function(String mediaChoice) apiFunc) async {
    if (GenreData.movieGenres.isEmpty || GenreData.tvGenres.isEmpty) {
      await APIHelper.fetchGenres();
    }
    final data = await apiFunc(type);
    return data;
  }

  Widget _buildSection(
      BuildContext context,
      String label,
      String type,
      Future<List<Media>> Function(String mediaChoice) apiFunc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeeAllPage(apiFunc:apiFunc, type:type),
                    ),
                  );
                },
                child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: FutureBuilder<List<Media>>(
            future: apiFunc(type),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final media = snapshot.data![i];
                    return MediaTile(
                      width: 120.0,
                      media: media,
                      imgBaseUrl: _imgBaseUrl,
                      onTap: () =>
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(
                              'Tapped ${media.title}'))),
                    );
                  },
                );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
              context,
              'Trending Movies',
              'movie',
              APIHelper.fetchTrendingMedia),
          _buildSection(
              context,
              'Trending TV Shows',
              'tv',
              APIHelper.fetchTrendingMedia)
        ],
      ),
    );
  }

}