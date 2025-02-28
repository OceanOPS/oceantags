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

  @override
  void initState() {
    super.initState();
    _db = widget.database;
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
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name for the platform';
                                }
                                return null;
                              },
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
                                    const PlatformEntity(
                                      reference: 'Test',
                                      latitude: -6.5,
                                      longitude: 113.4,
                                      status: 'inactive',
                                      network: 'sot',
                                      model: 'Generic Manual',
                                      isFavorite: false,
                                    ),
                                  );
                                  print('platform added');
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
