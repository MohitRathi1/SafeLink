// MySpotPage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'AddPersonPage.dart'; // We'll create this next

class MySpotPage extends StatefulWidget {
  const MySpotPage({super.key});

  @override
  _MySpotPageState createState() => _MySpotPageState();
}

class _MySpotPageState extends State<MySpotPage> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;
  String _currentLocation = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _determinePosition();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsString = prefs.getString('my_contacts') ?? '[]';
    setState(() {
      _contacts = jsonDecode(contactsString);
      _isLoading = false;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = 'Location permissions are permanently denied.';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation =
          'Lat: ${position.latitude}, Lng: ${position.longitude}';
    });
  }

  Future<void> _deleteContact(int id) async {
    final prefs = await SharedPreferences.getInstance();
    _contacts.removeWhere((contact) => contact['id'] == id);
    await prefs.setString('my_contacts', jsonEncode(_contacts));
    setState(() {});
  }

  Future<void> _callContact(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendSms(String phoneNumber, String message) async {
    try {
      String result = await sendSMS(message: message, recipients: [phoneNumber]);
      print(result);
    } catch (error) {
      print(error);
    }
  }

  Future<void> _broadcastHelpMessage() async {
    final phoneNumbers = _contacts.map((contact) => contact['phone']).toList();
    if (phoneNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contacts to send message to.')),
      );
      return;
    }

    String message = 'Help! I am in an emergency. My current location is $_currentLocation.';
    try {
      await sendSMS(message: message, recipients: phoneNumbers.cast<String>());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Help message sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPersonPage()),
              );
              _loadContacts(); // Refresh list after adding a person
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Broadcast Help Message',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text('Your current location: $_currentLocation'),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _broadcastHelpMessage,
                            icon: const Icon(Icons.warning_amber),
                            label: const Text('Broadcast Help'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'My Connections',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _contacts.isEmpty
                        ? const Center(child: Text('No connections added yet.'))
                        : ListView.builder(
                            itemCount: _contacts.length,
                            itemBuilder: (context, index) {
                              final contact = _contacts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(contact['tag'][0].toUpperCase()),
                                  ),
                                  title: Text(contact['name']),
                                  subtitle: Text('${contact['phone']} (${contact['tag']})'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.phone, color: Colors.green),
                                        onPressed: () => _callContact(contact['phone']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.message, color: Colors.blue),
                                        onPressed: () => _sendSms(
                                          contact['phone'],
                                          'Hello, I am reaching out from My Spot App.',
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteContact(contact['id']),
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
            ),
    );
  }
}