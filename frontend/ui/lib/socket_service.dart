// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  final String userId;

  SocketService({required this.userId});

  /// Initialize and connect the socket
  void initSocket() {
    // Replace with your server URL and port (e.g., http://192.168.1.10:3000)
    socket = IO.io('http://172.16.16.126:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // Connect the socket
    socket.connect();

    // Connection established
    socket.on('connect', (_) {
      print('Connected to socket server with id: ${socket.id}');
      // Register the user with the backend
      socket.emit('registerUser', userId);
    });

    // Listen for friend location update event
    socket.on('friendLocationUpdate', (data) {
      print('Received friend location update: $data');
      // Here you can update your app's UI as needed
    });

    // Optional: Listen for when a friend starts or stops sharing their location
    socket.on('friendStartedSharingLocation', (data) {
      print('Friend started sharing location: $data');
    });

    socket.on('friendStoppedSharingLocation', (data) {
      print('Friend stopped sharing location: $data');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from socket server');
    });
  }

  /// Emit a location update to the backend
  void updateLocation(double lat, double lon) {
    socket.emit('updateLocation', {
      'userId': userId,
      'lat': lat,
      'lon': lon,
    });
    print('Emitted updateLocation: lat=$lat, lon=$lon');
  }

  /// Optional: Emit start location sharing event
  void startLocationSharing() {
    socket.emit('startLocationSharing', {
      'userId': userId,
    });
    print('Emitted startLocationSharing for $userId');
  }

  /// Optional: Emit stop location sharing event
  void stopLocationSharing() {
    socket.emit('stopLocationSharing', {
      'userId': userId,
    });
    print('Emitted stopLocationSharing for $userId');
  }

  /// Clean up the socket connection
  void dispose() {
    socket.dispose();
  }
}
