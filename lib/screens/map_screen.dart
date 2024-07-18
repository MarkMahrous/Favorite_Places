import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:favorite_places/models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: 'Googleplex',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your Location' : 'Your Location',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (_pickedLocation == null) {
                  return;
                }

                final lat = _pickedLocation!.latitude;
                final lng = _pickedLocation!.longitude;

                final url = Uri.parse(
                    'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=Your Api Key');

                final response = await http.get(url);
                final resData = json.decode(response.body);
                final address = resData['results'][0]['formatted_address'];

                PlaceLocation newLocation = PlaceLocation(
                  latitude: lat,
                  longitude: lng,
                  address: address,
                );

                Navigator.of(context).pop(newLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        onTap: (position) {
          setState(() {
            _pickedLocation = position;
          });
        },
        initialCameraPosition: CameraPosition(
          target: _pickedLocation != null
              ? _pickedLocation!
              : LatLng(
                  widget.location.latitude,
                  widget.location.longitude,
                ),
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('m1'),
            position: _pickedLocation != null
                ? _pickedLocation!
                : LatLng(
                    widget.location.latitude,
                    widget.location.longitude,
                  ),
          ),
        },
      ),
    );
  }
}
