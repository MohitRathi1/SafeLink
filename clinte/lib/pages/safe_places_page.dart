import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../core/services/api_service.dart';

class SafePlacesPage extends StatefulWidget {
  const SafePlacesPage({super.key});

  @override
  State<SafePlacesPage> createState() => _SafePlacesPageState();
}

class _SafePlacesPageState extends State<SafePlacesPage> {
  final ApiService _apiService = ApiService();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  late Position _currentPosition;
  bool _isLoading = true;
  List<dynamic> _policeStations = [];
  bool _showMap = false;
  LatLng? _selectedStation;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _getCurrentPosition();
      final stations = await _apiService.getNearbyPoliceStations(_currentPosition);
      setState(() {
        _policeStations = stations;
        _isLoading = false;
      });
    } catch (e) {
      print('Initialization error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentPosition() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _displayRouteTo(LatLng stationLocation, String name) async {
    setState(() {
      _showMap = true;
      _selectedStation = stationLocation;
      _markers.clear();
      _polylines.clear();
    });

    _markers.add(Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      infoWindow: const InfoWindow(title: 'You'),
    ));

    _markers.add(Marker(
      markerId: MarkerId(name),
      position: stationLocation,
      infoWindow: InfoWindow(title: name),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_currentPosition.latitude},${_currentPosition.longitude}&'
        'destination=${stationLocation.latitude},${stationLocation.longitude}&'
        'key=${_apiService.googleMapsApiKey}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Check if 'routes' list is not empty before accessing
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final polyline = PolylinePoints.decodePolyline(points);

        final coords = polyline.map((p) => LatLng(p.latitude, p.longitude)).toList();

        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: coords,
            color: Colors.red,
            width: 5,
          ));
        });
      } else {
        // Handle no route found scenario
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No route found to this location.')),
        );
        print('No route found between current location and station.');
      }
    } else {
      print('Failed to get route data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_showMap && _selectedStation != null) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
          zoom: 14,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        onMapCreated: (controller) {},
      );
    }

    return ListView.builder(
      itemCount: _policeStations.length,
      itemBuilder: (context, index) {
        final station = _policeStations[index];
        final name = station['name'];
        final lat = station['geometry']['location']['lat'];
        final lng = station['geometry']['location']['lng'];

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            leading: const Icon(Icons.local_police),
            title: Text(name),
            subtitle: const Text('Tap to view on map'),
            onTap: () => _displayRouteTo(LatLng(lat, lng), name),
          ),
        );
      },
    );
  }
}