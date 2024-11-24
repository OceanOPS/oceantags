import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/data_screen.dart';
import 'screens/photos_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OceanDemo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Background color of the bar
          selectedItemColor: Color.fromARGB(255, 156, 9, 201), // Color for selected items
          unselectedItemColor: Colors.black54, // Color for unselected items
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MapScreen(),
    QRScanScreen(),
    PhotosScreen(),
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
        title: Text(
          'OceanDemo',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            color: Color.fromARGB(255, 156, 9, 201),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 28, 28, 28), // AppBar background color
        elevation: 0, // Remove shadow
        centerTitle: true, // Center the title
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Data',
          ),
        ],
      ),
    );
  }
}
