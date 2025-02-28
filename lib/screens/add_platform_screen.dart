import 'package:flutter/material.dart';
import '../database/db.dart';

class AddPlatformScreen extends StatefulWidget {
  final AppDatabase database;

  const AddPlatformScreen({Key? key, required this.database}) : super(key: key);

  @override
  AddPlatformScreenState createState() {
    return AddPlatformScreenState();
  }
}

class AddPlatformScreenState extends State<AddPlatformScreen> {
  late AppDatabase _db;
  final _formKey = GlobalKey<FormState>();
  final referenceController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final networkController = TextEditingController();
  final modelController = TextEditingController();
  List<String> _statusOptions = ["OPERATIONAL", "INACTIVE", "PROBABLE", "REGISTERED", "CONFIRMED"];
  String? _selectedStatusOption;

  @override
  void initState() {
    super.initState();
    _db = widget.database;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    referenceController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    networkController.dispose();
    modelController.dispose();
    super.dispose();
  }

  void addPlatform(PlatformEntity platform) async {
    await _db.insertPlatform(platform);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add platform", style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // 🔹 Platform Details (Inside a Card)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("New Platform", style: textTheme.titleLarge),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: colorScheme.primary), // ✅ Themed divider

                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              controller: referenceController,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name for the platform';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                              ),
                              controller: latitudeController,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                              ),
                              controller: longitudeController,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Model',
                              ),
                              controller: modelController,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Network',
                              ),
                              controller: networkController,
                            ),
                            DropdownButtonFormField(
                              decoration: const InputDecoration(
                                labelText: 'Status',
                              ),
                              hint: Text('Select status'),
                              value: _selectedStatusOption,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedStatusOption = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a status';
                                }
                                return null;
                              },
                              items: _statusOptions.map((option) {
                                return DropdownMenuItem(
                                  child: new Text(option),
                                  value: option,
                                );
                              }).toList(),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(Icons.save),
                              label: Text("Save"),
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate()) {
                                  // If the form is valid, display a snackbar. In the real world,
                                  // you'd often call a server or save the information in a database.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Processing Data')),
                                  );
                                  _db.insertPlatform(
                                    PlatformEntity(
                                      reference: referenceController.text,
                                      latitude: double.tryParse(latitudeController.text) ?? 00.00,
                                      longitude: double.tryParse(longitudeController.text) ?? 00.00,
                                      status: _selectedStatusOption!,
                                      network: networkController.text,
                                      model: modelController.text,
                                      isFavorite: false,
                                      unsynced: true
                                    ),
                                  );
                                  print('********* platform added ***********');
                                  print(referenceController.text);
                                }
                              },
                            ),// Add TextFormFields and ElevatedButton here.
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
