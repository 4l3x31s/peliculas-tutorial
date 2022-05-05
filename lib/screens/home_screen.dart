import 'package:flutter/material.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);

    //print('ejemplo');
    //print(moviesProvider.onDisplayMovies);


    return Scaffold(
        appBar: AppBar(
          title: Text('Peliculas'),
          elevation: 0,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //Tarjetas principales
              CardSwiper(movies: moviesProvider.onDisplayMovies),
              //Slider de peliculas
              MovieSlider(
                movies: moviesProvider.popularMovies,
                title: 'Prueba',
                onNextPage: ()=> moviesProvider.getPopularMovies(),
              ),
            ],
          ),
        ));
  }
}
