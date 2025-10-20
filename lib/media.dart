import 'package:sceneit/genre_data.dart';
import 'package:sceneit/person.dart';

class Media {
  final int id;
  final int ratingCount;
  final double rating;
  final double popularity;
  final String posterPath;
  final String overview;
  final String title;
  final String language;
  final String releaseDate;
  final String mediaType;
  final List<String> genres;
  //these only get populated when the user clicks on the movie/show
  List<Person>? cast;
  List<Media>? recommendations;

  Media({
    required this.id,
    required this.rating,
    required this.ratingCount,
    required this.popularity,
    required this.posterPath,
    required this.overview,
    required this.title,
    required this.language,
    required this.releaseDate,
    required this.mediaType,
    required this.genres,
    this.cast,
    this.recommendations,
  });

  static Media fromJson(Map<String,dynamic> json) {
    final List<String> genres = [];
    Map<int, String> genreMapper = GenreData.movieGenres;
    if (json['media_type'] == 'tv') {
      genreMapper = GenreData.tvGenres;
    }
    List<int> genreIds = [];
    if (json['genre_ids'] != null) {
      genreIds = List<int>.from(json['genre_ids']);
    }
    genreIds.map((id) => genres.add(genreMapper[id] ?? ''));
    return Media(
      id: json['id'],
      rating: (json['vote_average'] ?? -1).toDouble(),
      ratingCount: json['vote_count'] ?? -1,
      popularity: (json['popularity'] ?? -1).toDouble(),
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      language: json['original_language'] ?? 'en',
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      mediaType: json['media_type'] ?? 'movie',
      genres: genres
    );
  }
  //set cast, recommendations
  Media setMediaDetails(Map<String, dynamic> json) {
    List<Map<String, dynamic>> recResult = List<Map<String, dynamic>>.from(json['recommendations']['results']);
    List<Media> recommendations = [];
    for(var mediaJson in recResult) {
      recommendations.add(Media.fromJson(mediaJson));
    }
    this.recommendations = recommendations;

    List<Map<String, dynamic>> creditsResult = List<Map<String, dynamic>>.from(json['credits']['cast']);
    List<Person> cast = [];
    for(var personJson in creditsResult) {
      cast.add(Person.fromJson(personJson));
    }
    this.cast = cast;

    return this;
  }
}