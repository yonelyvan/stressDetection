import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stdetector/src/bloc/stress_level_block.dart';
import 'package:stdetector/src/model/gsr_buffer.dart';
import 'package:stdetector/src/model/gsr_data_request.dart';
import 'package:stdetector/src/ui/screens/screen_recorders.dart';
import 'package:stdetector/src/ui/widgets/widget_signal.dart';
import 'package:stdetector/src/ui/widgets/widget_stress_level.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:http/http.dart' as http;

import '../../bloc/record_bloc.dart';
import '../../model/gsr_data.dart';
import '../../model/record.dart';
import '../../repository/files.dart';
import 'package:flutter_toastr/flutter_toastr.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //bloc
  StressLevelBlock _stressLevelBlock = StressLevelBlock();

  // Initializing a global key, as it would help us in showing a SnackBar later
  ///final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  double currentValueGSR = 0;
  GSRBuffer gsrBuffer = GSRBuffer();

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;
  int deviceState = 0;
  bool isDisconnecting = false;
  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device; //= BluetoothDevice(address: "null");
  bool connected = false;
  bool isButtonUnavailable = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;

  /// recording Variables
  bool _isRecording = false;
  final RecordBloc _recordBloc = RecordBloc();

  //server
  final txtUrlServer = TextEditingController();

  @override
  void initState() {
    super.initState();
    initBluetooth();
    getUrl().then((value){
      setState(() {
        txtUrlServer.text = value;
      });
    });
  }

  @override
  void dispose()  {
    disposeBluetooth();
    _stressLevelBlock.dispose();
    _recordBloc.dispose();
    txtUrlServer.dispose();
    super.dispose();
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        ///key: scaffoldKey,
        appBar: AppBar(
          title: Text("Stress Detector"),
          //backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            ElevatedButton.icon(
              icon: Icon(
                Icons.bluetooth,
                color: Colors.white,
              ),
              label: Text(
                "Update",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              /*
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),*/
              //splashColor: Colors.deepPurple,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                await getPairedDevices().then((_) {
                  show(context, 'Device list updated');
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: isButtonUnavailable &&
                      bluetoothState == BluetoothState.STATE_ON,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.yellow,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Enable bluetooth',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: bluetoothState.isEnabled,
                        onChanged: (bool value) {
                          future() async {
                            if (value) {
                              await FlutterBluetoothSerial.instance
                                  .requestEnable();
                            } else {
                              await FlutterBluetoothSerial.instance
                                  .requestDisable();
                            }

                            await getPairedDevices();
                            isButtonUnavailable = false;

                            if (connected) {
                              _disconnect(context);
                            }
                          }

                          future().then((_) {
                            setState(() {});
                          });
                        },
                      )
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Device:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DropdownButton(
                                items: _getDeviceItems(),
                                onChanged: (value) {
                                  setState(() {
                                    if (!_devicesList.isEmpty) {
                                      _device = value as BluetoothDevice;
                                    }
                                  });
                                },
                                value: _devicesList.isNotEmpty ? _device : null,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (isButtonUnavailable) {
                                    _turnOnBluetooth(context);
                                  } else {
                                    if (connected) {
                                      _disconnect(context);
                                    } else {
                                      _connect(context);
                                    }
                                  }
                                },

                                /*
                                isButtonUnavailable ? _turnOnBluetooth(context)
                                    : connected
                                        ? _disconnect(context)
                                        : _connect(context),*/
                                child:
                                    Text(connected ? 'Disconnect' : 'Connect'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    /*Container(
                      color: Colors.blue,
                    ),*/
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Config server (Endpoint)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: TextField(
                    controller: txtUrlServer,
                    onChanged: (value){
                      saveUrl(value.trim());
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'http://192.168.0.252:3000/gsr',
                      hintStyle: TextStyle(color: Colors.black12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1, right: 1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ///--------------------- plot
                          WidgetSignal(
                            data: gsrBuffer.getProcessData(),
                            label: "(GSR value: ${currentValueGSR.toString()})",
                          ),
                          //SizedBox(height: 5),

                          ///bloc
                          //Container(color: Colors.black38,height: 2,),
                          /*
                      const Text(
                            "Stress Level",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black38),
                          ),*/
                          //const SizedBox(height: 10),
                          StreamBuilder(
                            stream: _stressLevelBlock.currentStressLevelStream,
                            initialData: 0,
                            builder: (context, snapshot) {
                              ///print(">>>> Stress level:${snapshot.data}");
                              return WidgetStressLevel(
                                  stressLevel: snapshot.data as int);
                            },
                          ),

                          const SizedBox(height: 20),
                          connected
                              ? ElevatedButton.icon(
                                  onPressed: () {
                                    _onRecord(context);
                                  },
                                  icon: Icon(_isRecording
                                      ? Icons.stop_circle
                                      : Icons.directions_run),
                                  label: Text(_isRecording
                                      ? "stop detector"
                                      : "Start detector"), //label text
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors
                                          .blueAccent //elevated btton background color
                                      ),
                                )
                              : Text(""),

                          ///go to settings
                          const SizedBox(height: 40),
                          const Text(
                            "NOTE: If you can't find the device in the list, please pair the device by going to bluetooth settings",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.black26,
                            ),
                          ),

                          const SizedBox(height: 15),
                          TextButton(
                            //elevation: 2,
                            child: Text("Bluetooth settings"),
                            onPressed: () {
                              FlutterBluetoothSerial.instance.openSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: options(context),
      ),
    );
  }

  Widget options(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScreenRecorders()),
          );
        },
        heroTag: null,
      ),
    ]);
  }

  /// Dialoig to insert
  void _dialogInsert(BuildContext c_context) {
    String fn = "";
    showDialog(
        context: c_context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            //title: Text(Translations.of(context).text("new_option")),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        fn = value;
                      },
                      decoration: InputDecoration(labelText: "file name"),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("save"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveFileAndRecorder(c_context, fn);
                },
              )
            ],
          );
        });
  }

  _saveFileAndRecorder(BuildContext cnt, String fileName) {
    List<List<int>> dataSignalSL = gsrBuffer.getMatrixSignalAndStressLevels();
    //todo SAVE
    Files files = Files();
    DateTime current = DateTime.now();
    String fn = "$fileName ${_localFormalDateTime(current)}.csv";
    Record record =
        Record(filename: fn, date: current, samples: dataSignalSL.length);

    ///write on disk
    //files.writeSignal(signal: signal, record: record);
    files.writeSignalAndStressLevels(
        signalAndStressLevels: dataSignalSL, record: record);

    ///write on db
    _recordBloc.addRecord.add(record);
    show(cnt, "saving .csv file");
  }

  _sendToServerRealTime() async {
    if(!_isRecording){
      return;
    }
    String url = txtUrlServer.text.trim();
    if(url.isEmpty){
      return;
    }
    print(">>>$url");
    try{
      final http.Response response = await http.post(
        //Uri.parse('http://192.168.0.252:3000/gsr'),
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'gsr': currentValueGSR.toInt(),
          'current_stress_level': gsrBuffer.currentStressLevel,
          'date_time': DateTime.now().toString(),
        }),
      );
    } catch(e) {
      log(e.toString());
    }

  }

  _onRecord(BuildContext c_context) {
    if (_isRecording) {
      //stop recording & save file
      setState(() {
        _isRecording = !_isRecording;
      });
      _dialogInsert(c_context);
    } else {
      //start recording
      gsrBuffer.clear();
      setState(() {
        _isRecording = !_isRecording;
      });
    }
  }

  _turnOnBluetooth(BuildContext cnt) {
    show(cnt, 'Turn on bluetooth');
  }

  void disposeBluetooth() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();

      ///connection = null;
      connection!.finish();
    }
  }

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    /// Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  void initBluetooth() {
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        bluetoothState = state;
      });
    });
    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        bluetoothState = state;
        if (bluetoothState == BluetoothState.STATE_OFF) {
          isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? ""),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect(BuildContext cnt) async {
    setState(() {
      isButtonUnavailable = true;
    });
    if (_device == null) {
      show(cnt, 'No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device?.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            connected = true;
          });
          connection!.input?.listen(_onDataReceived).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show(cnt, 'Device connected');

        setState(() => isButtonUnavailable = false);
      }
    }
  }

  _onDataReceived(Uint8List data) {
    //[10] == '\n'
    if (data[0] != 10) {
      String strFromArduino = ascii.decode(data);
      double r = double.parse(strFromArduino);
      print(">>> SIG: $r, (${data.toString()})");
      setState(() {
        currentValueGSR = r;
      });
      if (_isRecording) {
        gsrBuffer.push(r);
        _updateStressLevel();
      }
      //send to server
      _sendToServerRealTime();
    }
  }

  // Method to disconnect bluetooth
  void _disconnect(BuildContext cnt) async {
    setState(() {
      isButtonUnavailable = true;
      deviceState = 0;
    });

    await connection!.close();
    show(cnt, 'Device disconnected');
    if (!connection!.isConnected) {
      setState(() {
        connected = false;
        isButtonUnavailable = false;
      });
    }
  }

  /*
  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned On');
    setState(() {
      deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
    setState(() {
      deviceState = -1; // device off
    });
  }
  */

  // Method to show a Snackbar,
  // taking message as the text
  Future show_old(
    BuildContext cnt,
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    print(">>>>>>>>>>>>> show snackbar");
    ScaffoldMessenger.of(cnt).showSnackBar(
      const SnackBar(
        content: Text("Type Your message here..."),
      ),
    );
  }

  show(BuildContext cnt, String message) {
    FlutterToastr.show(message, cnt,
        duration: FlutterToastr.lengthLong, position: FlutterToastr.bottom);
  }

  //block functions
  _updateStressLevel() {
    _stressLevelBlock.sendEvent
        .add(UpdateStressLevelGSR(gsrBuffer.currentStressLevel));
  }

  String _localFormalDateTime(DateTime dt) {
    String r = "";
    String m = dt.month.toString();
    String d = dt.day.toString();
    m = m.length <= 1 ? "0$m" : m;
    d = d.length <= 1 ? "0$d" : d;
    r = "${dt.year}-$m-$d ${dt.hour}:${dt.minute}";
    return r;
  }

  Future<void> saveUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('url', url);
  }

  Future<String> getUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('url') ?? '';
  }


}
