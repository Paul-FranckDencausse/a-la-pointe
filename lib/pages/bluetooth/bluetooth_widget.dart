import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart'; // Assurez-vous que ce package est dans pubspec.yaml

// Assurez-vous que ces imports sont corrects pour votre projet
import '/flutter_flow/flutter_flow_theme.dart';
import '/pages/results/results_widget.dart'; // Important pour ResultsWidget.routeName
import '/flutter_flow/flutter_flow_util.dart'; // Pour context.pushNamed et launchURL
import '/index.dart'; // Pour HomePageWidget si vous l'utilisez pour la navigation de l'appBar


class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  static String routeName = 'BluetoothPage';
  static String routePath = '/bluetooth';

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2; // Index par défaut pour "Bluetooth" dans la BottomNavBar

  bool _bluetoothOn = false;
  bool _isScanning = false;
  bool _isConnecting = false;

  List<BluetoothDevice> _pairedDevices = [];
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  String? _connectedDeviceRemoteId; // Stocke le remoteId de l'appareil connecté

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (!mounted) return;
      setState(() {
        _bluetoothOn = state == BluetoothAdapterState.on;
      });
      if (_bluetoothOn) {
        _requestPermissionsAndLoadDevices();
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
      _pairedDevices = [];
      _scanResults = [];
      _connectedDevice = null;
      _connectedDeviceRemoteId = null;
      _isConnecting = false;
    });
  }

  Future<void> _requestPermissionsAndLoadDevices() async {
    bool permissionsGranted = await _checkAndRequestPermissions();
    if (permissionsGranted) {
      _loadBondedDevices();
      _startScan();
    } else {
      _showSnackbar("Permissions Bluetooth/Localisation nécessaires non accordées.", isError: true);
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    List<Permission> permissionsToRequest = [];
    if (Theme.of(context).platform == TargetPlatform.android) {
      if (await Permission.bluetoothScan.isDenied || await Permission.bluetoothScan.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.bluetoothScan);
      }
      if (await Permission.bluetoothConnect.isDenied || await Permission.bluetoothConnect.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.bluetoothConnect);
      }
      // La localisation est souvent nécessaire pour le scan sur Android
      if (await Permission.locationWhenInUse.isDenied || await Permission.locationWhenInUse.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.locationWhenInUse);
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) { // Correction de la casse ici
      if (await Permission.bluetooth.isDenied || await Permission.bluetooth.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.bluetooth);
      }
      // Optionnel: demander la localisation sur iOS si votre usage BLE le justifie
      // if (await Permission.locationWhenInUse.isDenied || await Permission.locationWhenInUse.isPermanentlyDenied) {
      //   permissionsToRequest.add(Permission.locationWhenInUse);
      // }
    }


    if (permissionsToRequest.isNotEmpty) {
      Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();
      bool allGranted = statuses.values.every((status) => status.isGranted);
      if (!allGranted) {
        if (statuses.values.any((status) => status.isPermanentlyDenied)) {
          _showSnackbar("Certaines permissions ont été refusées définitivement. Veuillez les activer dans les paramètres de l'application.", isError: true);
          // AppSettings.openAppSettings();
        }
        return false;
      }
    }
    return true;
  }

  Future<void> _loadBondedDevices() async {
    if (!_bluetoothOn) return;
    try {
      _pairedDevices = await FlutterBluePlus.bondedDevices;
      if(mounted) setState(() {});
    } catch (e) {
      _showSnackbar('Erreur de chargement des appareils appairés: $e', isError: true);
    }
  }

  Future<void> _startScan() async {
    if (!_bluetoothOn) {
      _showSnackbar('Veuillez activer le Bluetooth.', isError: true);
      return;
    }
    if (_isScanning) return;

    bool permissionsGranted = await _checkAndRequestPermissions();
    if (!permissionsGranted) {
      _showSnackbar("Impossible de scanner sans les permissions requises.", isError: true);
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && Theme.of(context).platform == TargetPlatform.android) {
        _showSnackbar('Veuillez activer les services de localisation pour le scan Bluetooth.', isError: true);
        // await Geolocator.openLocationSettings(); // Optionnel
        // return; // Ou scanner quand même
      }
    } catch (e) {
      debugPrint("Erreur avec Geolocator: $e. Le package est-il bien installé et configuré?");
      _showSnackbar("Impossible de vérifier l'état de la localisation.", isError: true);
    }


    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      List<ScanResult> newResults = [];
      for (ScanResult r in results) {
        if (r.device.platformName.isNotEmpty &&
            !_scanResults.any((sr) => sr.device.remoteId == r.device.remoteId) &&
            !_pairedDevices.any((pd) => pd.remoteId == r.device.remoteId) &&
            (_connectedDevice == null || _connectedDevice!.remoteId != r.device.remoteId)) {
          newResults.add(r);
        }
      }
      if(newResults.isNotEmpty){
        setState(() {
          _scanResults.addAll(newResults);
          _scanResults.sort((a, b) => b.rssi.compareTo(a.rssi));
        });
      }
    }, onError: (e) {
      if(mounted) _showSnackbar('Erreur de scan: $e', isError: true);
      if (mounted) setState(() => _isScanning = false);
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      if(mounted) _showSnackbar('Erreur lors du démarrage du scan: $e', isError: true);
      if (mounted) setState(() => _isScanning = false);
    }
    // Le scan s'arrête après le timeout ou manuellement
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isScanning) {
        FlutterBluePlus.stopScan(); // Assurer l'arrêt
        setState(() { _isScanning = false; });
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice?.remoteId == device.remoteId) {
      _showSnackbar('Déjà connecté à ${device.platformName}.');
      return;
    }
    if (_isConnecting) return;

    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      if(mounted) setState(() { _isScanning = false; });
    }

    setState(() { _isConnecting = true; });

    try {
      await device.connect(timeout: const Duration(seconds: 15), autoConnect: false);
      // La gestion de la connexion se fait via le stream
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erreur de connexion: ${e.toString().split(':').last.trim()}', isError: true);
        setState(() { _isConnecting = false; });
      }
      return;
    }

    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen(
            (BluetoothConnectionState state) {
          if (!mounted) return;
          if (state == BluetoothConnectionState.connected) {
            setState(() {
              _connectedDevice = device;
              _connectedDeviceRemoteId = device.remoteId.str; // <<<< RÉCUPÉRATION DE L'ID
              _isConnecting = false;
              _scanResults.removeWhere((sr) => sr.device.remoteId == device.remoteId);
              _pairedDevices.removeWhere((pd) => pd.remoteId == device.remoteId);
            });
            _showSnackbar('Connecté à ${device.platformName}!');
            debugPrint('CONNECTÉ à: ${device.platformName}, ID: $_connectedDeviceRemoteId');

            // Vous pouvez naviguer ici ou laisser l'utilisateur le faire via l'UI
          } else if (state == BluetoothConnectionState.disconnected) {
            _showSnackbar('${_connectedDevice?.platformName ?? 'Appareil'} déconnecté.', isError: true);
            setState(() {
              if (_connectedDevice?.remoteId == device.remoteId) {
                _connectedDevice = null;
                _connectedDeviceRemoteId = null;
              }
              _isConnecting = false;
            });
            _loadBondedDevices(); // Recharger les appareils appairés
            // _startScan(); // Optionnel: relancer un scan
          }
        },
        onError: (dynamic error) {
          if (mounted) {
            _showSnackbar('Erreur de stream de connexion: $error', isError: true);
            setState(() {
              _isConnecting = false;
              if (_connectedDevice?.remoteId == device.remoteId) {
                _connectedDevice = null;
                _connectedDeviceRemoteId = null;
              }
            });
          }
        }
    );
  }

  Future<void> _disconnectFromDevice() async {
    if (_connectedDevice == null) return;
    try {
      await _connectedDevice!.disconnect();
      // Le stream gérera la mise à jour de l'état
    } catch (e) {
      _showSnackbar('Erreur de déconnexion: $e', isError: true);
    }
  }

  // --- Widgets de construction de l'UI ---
  Widget _buildDeviceListTile(BluetoothDevice device, {bool isPaired = false}) {
    // ... (code existant pour _buildDeviceListTile - peut afficher device.remoteId.str)
    return ListTile(
      leading: Icon(Icons.bluetooth, color: FlutterFlowTheme.of(context).primary),
      title: Text(device.platformName.isNotEmpty ? device.platformName : 'Appareil inconnu'),
      subtitle: Text(device.remoteId.str),
      trailing: ElevatedButton(
        onPressed: (_isConnecting || _connectedDevice?.remoteId == device.remoteId)
            ? null
            : () => _connectToDevice(device),
        style: ElevatedButton.styleFrom(
            backgroundColor: FlutterFlowTheme.of(context).secondary,
            foregroundColor: Colors.white // Texte du bouton en blanc
        ),
        child: const Text('Connecter'),
      ),
    );
  }

  Widget _buildScanResultTile(ScanResult result) {
    // ... (code existant pour _buildScanResultTile - peut afficher result.device.remoteId.str)
    return ListTile(
      leading: Icon(Icons.bluetooth_searching, color: FlutterFlowTheme.of(context).primary),
      title: Text(result.device.platformName.isNotEmpty ? result.device.platformName : 'Appareil inconnu'),
      subtitle: Text(result.device.remoteId.str),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${result.rssi} dBm'),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: (_isConnecting || _connectedDevice?.remoteId == result.device.remoteId)
                ? null
                : () => _connectToDevice(result.device),
            style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).secondary,
                foregroundColor: Colors.white // Texte du bouton en blanc
            ),
            child: const Text('Connecter'),
          ),
        ],
      ),
    );
  }

  // --- Bottom Navigation Bar Logic ---
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Ne rien faire si l'onglet actuel est sélectionné

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Training
        context.pushNamed(TrainingWidget.routeName);
        break;
      case 1: // Résultats
      // Si un appareil est connecté, passer son ID, sinon passer null ou ne pas le passer
        context.pushNamed(
          ResultsWidget.routeName,
          queryParameters: _connectedDeviceRemoteId != null
              ? {'deviceId': _connectedDeviceRemoteId!}
              : {}, // Passe un map vide si pas d'ID
        );
        break;
      case 2: // Bluetooth (Page actuelle)
      // context.pushNamed(BluetoothWidget.routeName); // Ne rien faire ou recharger si nécessaire
        break;
      case 3: // Boutique
        launchURL('https://www.a-la-pointe.fr/shop');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground, // Correspond au fond de la page d'accueil
        elevation: 2.0,
        automaticallyImplyLeading: false, // Pas de bouton retour par défaut
        centerTitle: true,
        title: InkWell(
          onTap: () async {
            context.pushNamed(HomePageWidget.routeName); // Naviguer vers HomePage
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/picto-alp-bleu_(1).png', // Assurez-vous que ce chemin est correct
              width: 70,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
                _isScanning ? Icons.stop_circle_outlined : Icons.refresh,
                color: theme.primaryText // Utilisez une couleur de texte visible
            ),
            onPressed: _isScanning
                ? () async {
              if (await FlutterBluePlus.isScanning.first == true) { // Vérifier avant d'arrêter
                await FlutterBluePlus.stopScan();
              }
              if(mounted) setState(() => _isScanning = false);
            }
                : _startScan,
            tooltip: _isScanning ? 'Arrêter le Scan' : 'Scanner les appareils',
          )
        ],
      ),
      body: Column(
        children: [
          // Section Appareil Connecté
          if (_connectedDevice != null && _connectedDeviceRemoteId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.bluetooth_connected, color: Colors.greenAccent[700], size: 30),
                  title: Text(
                    _connectedDevice!.platformName.isNotEmpty ? _connectedDevice!.platformName : 'Appareil Connecté',
                    style: theme.titleMedium.override(fontFamily: theme.titleMediumFamily),
                  ),
                  subtitle: Text(
                    "ID: $_connectedDeviceRemoteId\nAppuyez pour voir les résultats ou maintenez pour déconnecter.",
                    style: theme.bodySmall.override(fontFamily: theme.bodySmallFamily),
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
                  onTap: () {
                    // <<< NAVIGATION VERS RESULTSWIDGET AVEC L'ID >>>
                    context.pushNamed(
                      ResultsWidget.routeName,
                      queryParameters: {'deviceId': _connectedDeviceRemoteId!},
                    );
                  },
                  onLongPress: _disconnectFromDevice,
                ),
              ),
            ),

          if (_isConnecting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 10),
                Text("Connexion en cours...", style: theme.bodyMedium)
              ]),
            ),

          if (!_bluetoothOn)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_disabled, size: 80, color: theme.secondaryText),
                      const SizedBox(height: 20),
                      Text('Bluetooth désactivé', style: theme.headlineSmall),
                      const SizedBox(height: 10),
                      Text('Veuillez activer le Bluetooth.', style: theme.bodyMedium),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text("Ouvrir les Paramètres"),
                        onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth),
                        style: ElevatedButton.styleFrom(backgroundColor: theme.primary, foregroundColor: theme.primaryText),
                      )
                    ],
                  ),
                ),
              ),
            ),

          if (_bluetoothOn)
            Expanded(
              child: ListView(
                children: [
                  if (_pairedDevices.isNotEmpty && _connectedDevice == null) ...[ // Afficher seulement si non connecté
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text('Appareils Appairés', style: theme.titleSmall),
                    ),
                    ..._pairedDevices
                        .where((d) => _connectedDevice?.remoteId != d.remoteId)
                        .map((device) => _buildDeviceListTile(device, isPaired: true))
                        .toList(),
                    const Divider(indent: 16, endIndent: 16),
                  ],
                  if (_scanResults.isNotEmpty || _isScanning) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: Text(_isScanning ? 'Scan en cours...' : 'Appareils Disponibles', style: theme.titleSmall),
                    ),
                    if (_scanResults.isEmpty && _isScanning)
                      const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Recherche d'appareils..."))),
                    ..._scanResults.map((result) => _buildScanResultTile(result)).toList(),
                  ],
                  if (_scanResults.isEmpty && _pairedDevices.where((d) => _connectedDevice?.remoteId != d.remoteId).isEmpty && !_isScanning && _connectedDevice == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Aucun appareil trouvé.\nAppuyez sur l\'icône Rafraîchir pour scanner.',
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: theme.secondary,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Training'), // fitness_center ou sports_gymnastics
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Résultats'), // bar_chart ou data_thresholding_sharp
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth_sharp), label: 'Bluetooth'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Boutique'), // shopping_cart_outlined ou shopping_cart
        ],
      ),
    );
  }
}

