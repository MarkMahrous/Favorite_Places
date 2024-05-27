import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/provider/favorite_places_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _placeNameController = TextEditingController();

  @override
  void dispose() {
    _placeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Place'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              maxLength: 50,
              controller: _placeNameController,
              decoration: const InputDecoration(
                labelText: 'Place Name',
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ref.read(favoritePlacesProvider.notifier).addPlace(
                        Place(name: _placeNameController.text),
                      );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
