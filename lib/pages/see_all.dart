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
    final data = await apiFunc(type);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SceneIt')),
      body: FutureBuilder<List<Media>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(child:CircularProgressIndicator());
          }
          else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.5,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
              final media = snapshot.data![i];
              return MediaTile(
                  width: 10,
                  media: media,
                  imgBaseUrl: _imgBaseUrl,
                  onTap:() => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped ${media.title}')),
                  )
                );
              }
            );
          }
        }
      )
    );
  }
}