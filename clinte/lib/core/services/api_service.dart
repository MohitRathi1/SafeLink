// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ApiService {
  final String googleMapsApiKey = "AIzaSyBhs5irTAVjEjLR1McJJI3p098AFxX9SHQ";

  Future<List<dynamic>> getNearbyPoliceStations(Position position) async {
    final lat = position.latitude;
    final lng = position.longitude;

    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=$lat,$lng&radius=1500&type=police&key=$googleMapsApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load police stations');
    }
  }
}