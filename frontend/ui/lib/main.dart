import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

/// Flutter code sample for [AboutListTile].

void main() => runApp(const AboutListTileExampleApp());

class AboutListTileExampleApp extends StatelessWidget {
  const AboutListTileExampleApp({super.key});
  static const title = "SheRaksha";
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: title,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];
  
  get onPressed => null;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Mapps(),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile.png')),
                      ElevatedButton(onPressed: onPressed, 
                      child: Text("Sign In")
                      )
                    ],
                  ),
                  Text("Welcome! User")
                ],
              ),
            ),
            ListTile(
              title: const Text('Add Friends / Emergency Contacts'),
              
              onTap: () {
                // Update the state of the app
                // _onItemTapped();
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Edit existing Contacts'),

              onTap: () {
                // Update the state of the app
                // _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                spacing: 30,
                children: [
                  const Text('School'),
                  Icon(Icons.exit_to_app)
                ],
              ),

              onTap: () {
                // Update the state of the app
                // _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Mapps extends StatefulWidget {
  const Mapps({super.key});

  @override
  State<Mapps> createState() => _MappsState();
}

class _MappsState extends State<Mapps> {
  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();
    requestPermission();
    _getUserLocation();
  }
  Future<void> requestPermission() async {
    final permission = Permission.location;

    if (await permission.isDenied) {
      await permission.request();
    }
  }
  LatLng currentPosition = LatLng(51.509364, -0.128928);

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(locationSettings:  LocationSettings());
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(currentPosition, 16);
  }
  
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 10,
        
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ui',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: currentPosition,
              width: 80,
              height: 80,
              child: Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
      ]
    );
  }
}