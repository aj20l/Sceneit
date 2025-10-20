import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/utils/genre_data.dart';

class APIHelper {
  static final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  static final String _baseUrl = 'https://api.themoviedb.org/3';

  //need to run when the app starts to get the genre map (id -> genre name)
  static Future<void> fetchGenres() async {
    final movieRes = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'));
    if(movieRes.statusCode == 200) {
      final movieData = jsonDecode(movieRes.body);
      for(var genre in movieData['genres']) {
        GenreData.movieGenres[genre['id']] = genre['name'];
      }
    } else {
      throw Exception('failed to get genres for movies');
    }
    final tvRes = await http.get(
        Uri.parse('$_baseUrl/genre/tv/list?api_key=$_apiKey&language=en-US'));
    if(tvRes.statusCode == 200) {
      final tvData = jsonDecode(tvRes.body);
      for(var genre in tvData['genres']) {
        GenreData.tvGenres[genre['id']] = genre['name'];
      }
    } else {
      throw Exception('failed to get genres for tv shows');
    }
  }

  static Future<List<Media>> fetchTrendingMovies() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/day?api_key=$_apiKey&language=en-US'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> movieData = jsonDecode(response.body);
      List<dynamic> results = movieData['results'];
      List<Media> movies = results.map((movie) => Media.fromJson(movie)).toList();
      return movies;
    } else {
      throw Exception('failed to get trending movies');
    }
  }
  static Future<List<Media>> fetchTrendingTvShows() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/trending/tv/day?api_key=$_apiKey&language=en-US'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> tvData = jsonDecode(response.body);
      List<dynamic> results = tvData['results'];
      List<Media> tvShows = results.map((show) => Media.fromJson(show)).toList();
      return tvShows;
    } else {
      throw Exception('failed to get trending movies');
    }
  }
  static Future<List<Media>> searchMedia(String query) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&language=en-US&query=$query'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Media> media = results.map((item) => Media.fromJson(item)).toList();
      return media;
    } else {
      throw Exception('failed to search media');
    }
  }

  static Future<List<Media>> fetchNowPlayingMovies() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey&language=en-US'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Media> movies = results.map((m) => Media.fromJson(m)).toList();
      return movies;
    } else {
      throw Exception('failed to get now playing movies');
    }
  }

  static Future<List<Media>> fetchOnAirTvShows() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/tv/on_the_air?api_key=$_apiKey&language=en-US'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Media> shows = results.map((s) => Media.fromJson(s)).toList();
      return shows;
    } else {
      throw Exception('failed to get on-air tv shows');
    }
  }

  static Future<List<Media>> fetchPopularMovies() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Media> movies = results.map((m) => Media.fromJson(m)).toList();
      return movies;
    } else {
      throw Exception('failed to get popular movies');
    }
  }

  static Future<List<Media>> fetchPopularTvShows() async {
    final response = await http.get(
        Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&language=en-US'));
    if(response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Media> shows = results.map((s) => Media.fromJson(s)).toList();
      return shows;
    } else {
      throw Exception('failed to get popular tv shows');
    }
  }

  static Future<Media> fetchMovieDetails(Media media) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/movie/${media.id}?api_key=$_apiKey&language=en-US&append_to_response=credits,recommendations'));
    if(response.statusCode == 200) {
      Map<String,dynamic> json = jsonDecode(response.body);
      return media.setMediaDetails(json);
    } else {
      throw Exception('failed to get movie details');
    }
  }

  static Future<Media> fetchTvDetails(Media media) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/tv/${media.id}?api_key=$_apiKey&language=en-US&append_to_response=credits,recommendations'));
    if(response.statusCode == 200) {
      Map<String,dynamic> json = jsonDecode(response.body);
      return media.setMediaDetails(json);
    } else {
      throw Exception('failed to get tv details');
    }
  }
  //might not be needed unless we want an in-depth actor screen
  static Future<Map<String, dynamic>> fetchActorDetails(int personId) async {
    final response = await http.get(
        Uri.parse('$_baseUrl/person/$personId?api_key=$_apiKey&language=en-US&append_to_response=movie_credits,tv_credits'));
    if(response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('failed to get actor details');
    }
  }
}