import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final String _apiKey = 'f0988acfb81ed0b5736a8bb7096b2324';
  final String _baseUrl = 'api.themoviedb.org';
  final String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
    onValue: (value) {

    }
  );

  final StreamController<List<Movie>> _suggestionStreamController = StreamController<List<Movie>>.broadcast();
  Stream<List<Movie>> get suggestionStream => this._suggestionStreamController.stream;


  MoviesProvider() {
    //print('MoviesProvider init');
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apiKey, 'language': _language, 'page': '$page'});

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

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    print('pidiendo infor al server -cast');

    // Await the http get response, then decode the json-formatted response.
    final response = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(response);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie',
      {
        'api_key': _apiKey,
        'language': _language,
        'query': query
      }
    );
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);
    return searchResponse.results;
  }
  void getSuggestionsByQuery(String searchTerm){
    debouncer.value = '';
    debouncer.onValue = (value) async {
      //print('Tenemos valor a buscar $value');
      final results = await searchMovie(value.toString());
      this._suggestionStreamController.add(results);
    };
    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });
    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
