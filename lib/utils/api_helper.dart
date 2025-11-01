//reference: https://docs.flutter.dev/cookbook/networking/fetch-data
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/utils/genre_data.dart';

class APIHelper {
  static final String _apiKey = '3e65e43bd2a3b6645f0835a166b02bc7';
  static final String _baseUrl = 'https://api.themoviedb.org/3';

  //need to run when the app starts so that genre ids can map to the actual genre
  static Future<void> fetchGenres() async {
    final movieRes = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'));
    if(movieRes.statusCode == 200) {
      final movieData = jsonDecode(movieRes.body);
      for(var genre in movieData['genres']) {
        GenreData.movieGenres[genre['id']] = genre['name'];
      }
    }
    else {
      throw Exception('failed to get genres for movies');
    }
    final tvRes = await http.get(
        Uri.parse('$_baseUrl/genre/tv/list?api_key=$_apiKey&language=en-US'));
    if(tvRes.statusCode == 200) {
      final tvData = jsonDecode(tvRes.body);
      for(var genre in tvData['genres']) {
        GenreData.tvGenres[genre['id']] = genre['name'];
      }
    }
    else {
      throw Exception('failed to get genres for tv shows');
    }
  }

  static Future<List<Media>> fetchTrendingMedia(String mediaChoice) async {
    if(mediaChoice == 'movie') {
      final response = await http.get(
          Uri.parse('$_baseUrl/trending/movie/day?api_key=$_apiKey&language=en-US'));
      if(response.statusCode == 200) {
        final Map<String, dynamic> movieData = jsonDecode(response.body);
        List<dynamic> results = movieData['results'];
        List<Media> movies = results.map((movie) => Media.fromJson(movie)).toList();
        return movies;
      }
      else {
        throw Exception('failed to get trending movies');
      }
    }
    else {
      final response = await http.get(
          Uri.parse('$_baseUrl/trending/tv/day?api_key=$_apiKey&language=en-US'));
      if(response.statusCode == 200) {
        final Map<String, dynamic> tvData = jsonDecode(response.body);
        List<dynamic> results = tvData['results'];
        List<Media> tvShows = results.map((show) => Media.fromJson(show)).toList();
        return tvShows;
      }
      else {
        throw Exception('failed to get trending movies');
      }
    }
  }

  static Future<List<Media>> fetchNowPlayingMedia(String mediaChoice) async {
    if(mediaChoice == 'movie') {
      final response = await http.get(
          Uri.parse('$_baseUrl/movie/now_playing?api_key=$_apiKey&language=en-US'));
      if(response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
        List<Media> movies = results.map((m) => Media.fromJson(m)).toList();
        return movies;
      }
      else {
        throw Exception('failed to get now playing movies');
      }
    }
    else {
      final response = await http.get(
          Uri.parse('$_baseUrl/tv/on_the_air?api_key=$_apiKey&language=en-US'));
      if(response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
        List<Media> shows = results.map((s) => Media.fromJson(s)).toList();
        return shows;
      }
      else {
        throw Exception('failed to get on air tv shows');
      }
    }
  }

  static Future<List<Media>> fetchPopularMedia(String mediaChoice) async {
    if(mediaChoice == 'movie') {
      final response = await http.get(
          Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US'));
      if(response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
        List<Media> movies = results.map((m) => Media.fromJson(m)).toList();
        return movies;
      }
      else {
        throw Exception('failed to get popular movies');
      }
    }
    else {
      final response = await http.get(
          Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey&language=en-US'));
      if(response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
        List<Media> shows = results.map((s) => Media.fromJson(s)).toList();
        return shows;
      }
      else {
        throw Exception('failed to get popular tv shows');
      }
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
    }
    else {
      throw Exception('failed to search media');
    }
  }

  static Future<Media> fetchMediaDetails(Media media) async {
    if(media.mediaType == 'movie') {
      final response = await http.get(
          Uri.parse('$_baseUrl/movie/${media.id}?api_key=$_apiKey&language=en-US&append_to_response=credits,recommendations'));
      if(response.statusCode == 200) {
        Map<String,dynamic> json = jsonDecode(response.body);
        return media.setMediaDetails(json);
      }
      else {
        throw Exception('failed to get movie details');
      }
    }
    else {
      final response = await http.get(
          Uri.parse('$_baseUrl/tv/${media.id}?api_key=$_apiKey&language=en-US&append_to_response=credits,recommendations'));
      if(response.statusCode == 200) {
        Map<String,dynamic> json = jsonDecode(response.body);
        return media.setMediaDetails(json);
      }
      else {
        throw Exception('failed to get tv details');
      }
    }
  }
}