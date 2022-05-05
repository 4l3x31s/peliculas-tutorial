import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/models/models.dart';


class MoviesProvider extends ChangeNotifier {
  final String _apiKey   = 'f0988acfb81ed0b5736a8bb7096b2324';
  final String _baseUrl  = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  int _popularPage = 0;

  MoviesProvider() {
    //print('MoviesProvider init');
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String>_getJsonData(String endpoint, [int page = 1]) async {
    var url =
      Uri.https(_baseUrl, endpoint, {
        'api_key': _apiKey,
        'language': _language,
        'page': '$page'
      });

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    
       // Await the http get response, then decode the json-formatted response.
    final response = await _getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(response);
    
    //print(nowPlayingResponse.results[0].title);
    onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }
  getPopularMovies() async {
    _popularPage++;
    final response = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(response);
    
    //print(nowPlayingResponse.results[0].title);
    popularMovies = [...popularMovies, ...popularResponse.results];

    notifyListeners();
  }
}
