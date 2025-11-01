import 'package:flutter/material.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/genre_data.dart';
import 'package:sceneit/utils/media.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Media>> _futureMediaData;
  String _dataChoice = 'popular';
  String _mediaChoice = 'movie';
  final String _imgBaseUrl = 'https://image.tmdb.org/t/p/w200';
  @override void initState() {
    super.initState();
    if(GenreData.movieGenres.isEmpty || GenreData.tvGenres.isEmpty) {
      APIHelper.fetchGenres();
    }
    if(_dataChoice == 'popular') {
      _futureMediaData = APIHelper.fetchPopularMedia(_mediaChoice);
    }
    else if(_dataChoice == 'trending') {
      _futureMediaData = APIHelper.fetchTrendingMedia(_mediaChoice);
    }
    else if(_dataChoice == 'now playing') {
      _futureMediaData = APIHelper.fetchNowPlayingMedia(_mediaChoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Media>>(
        future: _futureMediaData,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Center(child:CircularProgressIndicator());
          }
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2/3,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                final media = snapshot.data![i];
                return Card(
                  elevation: 2,
                  child: InkWell(
                    //change to navigate to media details
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped ${media.title}')),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          _imgBaseUrl + media.posterPath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const CircularProgressIndicator();
                          },
                        )
                      ],
                    )
                  )
                );
              }
          );
        },
      )
    );
  }
}
