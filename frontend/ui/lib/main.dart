import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Flutter code sample for [AboutListTile].

void main() => runApp(const AboutListTileExampleApp());

class AboutListTileExampleApp extends StatelessWidget {
  const AboutListTileExampleApp({super.key});
  static const title = "SheRaksha";
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(
        title: title,
      ),
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
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _isLoggedIn = false;
  String _userName = "User";

  get onPressed => null;

  Future<void> _signIn() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: SizedBox(
              height: 100,
              child: DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ))),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    controller: passController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      _isLoggedIn = true;
                      _userName = "Logged In User";
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Sign In'))
            ],
          );
        });
  }

  Future<void> _register() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: SizedBox(
              height: 100,
              child: DrawerHeader(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ))),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    controller: nameController,
                    keyboardType: TextInputType.name,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    controller: passController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      _isLoggedIn = true;
                      _userName = nameController.text;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Register'))
            ],
          );
        });
  }

  // Future<void> _submitForm() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();

  //     final String name = nameController.text;
  //     final String email = emailController.text;

  //     final Map<String, dynamic> data = {
  //       'name': name,
  //       'email':email
  //     };

  //     final String apiUrl = 'Insert backend';

  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: <String, String> {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(data),
  //     );
  //   }
  // }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String name = nameController.text;
      final String email = emailController.text;
      final String password = passController.text;

      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password
      };
      final String apiUrl =
          'http://localhost:5000/api/v1/user/register'; // For local development

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          log("User registered successfully!");
        } else {
          log("Error: ${response.body}");
        }
      } catch (e) {
        log("Error connecting to backend: $e");
      }
    }
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

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
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/profile.png')),
                      const SizedBox(width: 20),
                      if (!_isLoggedIn)
                        Column(
                          children: [
                            ElevatedButton(
                                onPressed: _signIn, child: Text("Sign In")),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _register();
                                },
                                child: Text("Register")),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Welcome! $_userName")
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
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text('Add Friendly Users'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    icon: Icon(Icons.email),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: _submitForm, child: Text("Submit"))
                        ],
                      );
                    });
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
                children: [const Text('Log Out!'), Icon(Icons.exit_to_app)],
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
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(locationSettings: LocationSettings());
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(currentPosition, 16);
    _sendLocationtoFlask(currentPosition);
  }

  void _sendLocationtoFlask(LatLng location) async {
    const String flaskEndpoint = 'http://172.16.16.125:5000/api';
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    try {
      final response = await http.post(
        Uri.parse(flaskEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'latitude': location.latitude,
          'longitude': location.longitude,
          'timestamp': formattedDateTime
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        double predictedSeverity = responseData['predicted_crime_severity'];
        log("Predicted crime severity: $predictedSeverity");

        if (predictedSeverity > -1) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Crime Alert"),
                  content: Text("Predicted crime severity: $predictedSeverity"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showShareOptionsDialog();
                        },
                        child: Text("OK"))
                  ],
                );
              });
        } else {
          log("Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      log("Error sending location to Flask: $e");
    }
  }

  void _showShareOptionsDialog() {
    // Sample friend list.
    List<String> friends = ["Alice", "Bob", "Charlie"];
    // Maintain selection state for friends.
    List<bool> selectedFriends = List.generate(friends.length, (_) => false);
    // Options for sharing.
    bool shareLocation = false;
    bool shareImage = false;
    bool recordAudio = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use StatefulBuilder to update state within the dialog.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Share Options"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Friend list section.
                    const Text("Select Friends:"),
                    Column(
                      children: List.generate(friends.length, (index) {
                        return CheckboxListTile(
                          title: Text(friends[index]),
                          value: selectedFriends[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedFriends[index] = value ?? false;
                            });
                          },
                        );
                      }),
                    ),
                    const Divider(),
                    // Sharing options section.
                    const Text("Select options to share:"),
                    CheckboxListTile(
                      title: const Text("Share location"),
                      value: shareLocation,
                      onChanged: (bool? value) {
                        setState(() {
                          shareLocation = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Share image"),
                      value: shareImage,
                      onChanged: (bool? value) {
                        setState(() {
                          shareImage = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text("Record audio"),
                      value: recordAudio,
                      onChanged: (bool? value) {
                        setState(() {
                          recordAudio = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Here, you can handle the selected options.
                    // For example, collect the list of selected friends:
                    List<String> friendsToShare = [];
                    for (int i = 0; i < friends.length; i++) {
                      if (selectedFriends[i]) {
                        friendsToShare.add(friends[i]);
                      }
                    }
                    log("Friends selected: $friendsToShare");
                    log("Share location: $shareLocation");
                    log("Share image: $shareImage");
                    log("Record audio: $recordAudio");

                    Navigator.of(context).pop();
                  },
                  child: const Text("Send"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
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
        ]);
  }
}
