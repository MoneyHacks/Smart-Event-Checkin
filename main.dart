import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(EventCheckInApp());
  } catch (e) {
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  ErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Firebase Initialization Error: $error"),
        ),
      ),
    );
  }
}

class EventCheckInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Check-In',
      home: EventCheckInScreen(), // Corrected line
    );
  }
}

class EventCheckInScreen extends StatefulWidget {
  @override
  _EventCheckInScreenState createState() => _EventCheckInScreenState();
}

class _EventCheckInScreenState extends State<EventCheckInScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _eventNameController = TextEditingController();
  final _attendeeNameController = TextEditingController();

  Future<void> _checkIn() async {
    final eventName = _eventNameController.text;
    final attendeeName = _attendeeNameController.text;

    if (eventName.isNotEmpty && attendeeName.isNotEmpty) {
      try {
        await _firestore.collection('checkins').add({
          'eventName': eventName,
          'attendeeName': attendeeName,
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Checked In Successfully!")),
        );
        _eventNameController.clear();
        _attendeeNameController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error checking in: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter event and attendee names.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Event Check-In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(labelText: "Event Name"),
            ),
            TextField(
              controller: _attendeeNameController,
              decoration: InputDecoration(labelText: "Attendee Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkIn,
              child: Text("Check In"),
            ),
          ],
        ),
      ),
    );
  }
}