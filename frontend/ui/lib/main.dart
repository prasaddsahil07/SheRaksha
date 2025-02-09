import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/socket_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controls/keeplog.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:path_provider/path_provider.dart';

/// Flutter code sample for [AboutListTile].

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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

class Friend {
  final String id;
  final String name;
  final String email;

  Friend({required this.id, required this.name, required this.email});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['_id'],
      name: json['firstName'],
      email: json['email'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final formk = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController addrController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  bool _isLoggedIn = false;
  String _userName = "User";
  String? token;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  get onPressed => null;

  Future<void> _saveLoginStatus(bool isLoggedIn, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('userName', userName);
    await prefs.setString('token', token!);
  }

  Future<void> _loadLoginStatus() async {
    final status = await checkLoginStatus();
    setState(() {
      _isLoggedIn = status['isLoggedIn'];
      _userName = status['userName'];
      token = status['token'];
    });
  }

  Future<bool> _logForm() async {
    if (formk.currentState!.validate()) {
      formk.currentState!.save();

      final String email = emailController.text;
      final String password = passController.text;
      final String gender = 'Female';

      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'gender': gender,
      };

      final String apiUrl =
          'http://172.16.16.126:5000/api/v1/user/login'; // For local development

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          log("User logged in!");
          String? cookie = response.headers['set-cookie'];
          if (cookie != null) {
            List<String> cookies = cookie.split(';');

            for (String c in cookies) {
              if (c.trim().startsWith('token=')) {
                token = c.trim().substring(6);
              }
            }
          }
          return true;
        } else {
          log("Error: ${response.body}");
          return false;
        }
      } catch (e) {
        log("Error connecting to backend: $e");
        return false;
      }
    }
    return false;
  }

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
              child: Form(
                key: formk,
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
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    bool check = await _logForm();
                    if (check) {
                      setState(() {
                        _isLoggedIn = true;
                        _userName = emailController.text;
                      });
                      await _saveLoginStatus(true, emailController.text);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('Sign In'))
            ],
          );
        });
  }

  Future<void> _regForm() async {
    if (formk.currentState!.validate()) {
      formk.currentState!.save();

      final String fname = fnameController.text;
      final String lName = lnameController.text;
      final String email = emailController.text;
      final String password = passController.text;
      final String addr = addrController.text;
      final String ph = phoneController.text;
      final String gender = 'Female';

      final Map<String, dynamic> data = {
        'firstName': fname,
        'lastName': lName,
        'email': email,
        'password': password,
        'gender': gender,
        'address': addr,
        'phone': ph
      };

      final String apiUrl =
          'http://172.16.16.126:5000/api/v1/user/register'; // For local development

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
          String? cookie = response.headers['set-cookie'];
          if (cookie != null) {
            List<String> cookies = cookie.split(';');

            for (String c in cookies) {
              if (c.trim().startsWith('token=')) {
                token = c.trim().substring(6);
              }
            }
          }
        } else {
          log("Error: ${response.body}");
        }
      } catch (e) {
        log("Error connecting to backend: $e");
      }
    }
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
              child: Form(
                key: formk,
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      controller: fnameController,
                      keyboardType: TextInputType.name,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      controller: lnameController,
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
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Address"),
                      controller: addrController,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: "Phone Number"),
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
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
                    _regForm();
                    setState(() {
                      _isLoggedIn = true;
                      _userName = fnameController.text;
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
      final String email = emailController.text;
      // final String password = passController.text;

      final Map<String, dynamic> data = {'friendEmail': email};

      final String apiUrl =
          'http://172.16.16.126:5000/api/v1/friend/add'; // For local development

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Cookie': "token=$token"
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          log("User registered successfully!");
          Navigator.of(context).pop();
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
  Future<List<Friend>> fetchFriends(String token) async {
    final String apiUrl =
        'http://172.16.16.126:5000/api/v1/friend/list'; // Replace with your actual API endpoint
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Cookie': "token=$token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> friendsJson = data['friends'];
          List<Friend> friends =
              friendsJson.map((json) => Friend.fromJson(json)).toList();
          return friends;
        } else {
          throw Exception('Failed to load friends: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to load friends: Status Code ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching friends: $e');
      rethrow;
    }
  }

  Future<void> removeFriend(String token, String friendId) async {
    // Adjust the endpoint URL as needed
    final String apiUrl = 'http://172.16.16.126:5000/api/v1/friend/remove';

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Passing token via a cookie header; adjust as needed for your auth scheme.
          'Cookie': 'token=$token',
        },
        // Sending friendId in the request body as JSON.
        body: jsonEncode({'friendId': friendId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Successfully removed friend.
          print(data['message']);
          Navigator.of(context).pop();
        } else {
          throw Exception('Failed to remove friend: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to remove friend: Status Code ${response.statusCode}');
      }
    } catch (e) {
      log('Error removing friend: $e');
      rethrow;
    }
  }

  void showFriendsDialog(BuildContext context, String token) async {
    try {
      List<Friend> friends = await fetchFriends(token);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Manage Friends'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Card(
                    elevation: 3,
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(friend.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(friend.name),
                      subtitle: Text(friend.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            await removeFriend(token, friend.id);
                            // Optionally update your UI (e.g., remove the friend from a list) after deletion.
                          } catch (e) {
                            // Display an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error removing friend: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle the error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load friends: $e')),
      );
    }
  }

  void fetchUser(String userId) async {
    final url = Uri.parse('http://172.16.16.126:5000/api/v1/getUser/$userId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
          // Passing token via a cookie header; adjust as needed for your auth scheme.
      'Cookie': 'token=$token',
    });
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log("User data: ${[data['user']]}");
    } else {
      log("Error: ${response.statusCode} - ${response.body}");
    }
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
      body: token == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(alignment: Alignment.topRight, children: [
              Mapps(token: token!), // Token is guaranteed to be non-null here
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll<Color>(Colors.red)),
                    onPressed: () {fetchUser(_userName);} ,
                    child: const Text(
                      "SOS Button",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ]),
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
              title: const Text('Manage Friends'),
              onTap: () {
                // Update the state of the app
                // _onItemTapped(1);
                // Then close the drawer
                showFriendsDialog(context, token!);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                spacing: 30,
                children: [const Text('Log Out!'), Icon(Icons.exit_to_app)],
              ),
              onTap: () async {
                // Update the state of the app
                // _onItemTapped(2);
                // Then close the drawer
                await logoutUser();

                // Update the local state to reflect that the user is logged out
                setState(() {
                  _isLoggedIn = false;
                  _userName = 'User';
                });
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
  final String token;
  const Mapps({super.key, required this.token});

  @override
  State<Mapps> createState() => _MappsState();
}

class _MappsState extends State<Mapps> {
  final MapController _mapController = MapController();
  Timer? _locationTimer;
  LatLng currentPosition = LatLng(51.509364, -0.128928);
  double _crimeSeverity = 0.0;
  List<dynamic> _gridData = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
    _getUserLocation();

    _updateLocationAndGrid();
    //Refresh every 5 seconds
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateLocationAndGrid();
    });
    socketService = SocketService(userId: '67a62b05a2f7d6c57bcf674f');
    socketService.initSocket();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    socketService.dispose();
    super.dispose();   
  }

  Future<void> requestPermission() async {
    final permission = Permission.location;

    if (await permission.isDenied) {
      await permission.request();
    }
  }

  // Get the current location and update the surrounding grid.
  // Request grid data (predictions for surrounding points) from the Flask API.
  void _getGridData(LatLng center) async {
    const String flaskEndpoint = 'http://172.16.16.125:12346/api_grid';
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    try {
      final response = await http.post(
        Uri.parse(flaskEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'latitude': center.latitude,
          'longitude': center.longitude,
          'timestamp': formattedDateTime,
          'male-female-ratio': 1.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // The response is expected to have a key 'grid' containing a list of predictions.
        setState(() {
          _gridData = responseData['grid'];
          log("New grid data: $_gridData");
        });
      } else {
        log("Error: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching grid data from Flask: $e");
    }
  }

  void _updateLocationAndGrid() async {
    try {
      var position = await GeolocatorPlatform.instance.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(currentPosition, 16);
      _getGridData(currentPosition);
    } catch (e) {
      log("Error getting user location: $e");
    }
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(locationSettings: LocationSettings());
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController.move(currentPosition, 16);
    _sendLocationtoFlask(currentPosition);
  }

  Future<void> _redirectToGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    await launchUrl(googleMapsUrl);
  }


  void _redirectToSafeLocation() {
    if (_gridData.isEmpty) {
      log('No grid data available for safe location redirection.');
      return;
    }

    final safePoint = _gridData.reduce((curr, next) =>
        (curr['predicted_crime_severity'] as num) < (next['predicted_crime_severity'] as num)
            ? curr
            : next);

    final double safeLat = (safePoint['latitude'] as num).toDouble();
    final double safeLon = (safePoint['longitude'] as num).toDouble();
    LatLng safeLocation = LatLng(safeLat, safeLon);

    _mapController.move(safeLocation, 16);
    _redirectToGoogleMaps(safeLat, safeLon);
  }

  void _sendLocationtoFlask(LatLng location) async {
    const String flaskEndpoint = 'http://172.16.16.125:12345/api';
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

        setState(() {
          _crimeSeverity = predictedSeverity;
        });

        if (predictedSeverity > 5) {
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

  Future<List<Friend>> fetchFriends(String token) async {
    final String apiUrl = 'http://172.16.16.126:5000/api/v1/friend/list';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Cookie': "token=$token"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          List<dynamic> friendsJson = data['friends'];
          return friendsJson.map((json) => Friend.fromJson(json)).toList();
        }
        throw Exception('Failed to load friends: ${data['message']}');
      }
      throw Exception('Failed to load friends: ${response.statusCode}');
    } catch (e) {
      log('Error fetching friends: $e');
      rethrow;
    }
  }

  late SocketService socketService;
  bool isSharingLocation = false;
  
  void _toggleLocationSharing(){
    if (isSharingLocation) {
      socketService.stopLocationSharing();
    }
    else {
      socketService.startLocationSharing();
    }
    setState(() {
      isSharingLocation = !isSharingLocation;
      _showShareOptionsDialog();
    });
  }
  String? _audioPath;
  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() => _audioPath = result.files.single.path!);
      log("Selected audio: $_audioPath");
    }
  }
  
  
  

  void _showShareOptionsDialog() {
    // Get the token from widget
    final String token = widget.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to share')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: 150,
            height: 600,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: AssetImage('assets/back1.png'),fit: BoxFit.cover,)
            ),
            child: Column(
              spacing: 5,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.white,
                    backgroundColor: Colors.white, // Button color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onPressed: () {
                    // TODO: Add your share location logic here
                    _toggleLocationSharing();
                    log('Location shared!');
                  },
                  child: Text(isSharingLocation
                    ? 'Stop Sharing Location'
                    : 'Start Sharing Location'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.white,
                    backgroundColor: Colors.white, // Button color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onPressed: () {
                    // TODO: Add your share location logic here
                    _redirectToSafeLocation();
                    log('Location shared!');
                  },
                  child: Text('Redirect to Safe Location'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.white,
                    backgroundColor: Colors.white, // Button color
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onPressed: () {
                    // TODO: Add your share location logic here
                    log('Media Shared!');
                    showModalBottomSheet(context: context, builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt, size: 30,),
                                title: const Text("Capture Image"),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera,
                                  );
                                  if (image != null) {
                                    log("Image captured: ${image.path}");
                                  }
                                  else{
                                    log("No image captured.");
                                  }
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.audiotrack),
                                title: Text("Upload Audio"),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickAudioFile();
                                  log("Audio uploaded");
                                },
                              ),
                          ],
                        ),
                      );
                    });
                  },
                  child: Text('Share Media'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create circle markers for each grid point.
    final heatmapPoints = _gridData.map<WeightedLatLng>((point) {
      final severity = (point['predicted_crime_severity'] as num).toDouble();
      return WeightedLatLng(
        LatLng(
          (point['latitude'] as num).toDouble(),
          (point['longitude'] as num).toDouble(),
        ),
        severity, // This weight drives the intensity on the heatmap.
      );
    }).toList();

    return FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: currentPosition,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ui',
          ),
          if (heatmapPoints.isNotEmpty)
            HeatMapLayer(
              key: ValueKey(_gridData.hashCode),
              heatMapDataSource: InMemoryHeatMapDataSource(data: heatmapPoints),
              heatMapOptions: HeatMapOptions(
                radius: 35,
                minOpacity: 0.3,
                blurFactor: 0.5,
                layerOpacity: 0.75,
                // Define a gradient mapping weight values to colors.
                gradient: {
                  0.2: Colors.green,
                  0.5: Colors.yellow,
                  1.0: Colors.red,
                },
              ),
              // If your version of the plugin expects a reset stream, include it; otherwise, remove.
              reset: Stream.empty(),
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: currentPosition,
                width: 80,
                height: 80,
                child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
              ),
            ],
          ),
        ]);
  }
}
