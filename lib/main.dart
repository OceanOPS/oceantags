import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/search_screen.dart';
import 'package:oceantags/database/db.dart'; 
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Drift Database
  final database = AppDatabase();

  Object? initErr;
  try {
    // ✅ Initialize tile caching backend
    await FMTCObjectBoxBackend().initialise();
    final store = FMTCStore('mapStore');
    await store.manage.create();
  } catch (err) {
    initErr = err;
  }

  runApp(OceanTagsApp(database: database)); // ✅ Start the app
}

/// 🔹 Stateful Widget to Control ThemeMode
class OceanTagsApp extends StatefulWidget {
  final AppDatabase database;

  const OceanTagsApp({Key? key, required this.database}) : super(key: key);

  @override
  _OceanTagsAppState createState() => _OceanTagsAppState();
}

class _OceanTagsAppState extends State<OceanTagsApp> {
  bool _isDarkMode = false; // ✅ Track dark mode state

  /// ✅ Toggles Dark/Light Mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OceanTagsTheme(
      isDarkMode: _isDarkMode,
      toggleDarkMode: _toggleDarkMode,
      database: widget.database,
    );
  }
}

/// 🔹 Separate Widget for Theme Handling (Ensures Proper Updates)
class OceanTagsTheme extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleDarkMode;
  final AppDatabase database;

  const OceanTagsTheme({
    Key? key,
    required this.isDarkMode,
    required this.toggleDarkMode,
    required this.database,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final seedColor = const Color.fromRGBO(137, 26, 255, 1); // ✅ Define seed color once

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
      fontFamily: 'M3',
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
      fontFamily: 'M3',
    );

    return MaterialApp(
      title: 'OceanTags',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // ✅ Toggle theme
      home: OceanTagsHome(
        database: database,
        toggleDarkMode: toggleDarkMode,
      ),
    );
  }
}

/// 🔹 Main Scaffold with AppBar & Navigation
class OceanTagsHome extends StatefulWidget {
  final AppDatabase database;
  final VoidCallback toggleDarkMode;

  const OceanTagsHome({
    Key? key,
    required this.database,
    required this.toggleDarkMode,
  }) : super(key: key);

  @override
  _OceanTagsHomeState createState() => _OceanTagsHomeState();
}

class _OceanTagsHomeState extends State<OceanTagsHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface, // ✅ Now based on seed color
        foregroundColor: colorScheme.onSurface, // ✅ Adapts to dark mode
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 28),
          color: colorScheme.onSurfaceVariant, // ✅ Now based on theme
          onPressed: () {
            print("User profile clicked!");
          },
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'M3',
              fontSize: 20.0,
              color: colorScheme.onSurface, // ✅ Now based on theme
            ),
            children: [
              TextSpan(text: 'Ocean', style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(text: 'Tags', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "toggle_dark_mode") {
                widget.toggleDarkMode(); // ✅ Toggle Dark Mode
              }
            },
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface), // ✅ Based on theme
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "toggle_dark_mode",
                child: Row(
                  children: [
                    Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: colorScheme.onSurfaceVariant, // ✅ Based on theme
                    ),
                    SizedBox(width: 10),
                    Text(Theme.of(context).brightness == Brightness.dark ? "Light Mode" : "Dark Mode"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack( // ✅ Keeps state when switching tabs
        index: _selectedIndex,
        children: [
          MapScreen(database: widget.database),
          SearchScreen(database: widget.database), 
          QRScanScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface, // ✅ Now based on theme
        indicatorColor: colorScheme.primaryContainer, // ✅ Matches theme
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.map),
            selectedIcon: Icon(Icons.map, color: colorScheme.onPrimaryContainer),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: colorScheme.onPrimaryContainer),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            selectedIcon: Icon(Icons.qr_code_scanner, color: colorScheme.onPrimaryContainer),
            label: 'Scan',
          ),
        ],
      ),
    );
  }
}
