import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AddPersonPage.dart'; // Import the new AddPersonPage

class MySpotPage extends StatefulWidget {
  const MySpotPage({super.key});

  @override
  State<MySpotPage> createState() => _MySpotPageState();
}

class _MySpotPageState extends State<MySpotPage> {
  List<Map<String, dynamic>> _contacts = [];
  int _nextId = 1;
  final String _googleApiKey = 'APIKEY'; // Your provided Google API key

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('contacts') ?? [];
    setState(() {
      _contacts =
          contactsJson
              .map((json) => jsonDecode(json) as Map<String, dynamic>)
              .toList();
    });
    _nextId = prefs.getInt('next_id') ?? 1;
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson =
        _contacts.map((contact) => jsonEncode(contact)).toList();
    await prefs.setStringList('contacts', contactsJson);
    await prefs.setInt('next_id', _nextId);
  }

  void _addContact() async {
    final newContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPersonPage(googleApiKey: _googleApiKey),
      ),
    );
    if (newContact != null) {
      setState(() {
        _contacts.add({'id': _nextId, ...newContact});
        _nextId++;
      });
      _saveContacts();
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newContact['name']} added successfully!')),
      );
    }
  }

  void _deleteContact(int id) {
    setState(() {
      _contacts.removeWhere((contact) => contact['id'] == id);
    });
    _saveContacts();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _broadcastHelp() async {
    Position? position = await _getCurrentLocation();
    if (position == null) {
      return;
    }

    String lat = position.latitude.toString();
    String long = position.longitude.toString();

    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Broadcast Help'),
            content: TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Add note'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String message =
                      'Help! My current location: $lat, $long. ${noteController.text}';
                  List<String> phones =
                      _contacts.map((c) => c['phone'] as String).toList();
                  if (phones.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No contacts available')),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  String recipients = phones.join(',');
                  Uri uri = Uri.parse(
                    'sms:$recipients?body=${Uri.encodeComponent(message)}',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch SMS app')),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  Future<void> _call(String phone) async {
    Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  Future<void> _text(String phone) async {
    Position? position = await _getCurrentLocation();
    if (position == null) {
      return;
    }

    String lat = position.latitude.toString();
    String long = position.longitude.toString();
    String message = 'My current location: $lat, $long';

    Uri uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch SMS app')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addContact),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _broadcastHelp,
              icon: const Icon(Icons.warning_amber, color: Colors.white),
              label: const Text(
                'Broadcast Help Message',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _contacts.isEmpty
                    ? const Center(
                      child: Text(
                        'No connections added yet.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        var contact = _contacts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                contact['name'][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              contact['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  contact['tag'].capitalize(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(contact['phone']),
                                Text(contact['address']),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _call(contact['phone']),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.message,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _text(contact['phone']),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _deleteContact(contact['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
