import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  static String routeName = 'BluetoothPage';
  static String routePath = '/bluetooth';

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _bluetoothOn = false;
  bool _isScanning = false;
  bool _isConnecting = false;

  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  String? _connectedDeviceRemoteId;

  BluetoothCharacteristic? _txCharacteristic; // Pour écrire
  BluetoothCharacteristic? _rxCharacteristic; // Pour lire (optionnel)

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    // Surveille l’état du Bluetooth
    _adapterStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
          if (!mounted) return;
          setState(() {
            _bluetoothOn = state == BluetoothAdapterState.on;
          });
          if (_bluetoothOn) {
            _startScan();
          } else {
            _clearDevices();
            _showSnackbar('Bluetooth désactivé');
          }
        });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    if (_isScanning) {
      FlutterBluePlus.stopScan();
    }
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? Colors.redAccent : null,
      ),
    );
  }

  void _clearDevices() {
    setState(() {
      _scanResults = [];
      _connectedDevice = null;
      _connectedDeviceRemoteId = null;
      _isConnecting = false;
      _txCharacteristic = null;
      _rxCharacteristic = null;
    });
  }

  // Demande les permissions
  Future<bool> _checkAndRequestPermissions() async {
    List<Permission> permissionsToRequest = [];

    if (await Permission.bluetoothScan.isDenied) {
      permissionsToRequest.add(Permission.bluetoothScan);
    }
    if (await Permission.bluetoothConnect.isDenied) {
      permissionsToRequest.add(Permission.bluetoothConnect);
    }
    if (await Permission.locationWhenInUse.isDenied) {
      permissionsToRequest.add(Permission.locationWhenInUse);
    }

    if (permissionsToRequest.isNotEmpty) {
      Map<Permission, PermissionStatus> statuses =
      await permissionsToRequest.request();
      bool allGranted = statuses.values.every((status) => status.isGranted);
      return allGranted;
    }
    return true;
  }

  Future<void> _startScan() async {
    if (!_bluetoothOn) {
      _showSnackbar('Veuillez activer le Bluetooth.', isError: true);
      return;
    }
    if (_isScanning) return;

    bool permissionsGranted = await _checkAndRequestPermissions();
    if (!permissionsGranted) {
      _showSnackbar("Permissions Bluetooth manquantes.", isError: true);
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        _scanResults = results;
      });
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
    } catch (e) {
      _showSnackbar('Erreur scan: $e', isError: true);
    }

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;
    if (_connectedDevice?.remoteId == device.remoteId) return;

    setState(() => _isConnecting = true);

    try {
      await device.connect(timeout: const Duration(seconds: 15));
    } catch (e) {
      _showSnackbar("Erreur de connexion: $e", isError: true);
      setState(() => _isConnecting = false);
      return;
    }

    _connectionStateSubscription?.cancel();
    _connectionStateSubscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
          if (!mounted) return;
          if (state == BluetoothConnectionState.connected) {
            setState(() {
              _connectedDevice = device;
              _connectedDeviceRemoteId = device.remoteId.str;
              _isConnecting = false;
            });
            _showSnackbar("Connecté à ${device.platformName}");

            // Découverte des services
            List<BluetoothService> services =
            await _connectedDevice!.discoverServices();
            for (var service in services) {
              for (var c in service.characteristics) {
                if (c.properties.write) {
                  _txCharacteristic = c;
                }
                if (c.properties.notify) {
                  _rxCharacteristic = c;
                  await c.setNotifyValue(true);
                  c.lastValueStream.listen((value) {
                    _showSnackbar("📩 Reçu: ${String.fromCharCodes(value)}");
                  });
                }
              }
            }
          } else if (state == BluetoothConnectionState.disconnected) {
            _showSnackbar("Déconnecté");
            setState(() {
              _connectedDevice = null;
              _connectedDeviceRemoteId = null;
              _txCharacteristic = null;
              _rxCharacteristic = null;
            });
          }
        });
  }

  Future<void> _disconnectFromDevice() async {
    if (_connectedDevice == null) return;
    try {
      await _connectedDevice!.disconnect();
    } catch (e) {
      _showSnackbar("Erreur de déconnexion: $e", isError: true);
    }
  }

  Future<void> _sendCommand(String cmd) async {
    if (_txCharacteristic == null) {
      _showSnackbar("Pas de characteristic WRITE", isError: true);
      return;
    }
    try {
      await _txCharacteristic!.write(cmd.codeUnits, withoutResponse: true);
      _showSnackbar("📡 Envoyé: $cmd");
    } catch (e) {
      _showSnackbar("Erreur envoi: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Bluetooth"),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? () => FlutterBluePlus.stopScan() : _startScan,
          )
        ],
      ),
      body: Column(
        children: [
          if (_connectedDevice != null)
            Card(
              child: ListTile(
                title: Text("Connecté à ${_connectedDevice!.platformName}"),
                subtitle: Text("ID: $_connectedDeviceRemoteId"),
                trailing: ElevatedButton(
                  onPressed: _disconnectFromDevice,
                  child: const Text("Déconnecter"),
                ),
              ),
            ),
          if (_isConnecting) const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              children: _scanResults
                  .map((r) => ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(r.device.platformName.isNotEmpty
                    ? r.device.platformName
                    : "Appareil inconnu"),
                subtitle: Text(r.device.remoteId.str),
                trailing: ElevatedButton(
                  onPressed: () => _connectToDevice(r.device),
                  child: const Text("Connecter"),
                ),
              ))
                  .toList(),
            ),
          ),
          if (_connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => _sendCommand("BUZZER_ON"),
                      child: const Text("BUZZER ON")),
                  ElevatedButton(
                      onPressed: () => _sendCommand("BUZZER_OFF"),
                      child: const Text("BUZZER OFF")),
                ],
              ),
            )
        ],
      ),
    );
  }
}
