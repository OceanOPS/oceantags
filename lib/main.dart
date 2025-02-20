import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/data_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/photos_screen.dart';
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
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 247, 133, 133).withOpacity(0.9),
          unselectedItemColor:Color.fromARGB(255, 28, 28, 28),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Color.fromARGB(255, 28, 28, 28),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 28, 28, 28),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 20, 20, 20),
          selectedItemColor: const Color.fromARGB(255, 247, 133, 133).withOpacity(0.9),
          unselectedItemColor: Colors.white60,
        ),
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
    QRScanScreen(),
    PhotosScreen(),
    AlertsScreen(),
    DataScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.account_circle, size: 28),
        color: widget.isDarkMode
                ? Color.fromARGB(255, 209, 209, 209)
                : Color.fromARGB(255, 63, 63, 63),
        onPressed: () {
          // ✅ Handle user profile action (e.g., show user details)
          print("User profile clicked!");
        },
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            color: widget.isDarkMode
                ? Color.fromARGB(255, 209, 209, 209)
                : Color.fromARGB(255, 63, 63, 63),
          ),
          children: [
            TextSpan(
              text: 'Ocean', // Regular text
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: 'Tags', // Bold text
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "toggle_dark_mode") {
              widget.toggleDarkMode(); // ✅ Toggle Dark/Light Mode
            }
          },
          icon: Icon(Icons.more_vert), // Three-dot menu icon
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: "toggle_dark_mode",
              child: Row(
                children: [
                  Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode ,
                    color: widget.isDarkMode ? const Color.fromARGB(255, 225, 225, 225) : const Color.fromARGB(255, 66, 66, 66),
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
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    ),
  );
}

}
