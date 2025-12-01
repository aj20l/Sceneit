//reference: https://docs.flutter.dev/cookbook/networking/fetch-data
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sceneit/utils/media.dart';
import 'package:sceneit/utils/genre_data.dart';

class APIHelper {
  static const String _apiKey = "3e65e43bd2a3b6645f0835a166b02bc7";
  static const String _baseUrl = "https://api.themoviedb.org/3";

  static Future<void> fetchGenres() async {
    final movieRes = await http.get(
      Uri.parse("$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US"),
    );

    if (movieRes.statusCode == 200) {
      final movieData = jsonDecode(movieRes.body);
      for (var g in movieData["genres"]) {
        GenreData.movieGenres[g["id"]] = g["name"];
      }
    } else {
      throw Exception("Failed to load movie genres");
    }

    final tvRes = await http.get(
      Uri.parse("$_baseUrl/genre/tv/list?api_key=$_apiKey&language=en-US"),
    );

    if (tvRes.statusCode == 200) {
      final tvData = jsonDecode(tvRes.body);
      for (var g in tvData["genres"]) {
        GenreData.tvGenres[g["id"]] = g["name"];
      }
    } else {
      throw Exception("Failed to load TV genres");
    }
  }

  static Future<List<Media>> fetchTrendingMedia(String mediaChoice) async {
    final url = mediaChoice == "movie"
        ? "$_baseUrl/trending/movie/day?api_key=$_apiKey&language=en-US"
        : "$_baseUrl/trending/tv/day?api_key=$_apiKey&language=en-US";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Media>.from(data["results"].map((m) => Media.fromJson(m)));
    } else {
      throw Exception("Failed to load trending media");
    }
  }

  static Future<List<Media>> fetchNowPlayingMedia(String mediaChoice) async {
    final url = mediaChoice == "movie"
        ? "$_baseUrl/movie/now_playing?api_key=$_apiKey&language=en-US"
        : "$_baseUrl/tv/on_the_air?api_key=$_apiKey&language=en-US";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Media>.from(data["results"].map((m) => Media.fromJson(m)));
    } else {
      throw Exception("Failed to load now playing media");
    }
  }

  static Future<List<Media>> fetchPopularMedia(String mediaChoice) async {
    final url = mediaChoice == "movie"
        ? "$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US"
        : "$_baseUrl/tv/popular?api_key=$_apiKey&language=en-US";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Media>.from(data["results"].map((m) => Media.fromJson(m)));
    } else {
      throw Exception("Failed to load popular media");
    }
  }

  static Future<List<Media>> searchMediaPage(
    String query,
    int page, {
    int pageSize = 20,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search/multi?api_key=$_apiKey&language=en-US&query=$query&page=$page&include_adult=false&per_page=$pageSize',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'];
      List<Media> media = results.map((item) => Media.fromJson(item)).toList();
      return media;
    } else {
      throw Exception('Failed to search media');
    }
  }

  static Future<Media> fetchMediaDetails(Media media) async {
    final url = media.mediaType == "movie"
        ? "$_baseUrl/movie/${media.id}?api_key=$_apiKey&language=en-US&append_to_response=credits,recommendations"
        : "$_baseUrl/tv/${media.id}?api_key=$_apiKey&language=en-US&append_to_response=credits,recommendations";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return media.setMediaDetails(json);
    } else {
      throw Exception("Failed to load details");
    }
  }
}
