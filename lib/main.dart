import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/search_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'platform_model.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(PlatformModelAdapter());

  // ✅ Load theme preference from Hive
  var box = await Hive.openBox('settings');
  bool isDarkMode = box.get('darkMode', defaultValue: false);

  Object? initErr;
  try {
    // ✅ Initialize tile caching backend
    await FMTCObjectBoxBackend().initialise();
    final store = FMTCStore('mapStore');
    await store.manage.create();
  } catch (err) {
    initErr = err;
  }

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  MyApp({required this.isDarkMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  /// ✅ Toggles Dark/Light Mode and saves it to Hive
  void _toggleDarkMode() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    var box = await Hive.openBox('settings');
    box.put('darkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OceanTags',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true, // ✅ Enable Material 3
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(137, 26, 255, 1), // ✅ Single source of color
          brightness: Brightness.light,
        ),
        fontFamily: 'M3', // ✅ Material 3 Typography
      ),
      darkTheme: ThemeData(
        useMaterial3: true, // ✅ Enable Material 3
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(137, 26, 255, 1), // ✅ Single source of color
          brightness: Brightness.dark,
        ),
        fontFamily: 'M3',
      ),
      home: HomeScreen(toggleDarkMode: _toggleDarkMode, isDarkMode: _isDarkMode),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  HomeScreen({required this.toggleDarkMode, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MapScreen(),
    SearchScreen(),
    QRScanScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface, // ✅ Depends on seed color
        foregroundColor: colorScheme.onSurface, // ✅ Dynamic based on theme
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 28),
          color: colorScheme.onSurfaceVariant, // ✅ Matches Material 3
          onPressed: () {
            print("User profile clicked!");
          },
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'M3',
              fontSize: 20.0,
              color: colorScheme.onSurface, // ✅ Adapts to theme
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
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface), // ✅ Matches theme
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "toggle_dark_mode",
                child: Row(
                  children: [
                    Icon(
                      widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: colorScheme.onSurfaceVariant, // ✅ Theme-based
                    ),
                    SizedBox(width: 10),
                    Text(widget.isDarkMode ? "Light Mode" : "Dark Mode"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer, // ✅ This highlights selected button
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.map),
            selectedIcon: Icon(Icons.map, color: colorScheme.onPrimaryContainer), // ✅ Highlighted Icon
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: colorScheme.onPrimaryContainer), // ✅ Highlighted Icon
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            selectedIcon: Icon(Icons.qr_code_scanner, color: colorScheme.onPrimaryContainer),
            label: 'Scan',
          ),
        ],
      )
,
    );
  }
}
