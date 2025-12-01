import 'package:flutter/material.dart';
import 'package:sceneit/pages/see_all.dart';
import 'package:sceneit/utils/api_helper.dart';
import 'package:sceneit/utils/genre_data.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/widgets/media_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:sceneit/utils/Watchlist.dart';
import 'package:sceneit/utils/session.dart';






void main() => runApp(const SearchPage());

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isDark = false;

  // Store search results
  List<Media> searchResults = [];

  // Debounce timer to prevent rate limits
  Timer? _debounce;


  Future<void> searchTMDB(String query,SearchController controller) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }

    final results= await APIHelper.searchMedia(query);

    setState(() {
      searchResults = results;
    });
    controller.openView();

  }

  void onSearchChanged(String query, SearchController controller) {
    // Cancel old timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();


    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchTMDB(query,controller);
    });
  }

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner:false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                leading: const Icon(Icons.search),
                onTap: () => controller.openView(),
                onChanged: (value) {
                  controller.openView();
                  onSearchChanged(value,controller);
                },

              );
            },

            // Suggestions list = TMDB results
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              return List<Widget>.generate(searchResults.length, (int index) {
                final movie = searchResults[index];
                final title = movie.title;
                final posterPath = movie.posterPath;
                final mediatile=MediaTile(media: movie,width: 50,imgBaseUrl:"https://image.tmdb.org/t/p/w92" );



                return ListTile(
                  leading: posterPath != null
                      ? Image.network(
                    mediatile.imgBaseUrl+posterPath,
                    width: 50,
                    height: 80,
                    fit: BoxFit.cover
                  )
                      : const Icon(Icons.movie),
                  title: Text(title),
                  subtitle: Text(
                    movie.releaseDate
                  ),//add to watchlist
                  onTap: () {      WatchlistItem item = WatchlistItem(
                      userId: Session.currentUser?.id,
                      mediaId: movie.id,
                      title: movie.title,
                      mediaType: movie.mediaType,
                      mediaData: movie.toMap()
                  );

                   WatchlistModel().insertItem(item);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(
                      'Added ${movie.title} to watchlist')));


                    controller.closeView(title);
                  },
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
// force update
