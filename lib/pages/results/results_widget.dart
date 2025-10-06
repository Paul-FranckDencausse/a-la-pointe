// lib/pages/results/results_widget.dart

import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'results_model.dart';
export 'results_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothClassicPage extends StatefulWidget {
  const BluetoothClassicPage({Key? key}) : super(key: key);

  @override
  State<BluetoothClassicPage> createState() => _BluetoothClassicPageState();
}

class _BluetoothClassicPageState extends State<BluetoothClassicPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice? _connectedDevice;
  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool get isConnected => _connection != null && _connection!.isConnected;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() => _bluetoothState = state);
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      setState(() => _bluetoothState = state);
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _isConnecting = true);
    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connectedDevice = device;
        _connection = connection;
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connecté à ${device.name ?? "Inconnu"}')),
      );

      connection.input?.listen((data) {
        debugPrint('Données reçues : ${String.fromCharCodes(data)}');
      }).onDone(() {
        setState(() {
          _connection = null;
          _connectedDevice = null;
        });
      });
    } catch (error) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $error')),
      );
    }
  }

  Future<void> _disconnect() async {
    await _connection?.close();
    setState(() {
      _connection = null;
      _connectedDevice = null;
    });
  }

  Future<void> _sendData(String message) async {
    if (isConnected) {
      _connection!.output.add(Uint8List.fromList(utf8.encode(message + "\r\n")));
      await _connection!.output.allSent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Classique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: _bluetoothState != BluetoothState.STATE_ON
          ? const Center(child: Text('Active le Bluetooth'))
          : FutureBuilder<List<BluetoothDevice>>(
        future: FlutterBluetoothSerial.instance.getBondedDevices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final devices = snapshot.data!;
          return ListView(
            children: devices.map((d) {
              return ListTile(
                title: Text(d.name ?? "Inconnu"),
                subtitle: Text(d.address),
                trailing: ElevatedButton(
                  onPressed: isConnected ? null : () => _connectToDevice(d),
                  child: const Text("Connecter"),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: isConnected
          ? FloatingActionButton.extended(
        onPressed: () => _sendData("PING"),
        label: const Text("Envoyer"),
        icon: const Icon(Icons.send),
      )
          : null,
    );
  }
}
