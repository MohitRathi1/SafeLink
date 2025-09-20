import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPersonPage extends StatefulWidget {
  final String googleApiKey;

  const AddPersonPage({super.key, required this.googleApiKey});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedTag = 'friend'; // Default tag
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode addressFocusNode = FocusNode();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    addressFocusNode.dispose();
    super.dispose();
  }

  /// Save contact info into SharedPreferences
  Future<void> _saveContact() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> contacts = prefs.getStringList('contacts') ?? [];

    // Save as "name|phone|address|tag"
    contacts.add(
      "${nameController.text.trim()}|${phoneController.text.trim()}|${addressController.text.trim()}|$selectedTag",
    );

    await prefs.setStringList('contacts', contacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Contact'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NAME
                  TextFormField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(phoneFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),

                  // PHONE
                  TextFormField(
                    controller: phoneController,
                    focusNode: phoneFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(addressFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ADDRESS (Google Places)
                  GooglePlaceAutoCompleteTextField(
                    textEditingController: addressController,
                    focusNode: addressFocusNode,
                    googleAPIKey: widget.googleApiKey,
                    inputDecoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    debounceTime: 800,
                    countries: const ['us', 'in'],
                    isLatLngRequired: false,
                    getPlaceDetailWithLatLng: (Prediction prediction) {},
                    itemClick: (Prediction prediction) {
                      addressController.text = prediction.description ?? '';
                      addressController.selection = TextSelection.fromPosition(
                        TextPosition(offset: prediction.description?.length ?? 0),
                      );
                    },
                    textInputAction: TextInputAction.done,
                    validator: (value, context) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // TAG DROPDOWN
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setModalState) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedTag,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                            style: const TextStyle(color: Colors.black87),
                            onChanged: (String? newValue) {
                              setModalState(() {
                                selectedTag = newValue!;
                              });
                            },
                            items: <String>[
                              'friend',
                              'father',
                              'mother',
                              'siblings',
                              'teacher',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.capitalize()),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _saveContact();

                        // Pop back and refresh list
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Add Contact',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// String extension with null/empty safety
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
