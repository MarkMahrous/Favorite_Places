import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:favorite_places/models/place.dart';

class LocationInput extends StatefulWidget {
  LocationInput({super.key, required this.onPickLocation});

  void Function(PlaceLocation location) onPickLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isgettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }

    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;

    final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    print(googleMapsApiKey);

    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=$googleMapsApiKey';
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isgettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    print(googleMapsApiKey);

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleMapsApiKey');

    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];

    _pickedLocation =
        PlaceLocation(latitude: lat, longitude: lng, address: address);

    widget.onPickLocation(_pickedLocation!);

    setState(() {
      _isgettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'Location Preview',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isgettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: const Text("Current Location"),
              icon: const Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Text("Select on Map"),
              icon: const Icon(Icons.map),
            ),
          ],
        )
      ],
    );
  }
}
