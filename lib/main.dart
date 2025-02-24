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

  runApp(OceanTagsApp(database: database));
}

/// 🔹 Stateful Widget to Control ThemeMode
class OceanTagsApp extends StatefulWidget {
  final AppDatabase database;

  const OceanTagsApp({Key? key, required this.database}) : super(key: key);

  @override
  _OceanTagsAppState createState() => _OceanTagsAppState();
}

class _OceanTagsAppState extends State<OceanTagsApp> {
  bool _isDarkMode = false;

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
    final seedColor = const Color.fromRGBO(137, 26, 255, 1);

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
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: OceanTagsHome(
        database: database,
        toggleDarkMode: toggleDarkMode,
      ),
    );
  }
}

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
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 28),
          color: colorScheme.onSurfaceVariant,
          onPressed: () {
            print("User profile clicked!");
          },
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'M3',
              fontSize: 20.0,
              color: colorScheme.onSurface,
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
                widget.toggleDarkMode();
              }
            },
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "toggle_dark_mode",
                child: Row(
                  children: [
                    Icon(
                      Theme.of(context).brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: colorScheme.onSurfaceVariant,
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapScreen(database: widget.database),
          SearchScreen(database: widget.database), 
          QRScanScreen(database: widget.database),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
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
