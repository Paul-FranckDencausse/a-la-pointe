import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart'; // Pour ouvrir les paramètres si besoin
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart'; // <<< AJOUTEZ CET IMPORT

// Assurez-vous que ces imports sont corrects pour votre projet
import '/flutter_flow/flutter_flow_theme.dart';
import '/pages/results/results_widget.dart'; // Pour la navigation vers ResultsWidget
import '/flutter_flow/flutter_flow_util.dart'; // Pour context.pushNamed

class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  static String routeName = 'BluetoothPage'; // Ou gardez BluetoothWidget.routeName
  static String routePath = '/bluetooth';    // Ou gardez BluetoothWidget.routePath

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _bluetoothOn = false;
  bool _isScanning = false;
  bool _isConnecting = false;

  List<BluetoothDevice> _pairedDevices = [];
  List<ScanResult> _scanResults = []; // Stocker les ScanResult pour avoir accès au RSSI, etc.
  BluetoothDevice? _connectedDevice;
  String? _connectedDeviceRemoteId; // Pour stocker l'ID de l'appareil connecté

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  // Caractéristiques (exemple pour lecture/écriture si nécessaire)
  // BluetoothCharacteristic? _targetCharacteristic;

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
    // Assurez-vous d'arrêter le scan si la page est quittée pendant le scan
    if (_isScanning) {
      FlutterBluePlus.stopScan();
    }
    // Si un appareil est connecté, vous pourriez vouloir le déconnecter
    // _connectedDevice?.disconnect(); // Dépend de votre logique d'application
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
      _startScan(); // Commencer le scan si les permissions sont OK
    } else {
      _showSnackbar("Permissions nécessaires non accordées.", isError: true);
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    List<Permission> permissionsToRequest = [];
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Android 12+
      if (await Permission.bluetoothScan.isDenied || await Permission.bluetoothScan.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.bluetoothScan);
      }
      if (await Permission.bluetoothConnect.isDenied || await Permission.bluetoothConnect.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.bluetoothConnect);
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      if (await Permission.bluetooth.isDenied || await Permission.bluetooth.isPermanentlyDenied) {
        permissionsToRequest.add(Permission.bluetooth);
      }
    }
    // Location is often needed for scanning
    if (await Permission.locationWhenInUse.isDenied || await Permission.locationWhenInUse.isPermanentlyDenied) {
      permissionsToRequest.add(Permission.locationWhenInUse);
    }

    if (permissionsToRequest.isNotEmpty) {
      Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();
      // Vérifier si toutes les permissions demandées sont maintenant accordées
      bool allGranted = statuses.values.every((status) => status.isGranted);
      if (!allGranted) {
        if (statuses.values.any((status) => status.isPermanentlyDenied)) {
          _showSnackbar("Certaines permissions ont été refusées définitivement. Veuillez les activer dans les paramètres de l'application.", isError: true);
          // Optionnel : ouvrir les paramètres de l'application
          // AppSettings.openAppSettings();
        }
        return false;
      }
    }
    return true; // Toutes les permissions nécessaires sont (ou étaient déjà) accordées
  }


  Future<void> _loadBondedDevices() async {
    if (!_bluetoothOn) return;
    try {
      List<BluetoothDevice> devices = await FlutterBluePlus.bondedDevices;
      if (!mounted) return;
      setState(() {
        _pairedDevices = devices;
      });
    } catch (e) {
      _showSnackbar('Erreur de chargement des appareils appairés: $e', isError: true);
      debugPrint("_loadBondedDevices error: $e");
    }
  }

  Future<void> _startScan() async {
    if (!_bluetoothOn) {
      _showSnackbar('Veuillez activer le Bluetooth.', isError: true);
      return;
    }
    if (_isScanning) return;

    // Vérifier à nouveau les permissions avant chaque scan peut être une bonne pratique
    bool permissionsGranted = await _checkAndRequestPermissions();
    if (!permissionsGranted) {
      _showSnackbar("Impossible de scanner sans les permissions requises.", isError: true);
      return;
    }

    // Vérifier si les services de localisation sont activés
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && Theme.of(context).platform == TargetPlatform.android) { // Surtout pertinent pour Android
      _showSnackbar('Veuillez activer les services de localisation pour le scan Bluetooth.', isError: true);
      // Optionnel: Inviter l'utilisateur à ouvrir les paramètres de localisation
      // await Geolocator.openLocationSettings();
      // return; // On pourrait retourner ici, ou laisser le scan tenter quand même
    }


    setState(() {
      _isScanning = true;
      _scanResults = []; // Vider les résultats précédents
    });

    try {
      // S'abonner aux résultats de scan
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        List<ScanResult> newResults = [];
        for (ScanResult r in results) {
          // Filtrer les appareils sans nom ou déjà listés/connectés
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
            // Trier par nom ou RSSI si souhaité
            _scanResults.sort((a, b) => b.rssi.compareTo(a.rssi)); // Plus fort signal en premier
          });
        }
      }, onError: (e) {
        _showSnackbar('Erreur de scan: $e', isError: true);
        debugPrint("_startScan listen error: $e");
        if (mounted) setState(() => _isScanning = false);
      });

      // Démarrer le scan
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      // Après le timeout, isScanning sera mis à false automatiquement par le plugin,
      // mais on peut le faire explicitement si on arrête le scan manuellement.
    } catch (e) {
      _showSnackbar('Erreur lors du démarrage du scan: $e', isError: true);
      debugPrint("_startScan error: $e");
      if (mounted) setState(() => _isScanning = false);
    } finally {
      // Le plugin gère l'arrêt du scan après le timeout.
      // Si on voulait un bouton pour arrêter manuellement :
      // if (mounted) setState(() => _isScanning = false);
      // FlutterBluePlus.stopScan();
    }
    // Mettre à jour l'état du scan après le timeout ou l'arrêt
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isScanning) { // Vérifier si le scan était toujours en cours
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_connectedDevice != null && _connectedDevice!.remoteId == device.remoteId) {
      _showSnackbar('Déjà connecté à ${device.platformName}.');
      return;
    }
    if (_isConnecting) {
      _showSnackbar('Connexion en cours...');
      return;
    }

    // Arrêter le scan avant de se connecter
    if (_isScanning) {
      await FlutterBluePlus.stopScan();
      setState(() { _isScanning = false; });
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      await device.connect(timeout: const Duration(seconds: 15), autoConnect: false);
      // Le onConnectionStateChanged notifiera le succès ou l'échec
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erreur de connexion à ${device.platformName}: ${e.toString().split(':').last.trim()}', isError: true);
        debugPrint('_connectToDevice error: $e');
        setState(() {
          _isConnecting = false;
        });
      }
      return; // Sortir si l'appel initial à connect() échoue
    }

    // Si pas d'exception, on s'abonne à l'état de la connexion
    // L'état de connexion devrait se mettre à jour via le stream
    _connectionStateSubscription?.cancel(); // Annuler l'ancien abonnement s'il existe
    _connectionStateSubscription = device.connectionState.listen(
            (BluetoothConnectionState state) async {
          if (!mounted) return;
          if (state == BluetoothConnectionState.connected) {
            _showSnackbar('Connecté à ${device.platformName}!');
            setState(() {
              _connectedDevice = device;
              _connectedDeviceRemoteId = device.remoteId.str; // <<< RÉCUPÉRATION DE L'ID ICI
              _isConnecting = false;
              // Retirer l'appareil des listes de scan/appairés s'il y était
              _scanResults.removeWhere((sr) => sr.device.remoteId == device.remoteId);
              _pairedDevices.removeWhere((pd) => pd.remoteId == device.remoteId);
            });
            debugPrint('CONNECTÉ à: ${device.platformName}, ID: $_connectedDeviceRemoteId');

            // Optionnel: Découvrir les services après la connexion
            // await _discoverServicesAndSubscribe(device);

            // Exemple: Naviguer vers ResultsWidget avec l'ID de l'appareil
            // context.pushNamed(
            //   ResultsWidget.routeName,
            //   queryParameters: {'deviceId': _connectedDeviceRemoteId!},
            // );

          } else if (state == BluetoothConnectionState.disconnected) {
            _showSnackbar('${_connectedDevice?.platformName ?? 'L\'appareil'} déconnecté.', isError: true);
            setState(() {
              if (_connectedDevice?.remoteId == device.remoteId) { // Seulement si c'est l'appareil actuellement connecté
                _connectedDevice = null;
                _connectedDeviceRemoteId = null;
              }
              _isConnecting = false;
            });
            // Optionnel: Essayer de se reconnecter ou de recharger les appareils
            _loadBondedDevices();
            _startScan();
          }
        },
        onError: (dynamic error) {
          if (mounted) {
            _showSnackbar('Erreur de stream de connexion: $error', isError: true);
            debugPrint('Connection state stream error: $error');
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
    if (_connectedDevice == null) {
      _showSnackbar('Aucun appareil connecté.');
      return;
    }
    try {
      await _connectedDevice!.disconnect();
      // L'état de déconnexion sera géré par le stream _connectionStateSubscription
      _showSnackbar('Déconnexion de ${_connectedDevice!.platformName} demandée.');
    } catch (e) {
      _showSnackbar('Erreur de déconnexion: $e', isError: true);
      debugPrint("_disconnectFromDevice error: $e");
    }
  }

  // --- Widgets de construction de l'UI ---

  Widget _buildDeviceListTile(BluetoothDevice device, {bool isPaired = false}) {
    return ListTile(
      leading: Icon(Icons.bluetooth, color: FlutterFlowTheme.of(context).primary),
      title: Text(device.platformName.isNotEmpty ? device.platformName : 'Appareil inconnu'),
      subtitle: Text(device.remoteId.str), // Affiche l'ID de l'appareil
      trailing: ElevatedButton(
        onPressed: (_isConnecting || _connectedDevice?.remoteId == device.remoteId)
            ? null // Désactiver si connexion en cours ou déjà connecté à cet appareil
            : () => _connectToDevice(device),
        style: ElevatedButton.styleFrom(
            backgroundColor: FlutterFlowTheme.of(context).secondary,
            foregroundColor: Colors.white
        ),
        child: const Text('Connecter'),
      ),
      onTap: (_isConnecting || _connectedDevice?.remoteId == device.remoteId)
          ? null
          : () => _connectToDevice(device),
    );
  }

  Widget _buildScanResultTile(ScanResult result) {
    return ListTile(
      leading: Icon(Icons.bluetooth_searching, color: FlutterFlowTheme.of(context).primary),
      title: Text(result.device.platformName.isNotEmpty ? result.device.platformName : 'Appareil inconnu'),
      subtitle: Text(result.device.remoteId.str),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${result.rssi} dBm'), // Affiche la force du signal
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: (_isConnecting || _connectedDevice?.remoteId == result.device.remoteId)
                ? null
                : () => _connectToDevice(result.device),
            style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).secondary,
                foregroundColor: Colors.white
            ),
            child: const Text('Connecter'),
          ),
        ],
      ),
      onTap: (_isConnecting || _connectedDevice?.remoteId == result.device.remoteId)
          ? null
          : () => _connectToDevice(result.device),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context); // Utiliser le thème FlutterFlow

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          'Gestion Bluetooth',
          style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            color: theme.primaryText, // Ou une couleur contrastante comme Colors.white
            useGoogleFonts: GoogleFonts.asMap().containsKey(theme.headlineMediumFamily),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop_circle_outlined : Icons.refresh, color: theme.primaryText),
            onPressed: _isScanning
                ? () async {
              await FlutterBluePlus.stopScan();
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
          if (_connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.bluetooth_connected, color: Colors.green, size: 30),
                  title: Text(
                    _connectedDevice!.platformName.isNotEmpty ? _connectedDevice!.platformName : 'Appareil Connecté',
                    style: theme.titleMedium,
                  ),
                  subtitle: Text(
                    "ID: $_connectedDeviceRemoteId\nAppuyez pour déconnecter ou aller aux résultats", // AFFICHE L'ID RÉCUPÉRÉ
                    style: theme.bodySmall,
                  ),
                  trailing: Icon(Icons.chevron_right, color: theme.secondaryText),
                  onTap: () {
                    // Action au clic sur l'appareil connecté
                    // Par exemple, naviguer vers la page de résultats avec l'ID
                    if (_connectedDeviceRemoteId != null) {
                      context.pushNamed(
                        ResultsWidget.routeName,
                        queryParameters: {'deviceId': _connectedDeviceRemoteId!},
                      );
                    }
                  },
                  onLongPress: _disconnectFromDevice, // Déconnexion sur appui long
                ),
              ),
            ),

          if (_isConnecting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text("Connexion en cours...", style: theme.bodyMedium),
                ],
              ),
            ),

          // Message si Bluetooth désactivé
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
                      Text(
                        'Bluetooth désactivé',
                        style: theme.headlineSmall.override(
                          fontFamily: theme.headlineSmallFamily,
                          color: theme.secondaryText,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(theme.headlineSmallFamily),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Veuillez activer le Bluetooth pour continuer.',
                        style: theme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text("Ouvrir les Paramètres Bluetooth"),
                        onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: theme.primaryText
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

          // Listes des appareils (seulement si Bluetooth est activé)
          if (_bluetoothOn)
            Expanded(
              child: ListView(
                children: [
                  if (_pairedDevices.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
                      child: Text('Appareils Appairés', style: theme.titleSmall),
                    ),
                    ..._pairedDevices
                        .where((d) => _connectedDevice == null || d.remoteId != _connectedDevice!.remoteId) // Ne pas afficher si déjà connecté
                        .map((device) => _buildDeviceListTile(device, isPaired: true))
                        .toList(),
                    const Divider(),
                  ],
                  if (_scanResults.isNotEmpty || _isScanning) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
                      child: Text(_isScanning ? 'Scan en cours...' : 'Appareils Disponibles', style: theme.titleSmall),
                    ),
                    if (_scanResults.isEmpty && _isScanning)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Recherche d'appareils..."),
                      )),
                    ..._scanResults.map((result) => _buildScanResultTile(result)).toList(),
                  ],
                  if (_scanResults.isEmpty && _pairedDevices.isEmpty && !_isScanning && _connectedDevice == null)
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
    );
  }
}
