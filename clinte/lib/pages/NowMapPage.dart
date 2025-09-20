// NowMapPage.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NowMapPage extends StatefulWidget {
  const NowMapPage({super.key});

  @override
  _NowMapPageState createState() => _NowMapPageState();
}

class _NowMapPageState extends State<NowMapPage> {
  static const LatLng _initialPosition = LatLng(
    37.42796133580664,
    -122.085749655962,
  );
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  final String _googleApiKey = "APIKEY";
  String? _downloadedImagePath;
  String? _downloadedPlaceName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Search')),
      body:
          _downloadedImagePath != null
              ? Center(
                child: Stack(
                  children: [
                    Image.file(
                      File(_downloadedImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _downloadedImagePath = null;
                              _downloadedPlaceName = null;
                            });
                          },
                          child: const Text('Go back to Live Map'),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Card(
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: _searchController,
                        googleAPIKey: _googleApiKey,
                        debounceTime: 600,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (
                          Prediction prediction,
                        ) async {
                          final url = Uri.parse(
                            'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&key=$_googleApiKey',
                          );
                          final response = await http.get(url);

                          if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            if (data['status'] == 'OK') {
                              final lat =
                                  data['result']['geometry']['location']['lat']
                                      as double;
                              final lng =
                                  data['result']['geometry']['location']['lng']
                                      as double;

                              _mapController?.animateCamera(
                                CameraUpdate.newLatLng(LatLng(lat, lng)),
                              );

                              setState(() {
                                _markers.clear();
                                _markers.add(
                                  Marker(
                                    markerId: MarkerId(prediction.placeId!),
                                    position: LatLng(lat, lng),
                                    infoWindow: InfoWindow(
                                      title: data['result']['name'],
                                      snippet:
                                          data['result']['formatted_address'],
                                    ),
                                  ),
                                );
                              });
                            }
                          }
                        },
                        itemClick: (Prediction prediction) {
                          _searchController.text = prediction.description!;
                          _searchController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _searchController.text.length),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_searchController.text.isNotEmpty) {
                            _downloadMap(_searchController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a place to download.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Download Map'),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Future<void> _downloadMap(String placeName) async {
    final position = await _mapController?.getLatLng(
      const ScreenCoordinate(x: 300, y: 200),
    );
    final zoom = await _mapController?.getZoomLevel();

    if (position == null || zoom == null) return;

    FileDownloader.downloadFile(
      url:
          'https://maps.googleapis.com/maps/api/staticmap?center=${position.latitude},${position.longitude}&zoom=$zoom&size=600x400&markers=color:red|${position.latitude},${position.longitude}&key=$_googleApiKey',
      name: 'map_${DateTime.now().millisecondsSinceEpoch}.png',
      onDownloadCompleted: (path) async {
        final prefs = await SharedPreferences.getInstance();
        List<String> maps = prefs.getStringList('downloaded_maps') ?? [];
        maps.add('$placeName|$path');
        await prefs.setStringList('downloaded_maps', maps);

        setState(() {
          _downloadedImagePath = path;
          _downloadedPlaceName = placeName;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Map downloaded!')));
      },
      onDownloadError: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $error')));
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
