// AddPersonPage.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedTag = 'Friend';
  final List<String> _tags = ['Friend', 'Father', 'Mother', 'Sibling', 'Teacher', 'Other'];
  final String _googleApiKey = "APIKEY"; // Replace with your Places API key

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final contactsString = prefs.getString('my_contacts') ?? '[]';
      List<dynamic> contacts = jsonDecode(contactsString);

      final newContact = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'tag': _selectedTag,
      };

      contacts.add(newContact);
      await prefs.setString('my_contacts', jsonEncode(contacts));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
             GooglePlaceAutoCompleteTextField(
  textEditingController: _addressController,
  googleAPIKey: _googleApiKey,
  debounceTime: 600,
  inputDecoration: const InputDecoration(labelText: 'Address'),
  countries: const ["in"],
  getPlaceDetailWithLatLng: (Prediction prediction) {
    _addressController.text = prediction.description!;
  },
  itemClick: (Prediction prediction) {
    _addressController.text = prediction.description!;
  },
),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedTag,
                decoration: const InputDecoration(labelText: 'Tag'),
                items: _tags.map((String tag) {
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTag = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Add Person'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}