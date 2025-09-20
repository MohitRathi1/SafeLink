// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// import 'core/services/api_service.dart'; // make sure this is implemented correctly

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SafeLink',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'SafeLink: Find Safe Points'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final ApiService _apiService = ApiService();
//   late GoogleMapController mapController;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   late Position _currentPosition;
//   bool _isLoading = true;
//   List<dynamic> _policeStations = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   void _initializeApp() async {
//     setState(() => _isLoading = true);
//     try {
//       await _getCurrentPosition();
//       await _getNearbyPoliceStations();
//     } catch (e) {
//       print("Error initializing app: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _getCurrentPosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied');
//     }

//     _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//   }

//   Future<void> _getNearbyPoliceStations() async {
//     final stations = await _apiService.getNearbyPoliceStations(_currentPosition);
//     setState(() {
//       _policeStations = stations;
//     });
//   }

//   Future<void> _displayMapWithStation(Map<String, dynamic> station) async {
//     setState(() {
//       _markers.clear();
//       _polylines.clear();
//     });

//     final stationLatLng = LatLng(
//       station['geometry']['location']['lat'],
//       station['geometry']['location']['lng'],
//     );

//     _markers.add(Marker(
//       markerId: const MarkerId('user_location'),
//       position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
//       infoWindow: const InfoWindow(title: 'Your Location'),
//     ));

//     _markers.add(Marker(
//       markerId: const MarkerId('police_station'),
//       position: stationLatLng,
//       infoWindow: InfoWindow(title: station['name']),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//     ));

//     await _getRouteAndDrawPolyline(_currentPosition, stationLatLng);

//     mapController.animateCamera(CameraUpdate.newLatLngZoom(stationLatLng, 15));
//   }

//   Future<void> _getRouteAndDrawPolyline(Position start, LatLng end) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=${_apiService.googleMapsApiKey}';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final points = data['routes'][0]['overview_polyline']['points'];
//       List<PointLatLng> result = PolylinePoints.decodePolyline(points);
//       List<LatLng> polylineCoordinates =
//           result.map((p) => LatLng(p.latitude, p.longitude)).toList();

//       setState(() {
//         _polylines.add(Polyline(
//           polylineId: const PolylineId('route'),
//           points: polylineCoordinates,
//           color: Colors.red,
//           width: 4,
//         ));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: ListView.builder(
//                     itemCount: _policeStations.length,
//                     itemBuilder: (context, index) {
//                       final station = _policeStations[index];
//                       return Card(
//                         margin: const EdgeInsets.all(8),
//                         elevation: 4,
//                         child: ListTile(
//                           leading: const Icon(Icons.local_police),
//                           title: Text(station['name']),
//                           subtitle: Text(station['vicinity'] ?? 'No address'),
//                           onTap: () => _displayMapWithStation(station),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: GoogleMap(
//                     onMapCreated: (controller) {
//                       mapController = controller;
//                     },
//                     initialCameraPosition: CameraPosition(
//                       target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
//                       zoom: 14.0,
//                     ),
//                     markers: _markers,
//                     polylines: _polylines,
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/safe_places_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clinte/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
