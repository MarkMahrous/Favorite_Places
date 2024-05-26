import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places/models/place.dart';

class FavoritePlacesProvider extends StateNotifier<List<Place>> {
  FavoritePlacesProvider() : super([]);

  void addPlace(Place place) {
    state = [...state, place];
  }
}

final favoritePlacesProvider =
    StateNotifierProvider<FavoritePlacesProvider, List<Place>>((ref) {
  return FavoritePlacesProvider();
});
