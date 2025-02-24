import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/search_screen.dart';
import 'package:oceantags/database/db.dart'; // ✅ Import Drift database
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Drift Database
  final database = PlatformDatabase();

  Object? initErr;
  try {
    // ✅ Initialize tile caching backend
    await FMTCObjectBoxBackend().initialise();
    final store = FMTCStore('mapStore');
    await store.manage.create();
  } catch (err) {
    initErr = err;
  }

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final PlatformDatabase database; // ✅ Pass Drift database

  const MyApp({Key? key, required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OceanTags',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(137, 26, 255, 1),
          brightness: Brightness.light,
        ),
        fontFamily: 'M3',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(137, 26, 255, 1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'M3',
      ),
      themeMode: ThemeMode.system, // ✅ Use system theme
      home: HomeScreen(database: database), // ✅ Pass database to HomeScreen
    );
  }
}

class HomeScreen extends StatefulWidget {
  final PlatformDatabase database; // ✅ Receive Drift database

  const HomeScreen({Key? key, required this.database}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
