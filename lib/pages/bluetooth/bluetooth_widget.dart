import 'dart:async';
import 'dart:typed_data'; // Pour ByteData
import 'dart:convert';   // Pour utf8 (si vous décodez des chaînes)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app_settings/app_settings.dart';

// Supposons que ErreurWidget est dans un fichier séparé ou défini ici
// Pour la simplicité, je vais mettre une version basique de ErreurWidget ici.
// Idéalement, utilisez votre version améliorée dans erreur_widget.dart

// --- Début de ErreurWidget (version simplifiée pour l'exemple) ---
class ErrorAction {
  final String label;
  final VoidCallback onPressed;
  ErrorAction({required this.label, required this.onPressed});
}

class ErreurWidget extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final List<ErrorAction>? actions;

  const ErreurWidget({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.error_outline, color: Colors.red, size: 60),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(title!, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (actions != null) ...[
              const SizedBox(height: 24),
              ...actions!.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(onPressed: action.onPressed, child: Text(action.label)),
              )).toList(),
            ]
          ],
        ),
      ),
    );
  }
}
// --- Fin de ErreurWidget ---


// ----- VOS UUIDs -----
// REMPLACEZ-LES PAR LES UUIDs DE VOTRE ESP32
// Exemple pour un service de capteurs environnementaux et une caractéristique de données
final Guid YOUR_SERVICE_UUID = Guid("0000181A-0000-1000-8000-00805f9b34fb"); // Exemple : Environmental Sensing
final Guid YOUR_SENSOR_CHARACTERISTIC_UUID = Guid("00002A6E-0000-1000-8000-00805f9b34fb"); // Exemple : Temperature

class BluetoothWidget extends StatefulWidget {
  const BluetoothWidget({super.key});

  static String routeName = 'Bluetooth';
  static String routePath = '/bluetooth';

  @override
  State<BluetoothWidget> createState() => _BluetoothWidgetState();
}

class _BluetoothWidgetState extends State<BluetoothWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _bluetoothOn = false;
  List<BluetoothDevice> _pairedDevices = [];
  List<BluetoothDevice> _availableDevices = [];
  bool _isScanning = false;

  BluetoothDevice? _connectedDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _sensorDataSubscription;
  Map<String, String> _sensorValues = {}; // Pour stocker les valeurs des capteurs (ex: "temp": "25.5°C")

  bool _isConnecting = false;
  bool _userDisconnectedManually = false;
  bool _showConnectionErrorView = false; // Pour gérer l'affichage de l'erreur

  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  // Références au thème FlutterFlow (adaptez si vous n'utilisez pas FlutterFlow directement pour le thème)
  // Vous devrez peut-être passer FlutterFlowTheme.of(context) directement dans build
  // ou initialiser une variable de thème dans la méthode build.
  // Pour cet exemple, je vais supposer que vous pouvez y accéder ou utiliser les thèmes Flutter standard.

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      final bool newBluetoothState = (state == BluetoothAdapterState.on);
      if (_bluetoothOn != newBluetoothState) { // Si l'état a réellement changé
        setState(() {
          _bluetoothOn = newBluetoothState;
          _showConnectionErrorView = false; // Réinitialiser l'erreur si le BT change d'état
          if (!_bluetoothOn) {
            _clearDeviceListsAndConnection();
          }
        });
      }
      if (_bluetoothOn) {
        _loadBondedDevices();
        _scanForDevices(); // Scanner automatiquement si le BT est activé
      }
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _sensorDataSubscription?.cancel();
    // Envisagez de vous déconnecter de l'appareil si l'utilisateur quitte l'écran
    // if (_connectedDevice != null && _connectedDevice!.isConnected) { // Vérifiez isConnected
    //   _disconnectFromDevice(isDisposing: true);
    // }
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _clearDeviceListsAndConnection() {
    _pairedDevices.clear();
    _availableDevices.clear();
    _connectedDevice = null;
    _sensorValues.clear();
    _isConnecting = false;
    _userDisconnectedManually = false;
    _connectionStateSubscription?.cancel();
    _sensorDataSubscription?.cancel();
  }

  Future<void> _checkBluetoothState() async {
    if (!mounted) return;
    final initialState = await FlutterBluePlus.adapterState.first;
    setState(() {
      _bluetoothOn = (initialState == BluetoothAdapterState.on);
    });
    if (_bluetoothOn) {
      _loadBondedDevices();
      _scanForDevices();
    }
  }

  Future<void> _loadBondedDevices() async {
    if (!_bluetoothOn || !mounted) return;
    try {
      final bonded = await FlutterBluePlus.bondedDevices;
      if (!mounted) return;
      setState(() {
        _pairedDevices = bonded;
      });
    } catch (e) {
      debugPrint("Erreur chargement appareils associés: $e");
      _showSnackbar('Erreur chargement appareils associés: $e');
    }
  }

  void _scanForDevices() {
    if (!_bluetoothOn || !mounted || _isScanning) return;

    setState(() {
      _isScanning = true;
      _availableDevices.clear();
      _showConnectionErrorView = false; // Réinitialiser l'erreur avant de scanner
    });

    try {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 10)); // Augmenté le timeout

      FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        final newDevices = <BluetoothDevice>[];
        for (ScanResult r in results) {
          if (r.device.platformName.isNotEmpty &&
              !_availableDevices.any((dev) => dev.remoteId == r.device.remoteId) &&
              !_pairedDevices.any((dev) => dev.remoteId == r.device.remoteId)) {
            newDevices.add(r.device);
          }
        }
        if (newDevices.isNotEmpty && mounted) {
          setState(() {
            _availableDevices.addAll(newDevices);
            _availableDevices.sort((a, b) => a.platformName.compareTo(b.platformName));
          });
        }
      }, onError: (e) {
        debugPrint("Erreur pendant le scan: $e");
        _showSnackbar('Erreur de scan: $e');
        if (mounted) setState(() => _isScanning = false);
      });

      // Arrêter le scan après le timeout
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isScanning) {
          FlutterBluePlus.stopScan();
          setState(() => _isScanning = false);
        }
      });

    } catch (e) {
      debugPrint("Erreur au démarrage du scan: $e");
      _showSnackbar('Impossible de démarrer le scan: $e');
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (!mounted || _isConnecting) return;

    setState(() {
      _isConnecting = true;
      _userDisconnectedManually = false;
      _showConnectionErrorView = false;
      _sensorValues.clear();
    });

    await FlutterBluePlus.stopScan(); // Arrêter le scan
    if (mounted) setState(() => _isScanning = false);


    try {
      await _connectionStateSubscription?.cancel(); // Annuler souscription précédente
      _connectionStateSubscription = device.connectionState.listen((state) async {
        if (!mounted) return;
        debugPrint("État connexion pour ${device.remoteId}: $state");

        if (state == BluetoothConnectionState.connected) {
          if (mounted) {
            setState(() {
              _connectedDevice = device;
              _isConnecting = false;
              _showConnectionErrorView = false;
            });
            _showSnackbar('Connecté à ${device.platformName.isNotEmpty ? device.platformName : device.remoteId.str}');
            await _discoverServicesAndSubscribe(device);
            // Pour le débogage, vous pouvez lister tous les UUIDs:
            // await listAllUuids(device);
          }
        } else if (state == BluetoothConnectionState.disconnected) {
          _showSnackbar('Déconnecté de ${device.platformName.isNotEmpty ? device.platformName : device.remoteId.str}');
          if (mounted) {
            setState(() {
              if (!_userDisconnectedManually) {
                _showConnectionErrorView = true; // Afficher l'erreur si déconnexion inattendue
              }
              _connectedDevice = null;
              _isConnecting = false;
              _sensorValues.clear();
              _sensorDataSubscription?.cancel();
              _sensorDataSubscription = null;
            });
          }
        }
      });

      await device.connect(timeout: const Duration(seconds: 15), autoConnect: false);
      // La logique de connexion réussie est maintenant gérée par le listener sur connectionState.

    } catch (e) {
      debugPrint("Erreur connexion à ${device.remoteId.str}: $e");
      final String errorMessage = e.toString();
      String displayMessage = 'Erreur de connexion: $e';
      if (errorMessage.contains("already connected")) {
        displayMessage = "Appareil déjà connecté ou connexion en cours.";
        // Si déjà connecté, on peut essayer de forcer la découverte des services
        if (device.isConnected && mounted) {
          setState(() {
            _connectedDevice = device; // Assumer connecté
            _isConnecting = false;
            _showConnectionErrorView = false;
          });
          await _discoverServicesAndSubscribe(device);
        }

      } else if (errorMessage.contains("failed to connect") || errorMessage.contains("GATT erreur")) {
        displayMessage = "Impossible de se connecter à l'appareil. Vérifiez qu'il est allumé et à portée.";
      }

      _showSnackbar(displayMessage);
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectedDevice = null;
          _showConnectionErrorView = true;
        });
      }
    }
  }

  Future<void> _disconnectFromDevice({bool isDisposing = false}) async {
    if (_connectedDevice == null || (!mounted && !isDisposing)) return;

    // Se désabonner des notifications de la caractéristique
    await _sensorDataSubscription?.cancel();
    _sensorDataSubscription = null;

    // Optionnel: explicitement désactiver les notifications sur l'appareil
    if (_connectedDevice!.isConnected) { // Vérifier isConnected
      try {
        final services = await _connectedDevice!.servicesStream.first;
        for (BluetoothService service in services) {
          if (service.uuid == YOUR_SERVICE_UUID) {
            for (BluetoothCharacteristic characteristic in service.characteristics) {
              if (characteristic.uuid == YOUR_SENSOR_CHARACTERISTIC_UUID &&
                  (characteristic.properties.notify || characteristic.properties.indicate)) {
                if (characteristic.isNotifying) {
                  await characteristic.setNotifyValue(false);
                  debugPrint("Désabonné des notifications pour ${characteristic.uuid}");
                }
                break;
              }
            }
            break;
          }
        }
      } catch(e) {
        debugPrint("Erreur lors de la désactivation des notifications: $e");
      }
    }


    if (!isDisposing && mounted) { // Ne pas appeler setState si on dispose
      setState(() {
        _userDisconnectedManually = true;
        _sensorValues.clear();
      });
    } else if (isDisposing) { // Si on dispose, juste effacer les valeurs
      _userDisconnectedManually = true;
      _sensorValues.clear();
    }


    try {
      if (_connectedDevice!.isConnected) { // Vérifier isConnected
        await _connectedDevice!.disconnect();
      }
      // La mise à jour de _connectedDevice à null est gérée par le listener sur connectionState
      if (!isDisposing && mounted) {
        _showSnackbar('Déconnexion réussie.');
      }
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion: $e");
      if (!isDisposing && mounted) {
        _showSnackbar('Erreur lors de la déconnexion: $e');
        setState(() {
          _userDisconnectedManually = false; // Réinitialiser si la déconnexion échoue
        });
      }
    }
  }


  Future<void> _discoverServicesAndSubscribe(BluetoothDevice device) async {
    if (!mounted || !device.isConnected) return; // S'assurer que l'appareil est connecté

    List<BluetoothService> services;
    try {
      services = await device.discoverServices();
    } catch (e) {
      debugPrint("Erreur découverte services pour ${device.remoteId}: $e");
      _showSnackbar('Erreur découverte services: $e');
      if (mounted) {
        setState(() {
          _showConnectionErrorView = true; // Afficher erreur si découverte échoue
          _connectedDevice = null; // Considérer comme déconnecté
        });
      }
      return;
    }

    bool characteristicFound = false;
    for (BluetoothService service in services) {
      if (service.uuid == YOUR_SERVICE_UUID) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid == YOUR_SENSOR_CHARACTERISTIC_UUID) {
            characteristicFound = true;
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              try {
                if (!characteristic.isNotifying) { // S'abonner seulement si pas déjà abonné
                  await characteristic.setNotifyValue(true);
                }
                debugPrint("Abonné aux notifications pour ${characteristic.uuid}");

                await _sensorDataSubscription?.cancel(); // Annuler toute souscription précédente
                _sensorDataSubscription = characteristic.lastValueStream.listen((value) {
                  _processSensorData(value);
                }, onError: (error) {
                  debugPrint("Erreur réception données capteur: $error");
                  _showSnackbar('Erreur réception données: $error');
                });
              } catch (e) {
                debugPrint("Erreur abonnement/lecture caractéristique ${characteristic.uuid}: $e");
                _showSnackbar('Erreur abonnement capteur: $e');
                if(mounted) setState(() => _showConnectionErrorView = true);
              }
            } else {
              debugPrint("Caractéristique ${characteristic.uuid} ne supporte pas notify/indicate. Essayez une lecture unique.");
              try {
                List<int> value = await characteristic.read();
                _processSensorData(value);
              } catch (e) {
                debugPrint("Erreur lecture caractéristique ${characteristic.uuid}: $e");
                _showSnackbar('Erreur lecture capteur: $e');
              }
            }
            return; // Sortir après avoir trouvé et traité la caractéristique
          }
        }
      }
    }
    if (!characteristicFound && mounted) {
      debugPrint("Service ou caractéristique capteur non trouvé pour ${device.remoteId}");
      _showSnackbar('Capteur non compatible ou non trouvé sur cet appareil.');
      setState(() => _showConnectionErrorView = true); // Afficher une erreur si le capteur n'est pas trouvé
    }
  }

  void _processSensorData(List<int> data) {
    if (!mounted || data.isEmpty) {
      debugPrint("Données capteur vides ou widget non monté.");
      return;
    }

    ByteData byteData = ByteData.sublistView(Uint8List.fromList(data));
    Map<String, String> newValues = {};

    // ----- PERSONNALISEZ CE BLOC DE DÉCODAGE -----
    // Exemple: supposons que l'ESP32 envoie 2 floats (température, humidité)
    // et un entier pour un switch (9 octets au total)
    try {
      if (data.length >= 4) { // Température (float, 4 octets)
        double temperature = byteData.getFloat32(0, Endian.little);
        newValues["Température"] = "${temperature.toStringAsFixed(1)} °C";
      }
      if (data.length >= 8) { // Humidité (float, 4 octets, après la température)
        double humidity = byteData.getFloat32(4, Endian.little);
        newValues["Humidité"] = "${humidity.toStringAsFixed(1)} %";
      }
      if (data.length >= 9) { // État interrupteur (1 octet, après l'humidité)
        int switchState = byteData.getUint8(8);
        newValues["Interrupteur"] = switchState == 1 ? "ON" : "OFF";
      }
      // Ajoutez d'autres décodages ici si nécessaire
    } catch (e) {
      debugPrint("Erreur décodage données capteur: $e. Données brutes: $data");
      _showSnackbar("Erreur format données capteur.");
      return;
    }
    // ----- FIN DU BLOC DE DÉCODAGE -----

    if (mounted && newValues.isNotEmpty) {
      setState(() {
        _sensorValues = newValues; // Remplacer par les nouvelles valeurs
      });
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }


  Future<void> listAllUuids(BluetoothDevice device) async {
    // ... (Code de listAllUuids fourni dans la réponse précédente) ...
    // Je le laisse en commentaire pour ne pas surcharger, mais vous pouvez le décommenter et l'appeler.
    print("----- Début liste UUIDs pour ${device.remoteId} -----");
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        print("\n[SERVICE] UUID: ${service.uuid.toString().toUpperCase()}");
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print("  [CARACTÉRISTIQUE] UUID: ${characteristic.uuid.toString().toUpperCase()}");
          print("    Properties: Notify: ${characteristic.properties.notify}, Read: ${characteristic.properties.read}, Write: ${characteristic.properties.write}");
          for (BluetoothDescriptor descriptor in characteristic.descriptors) {
            print("    [DESCRIPTEUR] UUID: ${descriptor.uuid.toString().toUpperCase()}");
          }
        }
      }
    } catch (e) {
      print("Erreur listAllUuids: $e");
    }
    print("----- Fin liste UUIDs -----");
  }


  @override
  Widget build(BuildContext context) {
    // Thème (Adaptez si vous n'utilisez pas FlutterFlow directement)
    // final theme = FlutterFlowTheme.of(context); // Exemple
    final theme = Theme.of(context); // Thème Flutter standard

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.colorScheme.background, // theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background, // theme.primaryBackground,
        title: Text(
          "Bluetooth",
          style: theme.textTheme.headlineMedium?.copyWith(fontFamily: GoogleFonts.interTight().fontFamily),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBluetoothControl(theme),
            if (!_bluetoothOn)
              Expanded(child: _buildBluetoothDisabledView(theme))
            else if (_connectedDevice != null && !_showConnectionErrorView)
              Expanded(child: _buildConnectedDeviceView(theme))
            else if (_showConnectionErrorView)
                Expanded(child: _buildErrorView())
              else
                Expanded(child: _buildDeviceSelectionView(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBluetoothControl(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Bluetooth", style: theme.textTheme.bodyMedium),
          Switch.adaptive(
            value: _bluetoothOn,
            onChanged: (val) async {
              AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
            },
            activeColor: theme.colorScheme.secondary, // theme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothDisabledView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Le Bluetooth est désactivé.",
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton( // FFButtonWidget
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
            },
            child: const Text("Activer le Bluetooth"),
            // options: FFButtonOptions(...)
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return ErreurWidget(
      title: "Erreur de Connexion",
      message: "La connexion à l'appareil a été perdue ou a échoué. Veuillez réessayer.",
      icon: Icons.bluetooth_disabled,
      actions: [
        ErrorAction(label: "Réessayer de scanner", onPressed: () {
          setState(() => _showConnectionErrorView = false);
          _scanForDevices();
        }),
      ],
    );
  }

  Widget _buildConnectedDeviceView(ThemeData theme) {
    if (_connectedDevice == null) return const SizedBox.shrink(); // Sécurité

    return SingleChildScrollView( // Pour éviter le débordement si beaucoup de données
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Connecté à:",
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _connectedDevice!.platformName.isNotEmpty ? _connectedDevice!.platformName : _connectedDevice!.remoteId.str,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            "Données des Capteurs:",
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (_sensorValues.isEmpty && !_isConnecting) // Afficher "En attente" si pas de données et pas en connexion
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "En attente de données...",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            )
          else if (_isConnecting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(), const SizedBox(width: 10), Text("Connexion/Lecture...", style: theme.textTheme.bodyMedium)]),
            )
          else
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _sensorValues.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${entry.key}:", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text(entry.value, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _disconnectFromDevice,
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            child: Text("Se déconnecter", style: TextStyle(color: theme.colorScheme.onError)),
          ),
          const SizedBox(height: 10),
          TextButton( // Bouton pour lister les UUIDs (pour débogage)
            onPressed: () {
              if (_connectedDevice != null && _connectedDevice!.isConnected) {
                listAllUuids(_connectedDevice!);
              } else {
                _showSnackbar("Connectez-vous d'abord à un appareil.");
              }
            },
            child: const Text("Lister les UUIDs de l'appareil (Debug)"),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelectionView(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            onPressed: _isScanning ? null : _scanForDevices, // Désactiver si scan en cours
            child: _isScanning ? const Row(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(strokeWidth: 2, color: Colors.white), SizedBox(width: 8), Text("Scan...")]) : const Text("Scanner les appareils"),
          ),
        ),
        _buildDeviceList("Appareils associés", _pairedDevices, theme),
        _buildDeviceList("Appareils disponibles", _availableDevices, theme),
      ],
    );
  }

  Widget _buildDeviceList(String title, List<BluetoothDevice> devices, ThemeData theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 4.0),
            child: Text(title, style: theme.textTheme.titleMedium),
          ),
          if (_isConnecting && title.contains("disponibles")) // Afficher seulement pour la liste où on pourrait cliquer
            const Padding(padding: EdgeInsets.all(8.0), child: Center(child: Text("Connexion en cours..."))),
          if (devices.isEmpty && !(title.contains("disponibles") && _isScanning))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(title.contains("disponibles") && _isScanning ? "Recherche..." : "Aucun appareil trouvé.")),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: Icon(Icons.bluetooth, color: theme.colorScheme.primary),
                  title: Text(device.platformName.isNotEmpty ? device.platformName : "Appareil inconnu"),
                  subtitle: Text(device.remoteId.str),
                  trailing: _isConnecting && _connectedDevice?.remoteId == device.remoteId
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: (_isConnecting || ( _connectedDevice != null && _connectedDevice!.isConnected)) ? null : () => _connectToDevice(device), // Désactiver si déjà connecté ou en cours de connexion
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

