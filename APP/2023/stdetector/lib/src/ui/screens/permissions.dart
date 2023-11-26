import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stdetector/src/ui/screens/home.dart';

class Permissions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  bool permissionsBluetooth = false;
  bool permissionsGps = false;

  Future<void> requestBluetoothPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isGranted) {
      setState(() {
        permissionsBluetooth = true;
      });
      // Bluetooth permission granted, proceed with Bluetooth functionality
    } else {
      // Bluetooth permission denied
    }
  }

  bool get _permissionsGranted => permissionsBluetooth & permissionsGps;

  void requestLocationPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        permissionsGps = true;
      });
    } else {
      // Location permission denied
    }
  }

  @override
  void initState() {
    requestBluetoothPermissions();
    requestLocationPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grant permissions"),
      ),
      body: Center(
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.blue,
            onSurface: Colors.red,
          ),
          onPressed: () {
            if (_permissionsGranted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            } else {
              requestBluetoothPermissions();
              requestLocationPermissions();
            }
          },
          child: _permissionsGranted
              ? Text('Go to Stress Detector')
              : Text("Grant permissions"),
        ),
      ),
    );
  }
}
